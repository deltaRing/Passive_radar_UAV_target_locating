% ���������ź�
% ����1��radar �״�
% ����2��target Ŀ��
% ����3��code �����λ���� 1 x ??
% ����4��f0 Ƶ��Դ 1 x N
% ����5��t ����ʱ��
% ����6��fs ����Ƶ��
% ����7��SNR �����
% ����8��fj ����Ƶ��
% ����9��B ����
% ����10��fc ��ԪƵ��
% ����11��rand_cnum ��Ԫ����
function [Signal, FSK_generate] = HopSignalFSKGenerate(radar, target, rand_num, f0, ...
    t, fs, SNR, fj, B, fc, rand_cnum)
    GHz = 1e9;
    MHz = 1e6;
    KHz = 1e3;
    if nargin == 2
        % ���Ƶ����Ŀ
        rand_num  = 10;
        % 10�����Ƶ�� from 2.3 GHz �� 2.5 GHz
        f0        = linspace(2.3995 * GHz, 2.4005 * GHz, rand_num);
        t         = 0.01; % 1����
        fs        = 200 * MHz; % ������Ϊ100MHz
        SNR       = 3; % 3dB SNR
        fj        = 1000; % ����Ƶ��Ϊ1000Hz 1ms
        rand_cnum = 20;
        fc        = 1 * KHz;
        B         = linspace(10 * MHz, 80 * MHz, rand_cnum);
    end
    Number        = t * fs; % ������Ŀ
    code_number   = t * fj; % ��Ƶ������Ŀ
    FSK_number    = t * fc;
    code_length   = Number / code_number; % ÿ�������������
    FSK_length    = Number / FSK_number;
    code_generate = randi([1, rand_num], [1, code_number]);
    FSK_generate  = randi([1, rand_cnum], [1, FSK_length]);
    code_window   = zeros(1, Number);
    FSK_window    = zeros(1, Number);
    
    % �����������
    for ii = 1:code_number
        code_window(1, (ii-1)*code_length+1:ii*code_length) = ...
            code_generate(ii);
    end
    
    % �����������
    for ii = 1:FSK_number
        FSK_window(1, (ii-1)*FSK_length+1:ii*FSK_length) = ...
            FSK_generate(ii);
    end
    % ����ʱ��
    time = linspace(0, t, Number);
    
    Signal = {}; % �ź�
    for rr = 1:length(radar)
        A = [];
        for tt = 1:length(target)
            deltaPos = target{tt}.Pos - radar{rr}.Pos;
            xyPos    = norm(deltaPos(1:2));
            xPos     = deltaPos(1); % λ��x
            yPos     = deltaPos(2); % λ��y
            zPos     = deltaPos(3); % λ��z
            theta    = atan2(yPos, xPos);  % ��λ��
            fai      = atan2(zPos, xyPos); % ������

            % �״����
            r0     = radar{rr}.r0; % �״�뾶
            M      = radar{rr}.M;  % �״�����
            c      = 3e8;      % ����
            lambda = c / f0(fix(length(f0) / 2));   % ����
            % Ŀ�����
            RCS    = target{tt}.RCS; % Ŀ��RCS
            TarPos = target{tt}.Pos;
            % �ӳ�ʱ��
            tau      = r0 / lambda * cos(theta - 2 * pi * (0:M-1) / M) * sin(fai);
            % ����ʸ��
            A(:, tt) = exp(1j * 2 * pi * tau).';
            % ��ȡ����
            amp(tt) = radar{rr}.Pr(RCS, lambda, TarPos);
        end
        % �ź�����
        S = exp(1j * 2 * pi * f0(code_window) .* time) .* exp(1j * 2 * pi * B(FSK_window) .* time);
        % ���
        S = S .* exp(-1j * 2 * pi * f0(fix(length(f0) / 2)) .* time);
        
        S = repmat(S, [length(target), 1]);
        X = A * S;
        
        % ���������
        if isnan(SNR) || isinf(SNR)
            
        else
           X = awgn(X, SNR);
        end
        Signal{rr} = X;
    end
end
