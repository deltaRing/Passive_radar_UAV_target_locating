% 通过多角度定位结果以及多雷达定位结果实现
% 输入1：雷达目标
% 输入2：定位结果
%
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
                    % result11 = atan2(y - Pos_r(2), x - Pos_r(1)); % 
                    % result12 = atan2(y - Pos_rr(2), x - Pos_rr(1)); %
                    % tan(angle1(1)) * (x - Pos_r(1)) + Pos_r(2) = y
                    % tan(angle2(1)) * (x - Pos_rr(1)) + Pos_rr(2) = y
                    % 求解X Y坐标
                    x = (Pos_r(1) - tan(angle2(1)) / tan(angle1(1)) * Pos_rr(1) + ...
                        (Pos_rr(2) - Pos_r(2)) / tan(angle1(1))) / ...
                        (1 - tan(angle2(1)) / tan(angle1(1)));
                    y = tan(angle1(1)) * (x - Pos_r(1)) + Pos_r(2);
                    deltaRange1 = norm([x - Pos_r(1) y - Pos_r(2)]);
                    deltaRange2 = norm([x - Pos_rr(1) y - Pos_rr(2)]);
                    % result21 = atan2(z - Pos_r(3), norm([x - Pos_r(1) y - Pos_r(2)])); %
                    % result22 = atan2(z - Pos_rr(3), norm([x - Pos_rr(1) y - Pos_rr(2)])); %
                    
                    % 求解Z坐标
                    z1 = tan(angle1(2)) * deltaRange1 + Pos_r(3);
                    z2 = tan(angle2(2)) * deltaRange2 + Pos_rr(3);
                    Targets = [Targets; x y (z1 + z2) / 2];
                end
            end
        end
    end
end