clear all
clc

%%%%%% 无源雷达 %%%%%%
addpath ./Utilize
addpath ./Initialize
addpath ./SignalGenerate
addpath ./AngleAlgorithm
addpath ./ChannelDetection

radarLoc = [0 0 0;
            -300 -600 0;
            800 -300 0;
            -300 600 0;
            ]; % 雷达位置
radarVelo = [10 10 0;
    20 -20 10;
    -15 20 -10;
    0 0 0];
ID = [0 1 2 3];
M = [16 16 16 16];
r0 = [0.2586 0.2586 0.2586 0.2586]; 
targetLoc   = [300 800 300;
               -600 -300 200]; 
targetVel   = [0 0 0;
                0 0 0];
targetID    = [0 1];
angleAzAxis = linspace(pi, -pi, 360);
angleElAxis = linspace(0, pi / 2, 90);

% 初始化雷达
for rr = 1:length(ID)
    radar{rr}  = RadarInitialize(radarLoc(rr, :), ID(rr), ...
        M(rr), r0(rr), radarVelo(rr, :));
end
% 初始化目标
for tt = 1:length(targetID)
    target{tt} = TargetInitialize(targetLoc(tt, :), ...
        targetVel(tt, :), targetID(tt));
end

radar_record = [];
EstimatedAngle = [];
Map = {};
label = {};

for tt = 0:0.5:5
    radar  = UpdateRadar(radar, tt);
    target = UpdateTarget(target, tt); 
    % signal = CosCircleGenerate(radar, target, 5.8e9, 1e-1, 1e3, 3);
%     signal = BPSKCircleGenerate(radar, target, 5.8e9, 'rand', 1e6, 1e-7, 1e11, 3);
    % signal   = QPSKCircleGenerate(radar, target, 5.8e9, 'rand', 1e6, 1e-7, 1e11, 3);
    [signal, code] = HopSignalFSKGenerate(radar, target);
    Time = channelTimeDetection(signal{1});
    label = PrepareLabel(targetLoc);
    for rr = 1:length(radar)
    %    angle  = MUSIC(signal{rr}, 1, 360, 90, 5.8e9, radar{rr}.r0);
        angle  = MVDR(signal{rr}, 360, 90, 5.8e9, radar{rr}.r0);

        figure(10000)
        mesh(angleElAxis, angleAzAxis, abs(flip(angle)))
        title(strcat('基站',num2str(rr),'MVDR估计结果'))
        xlabel('俯仰角')
        ylabel('方位角')
%         EstimatedAngle{end} = AngleInfoExtract(flip(angle), angleAzAxis, angleElAxis);
        Map{rr} = GetPotentionalLocation(radar{rr}.Pos, flip(angle));
    end
end

Targets         = LocateTarget_using_RangeInfo(radar, EstimatedAngle);
Targets_cluster = DBSCAN(Targets, 500, 3);
TargetNums      = unique(Targets_cluster(:, 4));

Targets         = [];
for tt = 1:length(TargetNums)
   index = find(Targets_cluster(:, 4) == TargetNums(tt));
   Target = Targets_cluster(index, 1:3);
   Targets = [Targets; mean(Target, 1)];
end


figure(10001)
scatter3(Targets(:, 1), Targets(:, 2), Targets(:, 3), 10, 'filled')
