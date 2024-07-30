function theta_range = MVDR(signal, azNum, elNum, f0, r0)
    if nargin == 1
        azNum = 360;
        elNum = 180;
        f0 = 1e6;
        r0 = 5.0;
    end
    M = size(signal, 1); 
    N = size(signal, 2);        
    c      = 3e8;      % ����
    lambda = c / f0;   % ����
    
    Rs  = signal * signal' / N; % ����غ���
    iRs = inv(Rs + 1e-10 * eye(M));              % �����
    
    % �����ռ���
    theta_range = [];
    for az = 1:azNum
        angleAz = 2 * pi / azNum * az;
        for el = 1:elNum
            angleEl = pi / 2 / elNum * el;
            % �ӳ�ʱ��
            tau = r0 / lambda * cos(angleAz - 2 * pi * (0:M-1) / M) * sin(angleEl);
            % ����ʸ��
            A   = exp(1j * 2 * pi * tau);
            % Ȩ��
            w   = iRs * A' / (A * iRs' * A' + 1e-10);
            % ����ֵ
            theta_range(az, el)= w' * Rs * w;
        end
        
    end


end