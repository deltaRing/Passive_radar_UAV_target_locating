% ≤‚ ‘STFT
function test_STFT(data, figureIndex, windowSize, overlap, nfft)
    if nargin == 1
        figureIndex = 1000;
        windowSize  = 64;
        overlap     = 16;
        nfft        = 128;
    end
    [s,f,t] = spectrogram(data, hamming(windowSize), overlap, nfft);
    figure(figureIndex)
    imagesc(t,f,abs(s).^2)
end