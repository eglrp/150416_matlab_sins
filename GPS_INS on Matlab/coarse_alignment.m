function [pitch, roll, yaw] = coarse_alignment(data, pos)
%%%�㷨�ο��������ߵ�ϵͳ�ֶ�׼�����Ƚϡ�-κ���ᣬ�ź�Խ-2000
    glvs
    Ts = 0.005;
%     pos = [40.067987*glv.deg; 116.247871*glv.deg; 43.53];
    [wnie, wnen, gn, retp] = earth(pos);
    %Lat = 40.0678524*pi/180;
    len = length(data);
    %wnie = glv.wie*[0; cos(Lat); sin(Lat)];
    gn = [0; 0; -retp.g];
    rn = askew(gn)*wnie;
    rrn = askew(rn)*gn;
    
    wbie_measum = [0; 0; 0];
    gb_measum = [0; 0; 0];
    for k=1:1:len
        [phim, dvbm] = cnscl(data(k, 6:8)', data(k, 3:5)');
        wbie_measum = wbie_measum+phim;
        gb_measum = gb_measum+dvbm;
    end
    wbie_mean = wbie_measum/len/Ts;
    gb_mean = -gb_measum/len/Ts;
    rb = askew(gb_mean)*wbie_mean;%-gb_meanΪgn�ڻ���ϵ�µķ���
    rrb = askew(rb)*gb_mean;
    
    cnb_align = ([gn'; rn'; rrn'])\([gb_mean'; rb'; rrb']);%����ʽ8��
    Cnb = cnb_align/(sqrtm(cnb_align'*cnb_align));%����ʽ7������������
    [pitch, roll, yaw] = DCMtoEuler(Cnb);
  