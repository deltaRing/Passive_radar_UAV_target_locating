% ��ʼ��Բ�����״�
% ����1��Pos ��������
% ����2��ID 
% ����3��M ���д�С
% ����4��r0 ���а뾶
% ����ѡ������5�� PosTx ��������λ��
% ����ѡ������6�� ������������
% ����ѡ������7�� ������������
% ����ѡ������8�� �״﷢�书��
% ����ѡ������9�� �״����� ��if 1 �����״� 2 ��Դ�״
function radar = RadarInitialize(Pos, id, M, r0, ...
                        PosTx, Gt, Gr, Pt, Type)
    if nargin == 4
        PosTx = Pos;
        Gt    = 10;
        Gr    = 1;
        Pt    = 1e5; % 1Kw
        Type  = 1; 
    end
    radar.Pos = Pos; % ��������λ��
    radar.PosTx = PosTx; % ��������λ��
    radar.id  = id;  % ID
    radar.M   = M;   % ���д�С
    radar.r0  = r0;  % Բ�뾶
    
    % ��������
    % �״﷽�� (RCS, lambda:����)
    if Type == 1
        % ����1��Ŀ��RCS ����2���źŲ��� ����3��Ŀ��λ��
        radar.Pr = @(RCS, lambda, TarPos) Pt * Gt * Gr * RCS * lambda^2 / ...
            ((4 * pi)^3 * norm(TarPos - Pos)^2 * norm(TarPos - PosTx)^2);
    else
        % ����1�����书�� ����2���źŲ��� ����3��Ŀ��λ��
        radar.Pr = @(Pr, lambda, TarPos) Pr * Gr * lambda^2 / ...
            ((4 * pi)^2 * norm(TarPos - Pos)^2);
    end
end