function theta_range = MVDR(signal, azNum, elNum, f0, r0)
    if nargin == 1
        azNum = 360;
        elNum = 180;
        f0 = 1e6;
        r0 = 5.0;
    end
    M = size(signal, 1); 
    N = size(signal, 2);        
    c      = 3e8;      % 光速
    lambda = c / f0;   % 波长
    
    Rs  = signal * signal' / N; % 自相关函数
    iRs = inv(Rs + 1e-10 * eye(M));              % 逆矩阵
    
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
            % 权重
            w   = iRs * A' / (A * iRs' * A' + 1e-10);
            % 计算值
            theta_range(az, el)= w' * Rs * w;
        end
        
    end


end