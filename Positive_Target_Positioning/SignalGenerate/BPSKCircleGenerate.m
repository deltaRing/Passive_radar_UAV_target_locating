% 生成圆阵列BPSK信号
% 输入1：radar 雷达
% 输入2：target 目标
% 输入3：f0 载频
% 输入4：code 码元种类/码元数目
% 输入5：B 带宽
% 输入6：t 持续时间
% 输入7：fs 采样频率
% 输入8：generate_noise 生成噪声 (输入具体值为具体信噪比 若该值为nan or inf 无效)
function Signal = BPSKCircleGenerate(radar, target, f0, code, B, ...
    t, fs, SNR)
    if nargin == 2
        f0  = 5.8e9; % 
        B   = 1e6;   % 1MHz
        code = 'rand';
        t = 1e-7; % seconds
        fs = 1e11;
        SNR = 15;
    end
    
    sampleNum = fix(fs * t);
    if code == 'rand'
        code_ = randi([0 1], [1 fix(sampleNum / 20)]); 
        code  = [];
        index = 1;
        for cc = 1:sampleNum
            if cc > sampleNum / 100 * index
                index = index + 1;
            end
            code = [code code_(index)];
        end
    end
        
    % 时间
    t       = linspace(1, t, sampleNum);
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
        % 信号生成
        S = cos(f0 * 2 * pi * t) .* cos(B * 2 * pi * t + pi * code);
        
        % 与本征信号进行相乘
        S = S .* cos(f0 * 2 * pi * t);
        
        filt = fir1(32, (2 * B) / (3 * fs), 'low');
        S = filter(filt, 1, S);
        
        S = S .* cos(B * 2 * pi * t);
        filt = fir1(32, 1e-100, 'low');
        S = filter(filt, 1, S); % 这里需要进一步设置参数

%         plot(S)
%         hold on
%         plot(code)
        
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