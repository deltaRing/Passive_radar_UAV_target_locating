% ��ʼ��Ŀ��
% ����1��Pos
% ����2��Vel
% ����3��id
% ��ѡ����1��Ŀ��RCS
% ��ѡ����2��Ŀ�귢��Ĺ���
% ��ѡ����3����λʱ��
function target = TargetInitialize(Pos, Vel, id, RCS, Pr, t)
    if nargin == 3
        RCS = 10;   % 1 m2
        Pr  = 10;  % 10w ����
        t   = 0.1; % ��λ����ʱ��
    end

    target.Pos = Pos; % Ŀ���ʼλ��
    target.Vel = Vel; % Ŀ���ٶ�
    target.id  = id;  % Ŀ��ID
    target.RCS = RCS; % Ŀ��RCS
    target.Pr  = Pr;  % Ŀ�귢���źŵĹ���
    
    target.F   = [1 t 0 0 0 0;
                  0 1 0 0 0 0;
                  0 0 1 t 0 0;
                  0 0 0 1 0 0;
                  0 0 0 0 1 t;
                  0 0 0 0 0 1]; % ״̬ת�Ʒ���
    target.InitX   = [Pos(1) Vel(1) Pos(2) Vel(2) Pos(3) Vel(3)]; % Ŀ��״̬
    target.X   = @(dt) [target.InitX(1) + Vel(1) * dt Vel(1) ...
                            target.InitX(3) + Vel(2) * dt Vel(2) ...
                            target.InitX(5) + Vel(3) * dt Vel(3)];
end