% 生成跳变信号
% 输入1：radar 雷达
% 输入2：target 目标
% 输入3：code 随机相位编码 1 x ??
% 输入4：f0 频率源 1 x N
% 输入5：t 持续时间
% 输入6：fs 采样频率
% 输入7：SNR 信噪比
% 输入8：fj 跳变频率
% 输入9：B 带宽
% 输入10：fc 码元频率
% 输入11：rand_cnum 码元个数
function [Signal, FSK_generate] = HopSignalFSKGenerate(radar, target, rand_num, f0, ...
    t, fs, SNR, fj, B, fc, rand_cnum)
    GHz = 1e9;
    MHz = 1e6;
    KHz = 1e3;
    if nargin == 2
        % 随机频点数目
        rand_num  = 10;
        % 10个随机频点 from 2.3 GHz 到 2.5 GHz
        f0        = linspace(2.3995 * GHz, 2.4005 * GHz, rand_num);
        t         = 0.01; % 1秒钟
        fs        = 200 * MHz; % 采样率为100MHz
        SNR       = 3; % 3dB SNR
        fj        = 1000; % 跳变频率为1000Hz 1ms
        rand_cnum = 20;
        fc        = 1 * KHz;
        B         = linspace(10 * MHz, 80 * MHz, rand_cnum);
    end
    Number        = t * fs; % 采样数目
    code_number   = t * fj; % 调频编码数目
    FSK_number    = t * fc;
    code_length   = Number / code_number; % 每个编码持续数量
    FSK_length    = Number / FSK_number;
    code_generate = randi([1, rand_num], [1, code_number]);
    FSK_generate  = randi([1, rand_cnum], [1, FSK_length]);
    code_window   = zeros(1, Number);
    FSK_window    = zeros(1, Number);
    
    % 生成随机编码
    for ii = 1:code_number
        code_window(1, (ii-1)*code_length+1:ii*code_length) = ...
            code_generate(ii);
    end
    
    % 生成随机编码
    for ii = 1:FSK_number
        FSK_window(1, (ii-1)*FSK_length+1:ii*FSK_length) = ...
            FSK_generate(ii);
    end
    % 生成时间
    time = linspace(0, t, Number);
    
    Signal = {}; % 信号
    for rr = 1:length(radar)
        A = [];
        for tt = 1:length(target)
            deltaPos = target{tt}.Pos - radar{rr}.Pos;
            xyPos    = norm(deltaPos(1:2));
            xPos     = deltaPos(1); % 位置x
            yPos     = deltaPos(2); % 位置y
            zPos     = deltaPos(3); % 位置z
            theta    = atan2(yPos, xPos);  % 方位角
            fai      = atan2(zPos, xyPos); % 俯仰角

            % 雷达参数
            r0     = radar{rr}.r0; % 雷达半径
            M      = radar{rr}.M;  % 雷达阵列
            c      = 3e8;      % 光速
            lambda = c / f0(fix(length(f0) / 2));   % 波长
            % 目标参数
            RCS    = target{tt}.RCS; % 目标RCS
            TarPos = target{tt}.Pos;
            % 延迟时间
            tau      = r0 / lambda * cos(theta - 2 * pi * (0:M-1) / M) * sin(fai);
            % 导向矢量
            A(:, tt) = exp(1j * 2 * pi * tau).';
            % 获取幅度
            amp(tt) = radar{rr}.Pr(RCS, lambda, TarPos);
        end
        % 信号生成
        S = exp(1j * 2 * pi * f0(code_window) .* time) .* exp(1j * 2 * pi * B(FSK_window) .* time);
        % 解调
        S = S .* exp(-1j * 2 * pi * f0(fix(length(f0) / 2)) .* time);
        
        S = repmat(S, [length(target), 1]);
        X = A * S;
        
        % 加入信噪比
        if isnan(SNR) || isinf(SNR)
            
        else
           X = awgn(X, SNR);
        end
        Signal{rr} = X;
    end
end

