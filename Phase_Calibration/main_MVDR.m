%% 针对圆阵列的相位差检测

%% 设置圆阵列波形
M = 5;    % 阵列大小
r0 = 3e8 / 1.4e9 / 2;
f0 = 2e8; % 200MHz
lambda = 3e8 / f0;   % 波长
t = linspace(0, 1e-8, 1e3 * 1e-8 * f0);

% 相位噪声
w = rand([1, M]) * pi;

% 入射角度
theta = [-pi / 6 pi / 3 pi / 4 -pi / 4 0.0];
fai   = [pi / 4 pi / 6 pi / 7 pi / 4 pi / 6];

Signal = {};
Signal_raw = {};
MVDR_ = {};
MVDR_raw = {};
A_ = {};
A_raw = {};

for ii = 1:length(theta)
    % 相位
    tau = r0 / lambda * cos(theta(ii) - 2 * pi * (0:M-1) / M) * sin(fai(ii));
    % 导向矢量
    A   = exp(1j * 2 * pi * tau);
    
    Amp = 0.9975 + 1e-3 * rand(1, M);
    s = exp(1j * 2 * pi * f0 * t);
    S = awgn(A.' * s, 10);
    Signal_raw{ii} = S;
    MVDR_raw{ii} = MVDR(S);
    A_raw{ii} = A;
    % FFT测角
    figure(1)
    mesh(abs(MVDR_raw{ii}))

    % 加相位噪声
    S = zeros(M, length(t));
    A = Amp .* exp(1j * 2 * pi * tau + 1j * w); 
    S = awgn(A.' * s, 10);
    Signal{ii} = S;
    A_{ii} = A;
    MVDR_{ii} = MVDR(S);
    % FFT测角
    figure(2)
    mesh(abs(MVDR_{ii}))
    drawnow
end

for ii = 1:length(Signal)
    s_ = Signal{ii};
    s_p = zeros(M, length(t));
    p = zeros(M, length(t));
    pp = [];
   for tt = 1:length(t)
        s_p(:, tt) = s_(:, tt) .* conj(A_raw{ii}).';
        p(:, tt) = [phase(s_p(1, tt)) 
            phase(s_p(2, tt)) 
            phase(s_p(3, tt)) 
            phase(s_p(4, tt))
            phase(s_p(5, tt))];
   end
    
   p_diff_1 = p(1, :) - p(2, :);
   p_diff_2 = p(1, :) - p(3, :);
   p_diff_3 = p(1, :) - p(4, :);
   p_diff_4 = p(1, :) - p(5, :);
    
   p_1 = DBSCAN(p_diff_1', 1, 50);
   p_2 = DBSCAN(p_diff_2', 1, 50);
   p_3 = DBSCAN(p_diff_3', 1, 50);
   p_4 = DBSCAN(p_diff_4', 1, 50);
    
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
    
    if length(find(p_4(:, 2) == 1)) >  length(find(p_4(:, 2) == 2))
        p4 = mean(p_4(find(p_4(:, 2) == 1), 1));
    else
        p4 = mean(p_4(find(p_4(:, 2) == 2), 1));
    end
    
    s_(2, :) = s_(2, :) * exp(1j * p1);
    s_(3, :) = s_(3, :) * exp(1j * p2);
    s_(4, :) = s_(4, :) * exp(1j * p3);
    s_(5, :) = s_(5, :) * exp(1j * p4);
    figure(1)
    mesh(abs(MVDR(Signal_raw{ii})))
    title('Raw Signal')
    figure(2)
    mesh(abs(MVDR(Signal{ii})))
    title('Before Calibration')
    figure(3)
    mesh(abs(MVDR(s_)))
    title('After Calibration')
end

