% ���������ź�
% ����1��radar �״�
% ����2��target Ŀ��
% ����3��code �����λ���� 1 x ??
% ����4��f0 Ƶ��Դ 1 x N
% ����5��t ����ʱ��
% ����6��fs ����Ƶ��
% ����7��SNR �����
% ����8��fj ����Ƶ��
function [Signal, code_generate] = HopSignalGenerate(radar, target, rand_num, f0, ...
    t, fs, SNR, fj)
    GHz = 1e9;
    MHz = 1e6;
    KHz = 1e3;
    if nargin == 2
        % ���Ƶ����Ŀ
        rand_num = 10;
        % 10�����Ƶ�� from 2.3 GHz �� 2.5 GHz
        f0       = linspace(2.3 * GHz, 2.5 * GHz, rand_num);
        t        = 0.01; % 1����
        fs       = 100 * MHz; % ������Ϊ100MHz
        SNR      = 3; % 3dB SNR
        fj       = 1000; % ����Ƶ��Ϊ100Hz 10ms
    end
    Number        = t * fs; % ������Ŀ
    code_number   = t * fj; % ��Ƶ������Ŀ
    code_length   = Number / code_number; % ÿ�������������
    code_generate = randi([1, rand_num], [1, code_number]);
    code_window   = zeros(1, Number);
    % �����������
    for ii = 1:code_number
        code_window(1, (ii-1)*code_length+1:ii*code_length) = ...
            code_generate(ii);
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
        S = exp(1j * 2 * pi * f0(code_window) .* time);
        
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

