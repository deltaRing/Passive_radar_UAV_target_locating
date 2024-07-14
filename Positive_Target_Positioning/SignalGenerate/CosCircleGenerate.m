% 生成圆阵列信号
% 输入1：radar 雷达
% 输入2：target 目标
% 输入3：f0 载频
% 输入4：t 持续时间
% 输入5：sampleNum 采样数
% 输入6：generate_noise 生成噪声 (输入具体值为具体信噪比 若该值为nan or inf 无效)
function Signal = CosCircleGenerate(radar, target, f0, ...
    t, sampleNum, SNR)
    
    if nargin == 2
        f0  = 5.8e9;
        t = 1e-10; % seconds
        sampleNum = 256;
        SNR = 15;
    end
    
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
%             theta    = theta_(tt);
%             fai      = fai_(tt);

            % 雷达参数
            r0     = radar{rr}.r0; % 雷达半径
            M      = radar{rr}.M;  % 雷达阵列
            c      = 3e8;      % 光速
            lambda = c / f0;   % 波长
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
        % 时间
        dt       = linspace(1, t, sampleNum);
        % 信号生成
        S = exp(1j * f0 * pi * dt);
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