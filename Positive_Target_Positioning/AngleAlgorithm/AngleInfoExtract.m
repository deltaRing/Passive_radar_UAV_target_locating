% ���ƽǶ���Ϣ
% ����1��MUSIC / MVDR ���Ƴ��ĽǶ���
% ����2����λ�Ƕ���
% ����3�������Ƕ���
% ��ѡ����1���˳�����ֵ
function Angles = AngleInfoExtract(angleInfo, angleAzAxis, angleElAxis, ...
                    ratio, weight_enable)
    if nargin == 3
        ratio = 0.95;
        weight_enable = 0;
    end
    Angles = []; 
    % ���ȹ������ֵ����Сֵ������
    maxValue  = max(max(abs(angleInfo)));
    meanValue = mean(mean(abs(angleInfo)));
    if meanValue * 1.25 >= maxValue, return; end % û�к��ʵ�Ŀ��
    [index_x, index_y] = find(abs(angleInfo) > maxValue * ratio);
    
    TempAngles = [angleAzAxis(index_x); angleElAxis(index_y)];
    Values = [];
    for ii = 1:length(index_x), Values = [Values abs(angleInfo(index_x(ii), index_y(ii)))]; end
    % ��������
    clustered_Angles = DBSCAN(TempAngles.');
    TypesNum         = unique(clustered_Angles(:, 3)); % һ�����ڶ��ٵ�
    % ���ķ����ƽǶ�λ��
    for ii = 1:length(TypesNum)
        Index      = find(clustered_Angles(:, 3) == TypesNum(ii));
        Weights    = Values(Index); % Ȩ��
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