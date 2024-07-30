% 初始化目标
% 输入1：Pos
% 输入2：Vel
% 输入3：id
% 可选输入1：目标RCS
% 可选输入2：目标发射的功率
% 可选输入3：单位时间
function target = TargetInitialize(Pos, Vel, id, RCS, Pr, t)
    if nargin == 3
        RCS = 10;   % 1 m2
        Pr  = 10;  % 10w 功率
        t   = 0.1; % 单位步进时间
    end

    target.Pos = Pos; % 目标初始位置
    target.Vel = Vel; % 目标速度
    target.id  = id;  % 目标ID
    target.RCS = RCS; % 目标RCS
    target.Pr  = Pr;  % 目标发射信号的功率
    
    target.F   = [1 t 0 0 0 0;
                  0 1 0 0 0 0;
                  0 0 1 t 0 0;
                  0 0 0 1 0 0;
                  0 0 0 0 1 t;
                  0 0 0 0 0 1]; % 状态转移方程
    target.InitX   = [Pos(1) Vel(1) Pos(2) Vel(2) Pos(3) Vel(3)]; % 目标状态
    target.X   = @(dt) [target.InitX(1) + Vel(1) * dt Vel(1) ...
                            target.InitX(3) + Vel(2) * dt Vel(2) ...
                            target.InitX(5) + Vel(3) * dt Vel(3)];
end