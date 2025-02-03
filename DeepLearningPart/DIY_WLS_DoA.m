%% 直接利用WDoA求出来的结果太过于离谱，因此采用自定义的WLS-DoA实现精确定位结果
% Origin Source：https://zhuanlan.zhihu.com/p/663164139

%%
% 测向站数量
M=6;
% 目标数量
N=1;
% 6个测向站的位置坐标,单位米
s1=[1200 1800 200].';
s2=[-1500 -800 150].';
s3=[1400 -600 -200].';
s4=[-800 1200 120].';
s5=[1300 -800 -250].';
s6=[-1000 1600 -150].';
S = [s1 s2 s3 s4 s5 s6];
% 目标位置,单位米
u1=[-800 680 700].';
%%

for i=1:M
    % 方位角真实值
    theta0(i)=atan((u1(1)-S(1,i))/(u1(2)-S(2,i)));
    % 仰角真实值
    beta0(i)=atan((u1(3)-S(3,i))/(sqrt((u1(1)-S(1,i))^2+(u1(2)-S(2,i))^2)));
end

for i=1:1:M
    Ga10(i,:)=[cos(theta0(i)),-sin(theta0(i)),0];
    Ga20(i,:)=[sin(theta0(i))*sin(beta0(i)),cos(theta0(i))*sin(beta0(i)),-cos(beta0(i))];
    
    %     组合字符串，得到接收站的变量名，以便循环
    str_si=['s',mat2str(i)];
    %    返回变量名对应的值
    si_value=S(:, i);
    ha10(i,:)=si_value(1)*cos(theta0(i))-si_value(2)*sin(theta0(i));
    ha20(i,:)=si_value(1)*sin(theta0(i))*sin(beta0(i))+...
        si_value(2)*cos(theta0(i))*sin(beta0(i))-si_value(3)*cos(beta0(i));
end

index = [];
results = [];

for ii = 1:M
    for iii = ii:M
        if ii == iii, continue; end
         Ga = [Ga10([ii,iii],:); Ga20([ii,iii],:)];
         Ha = [ha10([ii,iii],:); ha20([ii,iii],:)];
         location =  pinv(Ga) * Ha;
        % 去除错误结果
         if location(3) > 150
             results = [results; location'];
             index   = [index; ii iii];
         end
    end
end

Targets_cluster = DBSCAN(results, 5e2, 3);
TargetNums      = unique(Targets_cluster(:, 4));
Targets         = [];
for tt = 1:length(TargetNums)
    ii = find(Targets_cluster(:, 4) == TargetNums(tt));
    Target = Targets_cluster(ii, 1:3);
    Targets = [Targets; mean(Target, 1)];
end

diff = [];
for tt = 1:length(TargetNums)
    diff = [diff norm(Targets(tt, :) - u1')];
end
[~, iindex] = min(diff);
iiindex = find(Targets_cluster(:, 4) == iindex);
iindex = [];
for ii = 1:length(iiindex)
    dTar = Targets_cluster(iiindex(ii), 1:3);
    dIndex = find(sum(results - dTar, 2) == 0);
    iindex = [iindex; index(dIndex, :)];
end

small_loop_numebr = 100;
results = [];
for ii = 1:size(iindex, 1)
    %%     对目标位置的导数
    % 方位角、仰角对目标位置的导数
    diff_theta_ui=zeros(2,3,N);
    diff_beta_ui=zeros(2,3,N);
    for j=1:1:N
        for i=1:1:2
            si_value=S(:, i);

            ui_si=u1-si_value;
            ai2=sqrt(ui_si(1)^2+ui_si(2)^2);
            %     方位角对目标位置的导数
            diff_theta_ui_1=-ui_si(2)/ai2^2;
            diff_theta_ui_2=ui_si(1)/ai2^2;
            diff_theta_ui(i,:,j)=[diff_theta_ui_1,diff_theta_ui_2,0];
            %     仰角对目标位置的导数
            diff_beta_ui_1=-ui_si(1)*ui_si(3)/ai2/(osjl(u1,si_value))^2;
            diff_beta_ui_2=-ui_si(2)*ui_si(3)/ai2/(osjl(u1,si_value))^2;
            diff_beta_ui_3=ai2/(osjl(u1,si_value))^2;
            diff_beta_ui(i,:,j)=[diff_beta_ui_1,diff_beta_ui_2,diff_beta_ui_3];
        end
    end
    F_u1=[diff_theta_ui(:,:,1);diff_beta_ui(:,:,1)];
    F_u=blkdiag(F_u1);
    
    deta_theta = 0.00000001;
    cov_z=deta_theta^2*eye(2*2);
    for tt = 1:small_loop_numebr
        theta = theta0(iindex(ii, :)) + deta_theta*randn(1,2);
        beta  = beta0(iindex(ii, :)) + deta_theta*randn(1,2);
        for i=1:1:2
            Ga1(i,:)=[cos(theta(i)),-sin(theta(i)),0];
            Ga2(i,:)=[sin(theta(i))*sin(beta(i)),cos(theta(i))*sin(beta(i)),-cos(beta(i))];
            si_value=S(:, iindex(ii, i));
            ha1(i,:)=si_value(1)*cos(theta(i))-si_value(2)*sin(theta(i));
            ha2(i,:)=si_value(1)*sin(theta(i))*sin(beta(i))+si_value(2)*cos(theta(i))*sin(beta(i))-si_value(3)*cos(beta(i));
        end
        
        Ga=[Ga1;Ga2];
        ha=[ha1;ha2];
        %% 初始阶段
        W1=inv(cov_z);
        u_uls=pinv(Ga)*ha;
        %%  ha对测量向量的导数
        A1=zeros(2,2);
        A21=zeros(2,2);
        A22=zeros(2,2);
        
        for i=1:1:2
            si_value=S(:, iindex(ii, i));
            A1(i,i)=-si_value(1)*sin(theta(i))-si_value(2)*cos(theta(i));
            A21(i,i)=si_value(1)*cos(theta(i))*sin(beta(i))-si_value(2)*sin(theta(i))*sin(beta(i));
            A22(i,i)=si_value(1)*sin(theta(i))*cos(beta(i))+si_value(2)*cos(theta(i))*cos(beta(i))+si_value(3)*sin(beta(i));
        end
        
        A=[A1,zeros(2,2);A21,A22];
        %%  Ga对测量值的导数
        B=zeros(2*2,2*2);
        
        for i=1:1:2
            B1=zeros(2,3);
            B21=zeros(2,3);
            B1(i,:)=[-sin(theta(i)),-cos(theta(i)),0;];
            B21(i,:)=[cos(theta(i))*sin(beta(i)),-sin(theta(i))*sin(beta(i)),0];
            B(:,i)=[B1;B21]*u_uls;
        end
        for i=1:1:2
            B22=zeros(2,3);
            B22(i,:)=[sin(theta(i))*cos(beta(i)),cos(theta(i))*cos(beta(i)),sin(beta(i))];
            B(:,i+2)=[zeros(2,3);B22]*u_uls;
        end
        C=A-B;
        W2=inv(C.'*cov_z*C);
        u_estimate=inv(Ga.'*W2*Ga)*Ga.'*W2*ha;
    end
    results = [results; u_estimate'];
end

Targets_cluster = DBSCAN(results, 5e2, 3);
TargetNums      = unique(Targets_cluster(:, 4));
Targets         = [];
for tt = 1:length(TargetNums)
    ii = find(Targets_cluster(:, 4) == TargetNums(tt));
    Target = Targets_cluster(ii, 1:3);
    Targets = [Targets; mean(Target, 1)];
end




function [distance]=osjl(object,source)
% 输入均为列向量
distance=sqrt(sum((object-source).^2));
end
