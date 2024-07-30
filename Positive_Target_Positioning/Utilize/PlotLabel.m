% clc
% clear
load label.mat

label = label / max(max(max(label)));
% A = xlsread('data1.xlsx','Sheet1','A2:E46');
% x = A(:,2);
% y = A(:,3);
% z = A(:,4);
% As = A(:,5);

% �����ֵ����
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

% ���ò�ֵ����������Ⱦ��
% F = scatteredInterpolant(x, y, z, As, "linear", "linear");
% Vq = F(X, Y, Z);

% ��ʾ�ض���Χ
% Vq(Vq<=22) = NaN;

label(label<=0.00001) = NaN;

% ����As���ݶ�
% [gx, gy, gz] = gradient(Vq, 0.1, 0.1, 0.1);

% ������Ⱦ�������
figure(10011)
colormap("parula") % ������ɫӳ��
h = slice(X, Y, Z, label, RangeX_Axis, RangeY_Axis, 0:0.1:1); % X��Y�Ƿ���
set(h, 'EdgeColor', 'none') % �����ڲ��߿�
box on   % �򿪱߿�
grid on  % ������
colorbar
axis equal
xlabel('X')
ylabel('Y')
zlabel('Z')
alpha(0.25)

% ����Z����ӽ�
view(37, 20);

% ����Z����������
daspect([1 1 0.5]);

% ��ʾ�����ӽǱ߿�
ax = gca;
ax.BoxStyle = 'full';

% ���ñ߿��߿�
set(gca, 'LineWidth', 0.5)