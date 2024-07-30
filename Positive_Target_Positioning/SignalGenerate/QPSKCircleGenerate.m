% ����Բ����QPSK�ź�
% ����1��radar �״�
% ����2��target Ŀ��
% ����3��f0 ��Ƶ
% ����4��code ��Ԫ����/��Ԫ��Ŀ
% ����5��B ����
% ����6��t ����ʱ��
% ����7��fs ����Ƶ��
% ����8��generate_noise �������� (�������ֵΪ��������� ����ֵΪnan or inf ��Ч)
function Signal = QPSKCircleGenerate(radar, target, f0, code, B, ...
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
        code_ = randi([1 4], [1 fix(sampleNum / 100)]); 
        code  = [];
        index = 1;
        for cc = 1:sampleNum
            if cc > sampleNum / 100 * index
                index = index + 1;
            end
            code = [code code_(index)];
        end
    end
        
    % pi / 4: 00 3 pi / 4: 10 5 pi / 4: 11 7 pi / 4 : 01
    % ת��Ϊ4QPSK
    phase = [pi / 4 3 * pi / 4  5 * pi / 4 7 * pi / 4];
    gray  = [1 3 4 2];
    %        00 01 11 10
    
    % ʱ��
    t       = linspace(1, t, sampleNum);
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
%             theta    = theta_(tt);
%             fai      = fai_(tt);

            % �״����
            r0     = radar{rr}.r0; % �״�뾶
            M      = radar{rr}.M;  % �״�����
            c      = 3e8;      % ����
            lambda = c / f0;   % ����
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
        S = cos(f0 * 2 * pi * t) .* cos(B * 2 * pi * t + phase(code));
        
        % �뱾���źŽ������
        S = S .* cos(f0 * 2 * pi * t + randn());
        
        filt = fir1(32, (2 * B) / (3 * fs), 'low');
        S = filter(filt, 1, S);
        
        S = S .* cos(B * 2 * pi * t);
        filt = fir1(32, 1e-100, 'low');
        S = filter(filt, 1, S); % ������Ҫ��һ�����ò���

        figure(114514)
        code = gray(code);
        plot(S)
        hold on
        plot((code - 2.5) / 4.0)
        
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