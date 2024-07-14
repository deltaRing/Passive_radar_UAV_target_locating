% MUSIC 算法
% 1、输入1：signal 信号
% 2、输入2：K 信源数目
% 3、输入3：方位向遍历数目
% 4、输入4：俯仰向遍历数目
function theta_range = MUSIC(signal, K, azNum, elNum, f0, r0)
    if nargin == 1
        K = 8;
        azNum = 360;
        elNum = 90;
        f0 = 1e6;
        r0 = 5.0;
    end
    M = size(signal, 1);   
    N = size(signal, 2);      
    c      = 3e8;      % 光速
    lambda = c / f0;   % 波长
    
    Rs = signal * signal' / N;  % 自相关矩阵 
    % 特征值分解
    [EV,D] = eig(Rs);       % 特征值分解
    EVA = diag(D)';         % 将特征值矩阵对角线提取并转为一行
    [EVA,I] = sort(EVA);    % 将特征值排序 从小到大
    EV = fliplr(EV(:,I));   % 对应特征矢量排序
    
    % 遍历空间谱
    theta_range = [];
    for az = 1:azNum
        angleAz = 2 * pi / azNum * az;
        for el = 1:elNum
            angleEl = pi / 2 / elNum * el;
            % 延迟时间
            tau = r0 / lambda * cos(angleAz - 2 * pi * (0:M-1) / M) * sin(angleEl);
            % 导向矢量
            A   = exp(1j * 2 * pi * tau);
            En  = EV(:,K+1:M);             % 取矩阵的第M+1到N列组成噪声子空间
            theta_range(az, el)=1/(A*En*En'*A');
        end
        
    end
end