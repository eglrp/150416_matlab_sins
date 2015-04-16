% function glvs
%ȫ�ֱ���
    global glv
    glv.Re = 6378137;               %����뾶(GPS-84)
    glv.f = 1/298.257;              %�������
    glv.Rp = (1-glv.f)*glv.Re;      %������Բ�ȵ��������β���
    glv.e = sqrt(2*glv.f-glv.f^2); glv.e2 = glv.e^2;%ƫ����
    glv.ep = sqrt(glv.Re^2+glv.Rp^2)/glv.Rp;	glv.ep2 = glv.ep^2;
    glv.wie = 7.2921151467e-5;      %������ת������
    glv.meru = glv.wie/1000;        %����ת��
    glv.g0 = 9.7803267714;          %�������ٶ�
    glv.mg = 1.0e-3*glv.g0;         %���������ٶ�
    glv.ug = 1.0e-6*glv.g0;         %΢�������ٶ�
    glv.ugpg2 = glv.ug/glv.g0^2;    %�ӱ������ϵ��
    glv.ppm = 1.0e-6;               %�����֮һ
    glv.deg = pi/180;               %�Ƕ�
    glv.min = glv.deg/60;           %�Ƿ�
    glv.sec = glv.min/60;           %����
    glv.hur = 3600;                 %Сʱ
    glv.dps = pi/180/1;             %��/��
    glv.dph = glv.deg/glv.hur;      %��/Сʱ
    glv.dpss = pi/180/sqrt(1);          %��/sqrt(��)
    glv.dpsh = glv.deg/sqrt(glv.hur);   %��/sqrt(Сʱ), �Ƕ��������ϵ��
    glv.Hz = 1/1;                   %����(1/s)
    glv.ugpsHz = glv.ug/sqrt(glv.Hz);    %ug/sqrt(Hz), �ٶ��������ϵ��
    glv.mil = 2*pi/6000;            %��λ
    glv.nm = 1853;                  %����
    glv.kn = glv.nm/glv.hur;        %��
    glv.cs = [                      %Բ׶�ͻ�������ϵ��
        2./3,       0,          0,          0
        9./20,      27./20,     0,          0
        54./105,    92./105,    214./105,    0
        250./504,   525./504,   650./504,   1375./504 ];

