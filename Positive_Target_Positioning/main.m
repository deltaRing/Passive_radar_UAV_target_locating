clear all
clc

%%%%%% ��Դ�״� %%%%%%
addpath ./Utilize
addpath ./Initialize
addpath ./SignalGenerate
addpath ./AngleAlgorithm

radarLoc = [1000 1000 0;
            -1000 1000 0;
            1000 -1000 0;
            -1000 -1000 0;
            ]; % �״�λ��
ID = [0 1 2 3];
M = [25 25 25 25];
r0 = [0.625 0.625 0.625 0.625]; 
targetLoc   = [-900 900 500;
               900 900 1000]; 
targetVel   = [5 5 0;
                5 5 0];
targetID    = [0 0];
angleAzAxis = linspace(pi, -pi, 360);
angleElAxis = linspace(0, pi / 2, 90);

% ��ʼ���״�
for rr = 1:length(ID)
    radar{rr}  = RadarInitialize(radarLoc(rr, :), ID(rr), M(rr), r0(rr));
end
% ��ʼ��Ŀ��
for tt = 1:length(targetID)
    target{tt} = TargetInitialize(targetLoc(tt, :), targetVel(tt, :), targetID(tt));
end
signal = CosCircleGenerate(radar, target, 2.4e9, 1e-10, 1e3, 3);

for rr = 1:length(radar)
%     angle  = MUSIC(signal{rr}, 3, 360, 90, 2.4e9, radar{rr}.r0);
    angle  = MVDR(signal{rr}, 360, 90, 2.4e9, radar{rr}.r0);

    figure(10000)
    title('MUSIC���ƽ��')
    xlabel('������')
    ylabel('��λ��')
    mesh(angleElAxis, angleAzAxis, abs(flip(angle)))
    
    EstimatedAngle{rr} = AngleInfoExtract(flip(angle), angleAzAxis, angleElAxis);
end

Targets         = LocateTarget(radar, EstimatedAngle);
Targets_cluster = DBSCAN(Targets, 50, 10);
TargetNums      = unique(Targets_cluster(:, 4));


figure(10001)
scatter3(Targets(:, 1), Targets(:, 2), Targets(:, 3), 10, 'filled')