% clc
% clear
load label.mat

label = label / max(max(max(label)));
% A = xlsread('data1.xlsx','Sheet1','A2:E46');
% x = A(:,2);
% y = A(:,3);
% z = A(:,4);
% As = A(:,5);

% 定义插值网格
% [X,Y,Z] = meshgrid(0:0.25:30, 0:0.25:20, -30:0.25:0);
MaxRangeXYZ = [-1000 1000 -1000 1000 0 500];
RangePoints = [256 256 64];
minX = MaxRangeXYZ(1);
maxX = MaxRangeXYZ(2); RangePointsX = RangePoints(1);
minY = MaxRangeXYZ(3);
maxY = MaxRangeXYZ(4); RangePointsY = RangePoints(2);
minZ = MaxRangeXYZ(5);
maxZ = MaxRangeXYZ(6); RangePointsZ = RangePoints(3);

RangeX_Axis = linspace(minX, maxX, RangePointsX);
RangeY_Axis = linspace(minY, maxY, RangePointsY);
RangeZ_Axis = linspace(minZ, maxZ, RangePointsZ);
[X,Y,Z]     = meshgrid(RangeX_Axis, RangeY_Axis, RangeZ_Axis);

% 利用插值函数生成污染羽
% F = scatteredInterpolant(x, y, z, As, "linear", "linear");
% Vq = F(X, Y, Z);

% 显示特定范围
% Vq(Vq<=22) = NaN;

label(label<=0.00001) = NaN;

% 计算As的梯度
% [gx, gy, gz] = gradient(Vq, 0.1, 0.1, 0.1);

% 绘制污染羽和流线
figure(10011)
colormap("parula") % 设置颜色映射
h = slice(X, Y, Z, label, RangeX_Axis, RangeY_Axis, 0:0.1:1); % X和Y是反的
set(h, 'EdgeColor', 'none') % 隐藏内部边框
box on   % 打开边框
grid on  % 打开网格
colorbar
axis equal
xlabel('X')
ylabel('Y')
zlabel('Z')
alpha(0.25)

% 调整Z轴的视角
view(37, 20);

% 调整Z轴的整体比例
daspect([1 1 0.5]);

% 显示正面视角边框
ax = gca;
ax.BoxStyle = 'full';

% 设置边框线宽
set(gca, 'LineWidth', 0.5)