% 初始化圆阵列雷达
% 输入1：Pos 接受天线
% 输入2：ID 
% 输入3：M 阵列大小
% 输入4：r0 阵列半径
% （可选）输入5： PosTx 发射天线位置
% （可选）输入6： 接受天线增益
% （可选）输入7： 发射天线增益
% （可选）输入8： 雷达发射功率
% （可选）输入9： 雷达类型 （if 1 主动雷达 2 无源雷达）
function radar = RadarInitialize(Pos, id, M, r0, Vel, ...
                        t, PosTx, Gt, Gr, Pt, Type)
    if nargin == 5
        t = 0.1;
        PosTx = Pos;
        Gt    = 10;
        Gr    = 1;
        Pt    = 1e5; % 1Kw
        Type  = 1; 
    end
    radar.Pos = Pos; % 接受天线位置
    radar.Vel = Vel;
    radar.PosTx = PosTx; % 发射天线位置
    radar.id  = id;  % ID
    radar.M   = M;   % 阵列大小
    radar.r0  = r0;  % 圆半径
    
    radar.F   = [1 t 0 0 0 0;
                  0 1 0 0 0 0;
                  0 0 1 t 0 0;
                  0 0 0 1 0 0;
                  0 0 0 0 1 t;
                  0 0 0 0 0 1]; % 状态转移方程
    radar.InitX   = [Pos(1) Vel(1) Pos(2) Vel(2) Pos(3) Vel(3)]; % 目标状态
    radar.X   = @(dt) [radar.InitX(1) + Vel(1) * dt Vel(1) ...
                            radar.InitX(3) + Vel(2) * dt Vel(2) ...
                            radar.InitX(5) + Vel(3) * dt Vel(3)];
    
    % 环境参数
    % 雷达方程 (RCS, lambda:波长)
    if Type == 1
        % 输入1：目标RCS 输入2：信号波长 输入3：目标位置
        radar.Pr = @(RCS, lambda, TarPos) Pt * Gt * Gr * RCS * lambda^2 / ...
            ((4 * pi)^3 * norm(TarPos - Pos)^2 * norm(TarPos - PosTx)^2);
    else
        % 输入1：发射功率 输入2：信号波长 输入3：目标位置
        radar.Pr = @(Pr, lambda, TarPos) Pr * Gr * lambda^2 / ...
            ((4 * pi)^2 * norm(TarPos - Pos)^2);
    end
end