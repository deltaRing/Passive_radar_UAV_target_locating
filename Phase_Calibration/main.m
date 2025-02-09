clear all

%% 设置线阵波形
M = 4;    % 阵列大小
f0 = 2e8; % 200MHz
t = linspace(0, 1e-8, 1e3 * 1e-8 * f0);

% 相位噪声
w = rand([1, M]) * pi;

% FFT点数
FFTN = 128;

% 入射角度
theta = [-pi / 6 -pi / 6 pi / 3 pi / 4 -pi / 4 0.0];
phi = pi * sin(theta);

Signal = {};
Signal_raw = {};
FFT = {};
FFT_raw = {};
A_ = {};
A_raw = {};

for ii = 1:length(phi)
    Amp = 0.9975 + 1e-3 * rand(1, M);
    s = exp(1j * 2 * pi * f0 * t);
    A = exp(1j * [0:M-1] * phi(ii)); 
    S = awgn(A.' * s, 10);
    Signal_raw{ii} = S;
    FFT_raw{ii} = fft(S(:, 10), FFTN);
    A_raw{ii} = A;
    % FFT测角
    figure(1)
    plot(abs(fft(S(:, 10), FFTN)))

    % 加相位噪声
    S = zeros(M, length(t));
    A = Amp .* exp(1j * ([0:M-1] * phi(ii) + w)); 
    S = awgn(A.' * s, 10);
    
    % 加入部分多径
    delay = randi([10, 100]);
    Signal{ii} = S + 1e-1 * rand() * [zeros(M,delay-1) S(:, delay:end)];
    A_{ii} = A;
    FFT{ii} = fft(S(:, 10), FFTN);
    % FFT测角
    figure(2)
    plot(abs(fft(S(:, 10), FFTN)))
    drawnow
end

% DFT 矩阵
for kk = 1:FFTN
    DFT(kk, :) = exp(-1j * 2 * pi / FFTN * [0:(FFTN-1)] * kk);
end
% 同FFT结果相同
sss = DFT * [S(:, 10); zeros(FFTN-4, 1)]; % 【DFT 矩阵 * 信号 + 插零部分】

for ii = 1:length(Signal)
    s_ = Signal{ii};
    s_p = zeros(M, length(t));
    p = zeros(M, length(t));
    pp = [];
    
%     for tt = 1:length(t)
%         s_d(1, tt) = s_(1, tt)* conj(s_(2, tt)); % doa + d1
%         s_d(2, tt) = s_(1, tt)* conj(s_(3, tt)); % 2doa + d2
%         s_d(3, tt) = s_(1, tt)* conj(s_(4, tt)); % 3doa + d3
%         s_d(4, tt) = s_(2, tt)* conj(s_(3, tt)); % doa + d2 - d1
%         s_d(5, tt) = s_(2, tt)* conj(s_(4, tt)); % 2doa + d3 - d1
%         s_d(6, tt) = s_(3, tt)* conj(s_(4, tt)); % doa + d3 - d2
%         pp(:, tt) = [phase(s_d(1, tt));
%             phase(s_d(2, tt));
%             phase(s_d(3, tt));
%             phase(s_d(4, tt));
%             phase(s_d(5, tt));
%             phase(s_d(6, tt));
%             ];
%     end
%     
%     Ob = [1 1 0 0; 2 0 1 0; 3 0 0 1;];
%         %1 -1 1 0; 2 -1 0 1; 1 0 -1 1];
%     
%     for tt = 1:length(t)
%         res(:, tt) = inv(Ob' * Ob + 1e-12 * eye(4)) * Ob' * pp(1:3, tt);
%     end
%     
%     figure(3)
%     plot(res(1, :))
%     hold on
%     plot(res(2, :))
%     plot(res(3, :))
%     plot(res(4, :))
    
    for tt = 1:length(t)
        s_p(:, tt) = s_(:, tt) .* conj(A_raw{ii}).';
        p(:, tt) = [phase(s_p(1, tt)) 
            phase(s_p(2, tt)) 
            phase(s_p(3, tt)) 
            phase(s_p(4, tt))];
    end
    p_diff_1 = p(1, :) - p(2, :);
    p_diff_2 = p(1, :) - p(3, :);
    p_diff_3 = p(1, :) - p(4, :);
    p_diff_4 = p(2, :) - p(3, :);
    p_diff_5 = p(2, :) - p(4, :);
    p_diff_6 = p(3, :) - p(4, :);
    
    p_1 = DBSCAN(p_diff_1', 1, 50);
    p_2 = DBSCAN(p_diff_2', 1, 50);
    p_3 = DBSCAN(p_diff_3', 1, 50);
    p_4 = DBSCAN(p_diff_4', 1, 50);
    p_5 = DBSCAN(p_diff_5', 1, 50);
    p_6 = DBSCAN(p_diff_6', 1, 50);
    
    if length(find(p_1(:, 2) == 1)) >  length(find(p_1(:, 2) == 2))
        p1 = mean(p_1(find(p_1(:, 2) == 1), 1));
    else
        p1 = mean(p_1(find(p_1(:, 2) == 2), 1));
    end
    
    if length(find(p_2(:, 2) == 1)) >  length(find(p_2(:, 2) == 2))
        p2 = mean(p_2(find(p_2(:, 2) == 1), 1));
    else
        p2 = mean(p_2(find(p_2(:, 2) == 2), 1));
    end
    
    if length(find(p_3(:, 2) == 1)) >  length(find(p_3(:, 2) == 2))
        p3 = mean(p_3(find(p_3(:, 2) == 1), 1));
    else
        p3 = mean(p_3(find(p_3(:, 2) == 2), 1));
    end
    
    s_(2, :) = s_(2, :) * exp(1j * p1);
    s_(3, :) = s_(3, :) * exp(1j * p2);
    s_(4, :) = s_(4, :) * exp(1j * p3);
    figure(1)
    plot(abs(fft(Signal_raw{ii}(:, 10), FFTN)))
    title('Raw Signal')
    figure(2)
    plot(abs(fft(Signal{ii}(:, 10), FFTN)))
    title('Before Calibration')
    figure(3)
    plot(abs(fft(s_(:, 10), FFTN)))
    title('After Calibration')
end

% w_init = zeros(1, 4);
% J      = zeros(FFTN, M);
% %% 解相位噪声
% for ii = 1:length(Signal)
%     S = Signal{ii};
%     sss = DFT * [S(:, 10); zeros(FFTN-M, 1)];
%     for iii = 1:1000
%         for kk = 1:FFTN
%             J(kk, :) = 1j * S(:, 10).' .* exp(1j * ([0:M-1] * pi * sin(theta(ii)) + w_init - 2 * pi / FFTN * [0:M-1] * kk));
%         end
%         dw = -inv(J' * J + 1e-10 * eye(M)) * J' * sss;
%         % 转换为角度
%         d_w = atan2(imag(dw), real(dw));
%         d_w = rem(d_w, 2 * pi);
%         
%         w_init = w_init + d_w.';
%         % 去除重复部分
%         w_init = rem(w_init, 2 * pi); 
%     end
% end
