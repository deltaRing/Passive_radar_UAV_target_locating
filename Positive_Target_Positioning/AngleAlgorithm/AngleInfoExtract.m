% 估计角度信息
% 输入1：MUSIC / MVDR 估计出的角度谱
% 输入2：方位角度轴
% 输入3：俯仰角度轴
% 可选输入1：滤除比例值
function Angles = AngleInfoExtract(angleInfo, angleAzAxis, angleElAxis, ...
                    ratio, weight_enable)
    if nargin == 3
        ratio = 0.95;
        weight_enable = 1;
    end
    Angles = []; 
    % 首先估计最大值与最小值的区别
    maxValue  = max(max(abs(angleInfo)));
    meanValue = mean(mean(abs(angleInfo)));
    if meanValue * 1.25 >= maxValue, return; end % 没有合适的目标
    [index_x, index_y] = find(abs(angleInfo) > maxValue * ratio);
    
    TempAngles = [angleAzAxis(index_x); angleElAxis(index_y)];
    Values = [];
    for ii = 1:length(index_x), Values = [Values abs(angleInfo(index_x(ii), index_y(ii)))]; end
    % 先做聚类
    clustered_Angles = DBSCAN(TempAngles.');
    TypesNum         = unique(clustered_Angles(:, 3)); % 一共存在多少点
    % 质心法估计角度位置
    for ii = 1:length(TypesNum)
        Index      = find(clustered_Angles(:, 3) == TypesNum(ii));
        Weights    = Values(Index); % 权重
        Weights    = Weights / sum(Weights);
        tempangles = TempAngles(:, Index);
        if weight_enable
            angle  = tempangles * Weights';
        else
            angle  = tempangles;
        end
        Angles     = [Angles angle];
    end
end