function [eb, web, db, wdb] = drift_bias(val)
% �������ݺͼӼƵ�����ֵƯ�����������ϵ��
% ���� --- һ��Ϊ4X3���󣬵�һ��Ϊ���ݳ�ֵƯ�ƣ��˵�λ0.01deg/hur
%                         �ڶ���Ϊ���ݽǶ�����ϵ�����˵�λ0.001deg/sqrt(hur)
%                         ������Ϊ�ӼƳ�ֵƯ�ƣ��˵�λ100ug
%                         ������Ϊ�Ӽ��ٶ�����ϵ�����˵�λ10ug/sqrt(Hz)
%           ���Ϊ4X1��������ÿ���������ĸ�����ֵ��ͬ���ٳ���������λ
%           ���Ϊ�����������������ֵ��ͬ���ٳ���������λ
% ��� ---
%     eb - ���ݳ�ֵƯ��    web - �����������ϵ��
%     db - �ӼƳ�ֵƯ��    wdb - �Ӽ��������ϵ��
    global glv
    if exist('val')==0
        val = 1;
    end
    [m, n] = size(val);
    if m == 1
        val = val*ones(4,1);
    end
    if n == 1
        val = repmat(val,1,3);
    end
    eb = val(1,:)'*0.5*glv.dph;
    web = val(2,:)'*0.08*glv.dpsh;
    db = val(3,:)'*800*glv.ug;
    wdb = val(4,:)'*35*glv.ugpsHz;