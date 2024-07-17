% 利用雷达距离信息实现目标定位
% 输入1：雷达相关信息
% 输入2：探测角度的相关信息
% 输出1：目标位置信息
function TargetPos = LocateTarget_using_RangeInfo(Radars, Angles)
    TargetPos = [];
    
    for rr = 1:length(Radars)
        Pos_r = Radars{rr}.Pos; % 接收天线1
        for rrr = rr:length(Radars)
            if rr == rrr, continue; end
            Pos_rr = Radars{rrr}.Pos; % 接收天线2
            
            thetaR1 = atan2(Pos_rr(2) - Pos_r(2), Pos_rr(1) - Pos_r(1));
            thetaR2 = atan2(Pos_r(2) - Pos_rr(2), Pos_r(1) - Pos_rr(1));
            
            %% 射线
            for tt = 1:length(Angles{rr})
                angle1 = Angles{rr}(:, tt);
                for ttt = 1:length(Angles{rrr})
                    angle2 = Angles{rrr}(:, ttt);
                    %% 求解交点 定位结果
                    
                    RadarRange = norm(Pos_r - Pos_rr);
                    
                    theta1 = angle1(1); theta2 = angle2(1);
                    fai1   = angle1(2); fai2   = angle2(2);
                    if abs(theta1 - thetaR1) > pi
                        thetaA1 = 2 * pi - abs(theta1 - thetaR1);
                    else
                        thetaA1 = abs(theta1 - thetaR1);
                    end
                    
                    if abs(theta2 - thetaR2) > pi
                        thetaA2 = 2 * pi - abs(theta2 - thetaR2);
                    else
                        thetaA2 = abs(theta2 - thetaR2);
                    end
                    
                    thetaTar  = pi - thetaA1 - thetaA2;
                    rangeR1xy = RadarRange / sin(thetaTar) * sin(thetaA2);
                    rangeR2xy = RadarRange / sin(thetaTar) * sin(thetaA1);
                   
                    PosRadar1x = rangeR1xy * cos(theta1);
                    PosRadar1y = rangeR1xy * sin(theta1);
                    PosRadar1z = rangeR1xy * tan(fai1);
                    
                    PosRadar2x = rangeR2xy * cos(theta2);
                    PosRadar2y = rangeR2xy * sin(theta2);
                    PosRadar2z = rangeR2xy * tan(fai2);
                    
                    PosTar1    = [PosRadar1x PosRadar1y PosRadar1z];
                    PosTar2    = [PosRadar2x PosRadar2y PosRadar2z];
                    
                    CorRes1    = PosTar1 + Pos_r;
                    CorRes2    = PosTar2 + Pos_rr;
                    TargetPos = [TargetPos; (CorRes1 + CorRes2) / 2];
                end
            end
        end
    end
end