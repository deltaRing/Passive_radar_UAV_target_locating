function [X, f0_] = generate_channel_data(frePoint, freq, time, sampleNum, SNR)
    load phase.mat
    MHz = 1e6;
    f0 = (1000:100:18000) * MHz;
    
%     f1=1:0.1:18;
%     plot(a1_f(:,152),'r-');hold on;
%     plot(a2_f(:,152),'g-');hold on;
%     plot(a3_f(:,152),'b-');hold on;
%     plot(a4_f(:,152),'k-');hold on;
%     plot(a5_f(:,152),'y-');hold on;
%     k1=16;
%     b1=a1_f(:,k1)-a1_f(61,k1);
%     b2=a2_f(:,k1)-a2_f(61,k1);
%     b3=a3_f(:,k1)-a3_f(61,k1);
%     b4=a4_f(:,k1)-a4_f(61,k1);
%     b5=a5_f(:,k1)-a5_f(61,k1);
%     f=f1(k1-1);
%     a1_x=exp(sqrt(-1)*(b1)*pi/180);
%     a2_x=exp(sqrt(-1)*(b2)*pi/180);
%     a3_x=exp(sqrt(-1)*(b3)*pi/180);
%     a4_x=exp(sqrt(-1)*(b4)*pi/180);
%     a5_x=exp(sqrt(-1)*(b5)*pi/180);
    
    % 延迟时间
    tau = [table2array(ch1p(frePoint, freq))';
            table2array(ch2p(frePoint, freq))';
            table2array(ch3p(frePoint, freq))';
            table2array(ch4p(frePoint, freq))';
            table2array(ch5p(frePoint, freq))'] / 180.0 * pi;
    % 导向矢量
    A = exp(1j * tau);
    % 时间设置
    t = linspace(0, time, sampleNum);
    % 信号生成
    S = exp(1j * f0(freq) * 2 * pi * t);
    X = A * S;
    X = awgn(X, SNR);
    f0_ = f0(freq);
end