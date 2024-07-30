% �ŵ�����ʱ����
% ����1���ź�
% ����2��������
% ����3������Ƶ��
% ����4��
%
function Time = channelTimeDetection(S, checkWindow, fs,...
    fftn, figureIndex, threshold)
    GHz = 1e9;
    MHz = 1e6;
    KHz = 1e3;
    if nargin == 1
        checkWindow = 256; % ÿ�ζ�ȡ100����
        fs = 200 * MHz; % ����Ƶ��
        fftn = 512; % FFT����
        figureIndex = 999;
        threshold = 1 * MHz;
    end
    
    Time = [];
    fAxis = fs * (0:(fftn-1)) / fftn;
    lengthS = size(S, 2);
    dt = 0;
%     figure(figureIndex)
    previousF = inf;
    for ii = 1:10:lengthS - checkWindow
        signal      = S(1, ii:ii+checkWindow);
        freq        = fft(signal, fftn);
        freq        = abs(freq);
        [~, index]  = max(freq);
        maxfreq     = fAxis(index);
%         plot(fAxis, freq)
%         drawnow
        if isinf(previousF)
            previousF = maxfreq;
            dt = dt + 10 / fs;
        end
        
        if abs(maxfreq - previousF) < threshold
            previousF = maxfreq;
            dt = dt + 10 / fs;
        else
            Time = [Time dt];
            previousF = maxfreq;
            dt = 10 / fs;
        end
    end
    Time = [Time dt];
end