% 通过多角度定位结果以及多雷达定位结果实现
% 输入1：雷达目标
% 输入2：定位结果
% 输出1：目标所在位置
function Targets = LocateTarget(Radars, Angles)
    % 目标位置
    Targets = [];

    for rr = 1:length(Radars)
        Pos_r = Radars{rr}.Pos; % 接收天线1
        for rrr = rr:length(Radars)
            if rr == rrr, continue; end
            Pos_rr = Radars{rrr}.Pos; % 接收天线2
            
            %% 射线
            for tt = 1:length(Angles{rr})
                angle1 = Angles{rr}(:, tt);
                for ttt = 1:length(Angles{rrr})
                    angle2 = Angles{rrr}(:, ttt);
                    %% 求解交点 定位结果
                    % 求解X Y坐标
                    x = (Pos_r(1) - tan(angle2(1)) / tan(angle1(1)) * Pos_rr(1) + ...
                        (Pos_rr(2) - Pos_r(2)) / tan(angle1(1))) / ...
                        (1 - tan(angle2(1)) / tan(angle1(1)));
                    y = tan(angle1(1)) * (x - Pos_r(1)) + Pos_r(2);
                    deltaRange1 = norm([x - Pos_r(1) y - Pos_r(2)]);
                    deltaRange2 = norm([x - Pos_rr(1) y - Pos_rr(2)]);
                    % 求解Z坐标
                    z1 = tan(angle1(2)) * deltaRange1 + Pos_r(3);
                    z2 = tan(angle2(2)) * deltaRange2 + Pos_rr(3);
                    
                    TargetInitPos1 = [x y z1];
                    TargetInitPos2 = [x y z2];
                    TargetInitPos  = (TargetInitPos1 + TargetInitPos2) / 2;
                    range1 = norm(TargetInitPos1 - Pos_r);
                    range2 = norm(TargetInitPos2 - Pos_rr);
                    
                    measurements = [angle1; angle2; range1; range2];
                    
                    Tar = getTargetPos(TargetInitPos, Pos_r', Pos_rr', measurements);
                    
                    
norm(Tar - Pos_r')
norm(Tar - Pos_rr')
atan2(Tar(2) - Pos_r(2), Tar(1) - Pos_r(1))
atan2(Tar(2) - Pos_rr(2), Tar(1) - Pos_rr(1))
atan2(Tar(3) - Pos_r(3), getDeltaRangeXY(Tar, Pos_r))
atan2(Tar(3) - Pos_rr(3), getDeltaRangeXY(Tar, Pos_rr))
                end
            end
        end
    end
end

% 距离求解
function deltaRange = getDeltaRange(TargetPos, RadarPos)
    deltaRange = sqrt((TargetPos(1) - RadarPos(1))^2 + ...
        (TargetPos(2) - RadarPos(2))^2 + ...
        (TargetPos(3) - RadarPos(3))^2);
end

% 距离求解
function deltaRangeXY = getDeltaRangeXY(TargetPos, RadarPos)
    deltaRangeXY = sqrt((TargetPos(1) - RadarPos(1))^2 + ...
        (TargetPos(2) - RadarPos(2))^2);
end

% 雅可比矩阵
function J = getJacobian(TargetPos, RadarPos_1, RadarPos_2)
    J(1, 1) = (RadarPos_1(2) - TargetPos(2)) / ...
        getDeltaRangeXY(TargetPos, RadarPos_1)^2;

    J(1, 2) = (TargetPos(1) - RadarPos_1(1)) / ...
        getDeltaRangeXY(TargetPos, RadarPos_1)^2;
    
    J(1, 3) = 0.0;
    
    J(2, 1) = -(TargetPos(3) - RadarPos_1(3)) * (TargetPos(1) - RadarPos_1(1)) / ...
        getDeltaRange(TargetPos, RadarPos_1)^2 / getDeltaRangeXY(TargetPos, RadarPos_1);
    
    J(2, 2) = -(TargetPos(3) - RadarPos_1(3)) * (TargetPos(2) - RadarPos_1(2)) / ...
        getDeltaRange(TargetPos, RadarPos_1)^2 / getDeltaRangeXY(TargetPos, RadarPos_1);
    
    J(2, 3) = getDeltaRangeXY(TargetPos, RadarPos_1) / getDeltaRange(TargetPos, RadarPos_1)^2;
    
    J(3, 1) = (RadarPos_2(2) - TargetPos(2)) / ...
        getDeltaRangeXY(TargetPos, RadarPos_2)^2;

    J(3, 2) = (TargetPos(1) - RadarPos_2(1)) / ...
        getDeltaRangeXY(TargetPos, RadarPos_2)^2;
    
    J(3, 3) = 0.0;
    
    J(4, 1) = -(TargetPos(3) - RadarPos_2(3)) * (TargetPos(1) - RadarPos_2(1)) / ...
        getDeltaRange(TargetPos, RadarPos_2)^2 / getDeltaRangeXY(TargetPos, RadarPos_2);
    
    J(4, 2) = -(TargetPos(3) - RadarPos_2(3)) * (TargetPos(2) - RadarPos_2(2)) / ...
        getDeltaRange(TargetPos, RadarPos_2)^2 / getDeltaRangeXY(TargetPos, RadarPos_2);
    J(4, 3) = getDeltaRangeXY(TargetPos, RadarPos_2) / getDeltaRange(TargetPos, RadarPos_2)^2;
    
    J(5, 1) = -TargetPos(1) / getDeltaRange(TargetPos, RadarPos_1);
    J(5, 2) = -TargetPos(2) / getDeltaRange(TargetPos, RadarPos_1);
    J(5, 3) = -TargetPos(3) / getDeltaRange(TargetPos, RadarPos_1);
    
    J(6, 1) = -TargetPos(1) / getDeltaRange(TargetPos, RadarPos_2);
    J(6, 2) = -TargetPos(2) / getDeltaRange(TargetPos, RadarPos_2);
    J(6, 3) = -TargetPos(3) / getDeltaRange(TargetPos, RadarPos_2);
end

% 
function err = getMeasureErr(measurements, TargetPos, RadarPos_1, RadarPos_2)
    theta_1 = atan2(TargetPos(2) - RadarPos_1(2), ...
        TargetPos(1) - RadarPos_1(1));
    
    theta_2 = atan2(TargetPos(2) - RadarPos_2(2), ...
        TargetPos(1) - RadarPos_2(1));
    
    fai_1   = atan2(TargetPos(3) - RadarPos_1(3), ...
        getDeltaRangeXY(TargetPos, RadarPos_1));
    
    fai_2   = atan2(TargetPos(3) - RadarPos_2(3), ...
        getDeltaRangeXY(TargetPos, RadarPos_2));
    
    err = [measurements(1) - theta_1;
        measurements(2) - fai_1;
        measurements(3) - theta_2;
        measurements(4) - fai_2;
        measurements(5) - getDeltaRange(TargetPos, RadarPos_1);
        measurements(6) - getDeltaRange(TargetPos, RadarPos_2)
        ];

end

% 迭代求解
function TargetPos = getTargetPos(TargetInitPos, RadarPos_1, RadarPos_2, ...
                        measurements, sigma, maxIterNum)
    if nargin == 4
        sigma = 1e-6;
        maxIterNum = 1e3;
    end
    
    X  = TargetInitPos';
    J  = getJacobian(X, RadarPos_1, RadarPos_2);
    er = getMeasureErr(measurements, X, RadarPos_1, RadarPos_2);
    
    deltaInfo = inv(J' * J + 1e-8 * eye(3)) * J' * er;
    X  = X + deltaInfo;
    e  = norm(er);
    
    for ii = 1:maxIterNum
        if e < sigma, break; end
        J  = getJacobian(X, RadarPos_1, RadarPos_2);
        er = getMeasureErr(measurements, X, RadarPos_1, RadarPos_2);

        deltaInfo = inv(J' * J + 1e-8 * eye(3)) * J' * er;
        if norm(deltaInfo) < sigma, break; end
        e  = norm(er);
        X  = X + deltaInfo;
    end
    
    TargetPos = X;
end