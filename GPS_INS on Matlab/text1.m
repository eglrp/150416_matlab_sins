tic;
clear all
clc
glvs
Ts = 0.005;                                                 %IMU数据输出周期
imu0 = load('data\RAWIMU.txt');
veli = load('data\BESTVEL.txt');
posi = load('data\BESTPOS.txt');
pos0 = [40.067987*glv.deg; 116.247871*glv.deg; 43.53];  %初始位置
vn0 = [0; 0; 0];                                        %1:47000车辆处于停车状态
[pitch, roll, yaw] = coarse_alignment(imu0(1:47000, :), pos0);%解析粗对准
att0 = [pitch; roll; yaw];                              %初始姿态
cnb0 = a2cnb(att0);
qnb0 = m2qnb(cnb0);                                     %初始姿态四元数
qnb = qnb0; vn = vn0; pos = pos0;
n = 1;                                                      %n子样数
Ts = n*Ts;                                                  %计算周期
dpos = [1./glv.Re; 1./glv.Re; 0.3];                         %位置观测噪声
dv = [.5; .5; .1];                                          %速度观测噪声
[eb, web, db, wdb] = drift_bias([1;1;1;1]);                 %惯性器件零偏和随机漂移

%%%%%%%%%%%%%滤波器参数设置——选取依据为滤波理论知识和实际工程条件%%%%%%%%%%%%%%%
Qt = diag([web; wdb; repmat(0.01, 3, 1); 0.1*web; 0.1*wdb])^2;
Rk = diag([dv; dpos])^2;
Pk = diag([[6.;6.;18.]*glv.deg; [.2; .2; .1]; [5./glv.Re;...
    5./glv.Re; 2.]; [2.; 2.; 2.]*glv.dph; ...
    [3.; 3.; 3.]*glv.mg])^2;
Xk = [[2.;2.;10.]*glv.deg; [.3; .3; .1]; ...
    [5./glv.Re; 5./glv.Re; 1.]; [.7; .7; .7]*glv.dph;...
    [1.; 1.; 1.]*glv.mg];
Hk = [zeros(6, 3), eye(6), zeros(6,6)];
len = 252760;
lenp = 1020;
Xkk = zeros(lenp, length(Xk));                              %滤波状态存储
Zk_kf = zeros(lenp, 6);                                 %观测量存储，即速度和位置误差
navigation = zeros(len, 9);                                 %导航参数存储
kv = 1;                                                  %与此计算中的IMU数据对齐
kk = 1;
kerr = 1;
for k = 47000:n:299750                                    %10.5公里行车距离，20分钟
    k1 = k+n-1;                                             %行车时间
   wm = imu0(k:k1,6:8)';
   vm = imu0(k:k1,3:5)';
   [qnb, vn, pos] = sinss(qnb, vn, pos, wm, vm, Ts);
   cnb = q2cnb(qnb);
   [x, y, z] = DCMtoEuler(cnb);
   att = [x; y; z];
   navigation(kk,:) = [att'./glv.deg, vn', pos(1:2,1)'/glv.deg, pos(3,1)];
   wm = sum(wm,2);                                          %与采用的子样数对应
   vm = sum(vm,2);                                          %getfs要求计算周期内的增量
   Ft = getfs(qnb, vn, pos, vm./Ts, 15);                    %线性系统系数矩阵
   [Fikk_1, Qk] = kfdis(Ft, Qt, Ts, 4);                     %状态一步转移矩阵
   for j = k:1:k1
       if imu0(j, 2)==veli(kv, 2)                           %在GPS采样点进行补偿        
           vi = veli(kv, 3:5)';
           pi = [posi(kv, 3:4)'*glv.deg; posi(kv, 5)];
           Zk = [vn-vi; pos-pi];                            %构造观测量
           Zk_kf(kerr, :) = Zk';
           [Xk, Pk, Kk] = kalman(Fikk_1, Qk, Xk, Pk, Hk, Rk, Zk);
           Xkk(kerr, :) = Xk';
           vn = vn-Xk(4:6, 1);                              %形成闭环修正
           pos = pos-Xk(7:9, 1);                            %闭环修正
           pos(3) = posi(kv, 5);                            %抑制高度通道发散
           xk(9)=0;                                         %抑制高度通道发散
           kv = kv+1;
           kerr = kerr+1;
       else
           [Xk, Pk] = kalman(Fikk_1, Qk, Xk, Pk);           %无观测量时只进行预测
       end
   end
   timedisp(kk, Ts, 100);                                   %显示进度
   kk = kk+1;
end

save navigation_kalman navigation
save Xkk_kf Xkk
save Zk_kf Zk_kf

figure,             %画出组合导航轨迹
plot(navigation(1:kk-1,8), navigation(1:kk-1,7), '-'), grid on
xlabel('\it\lambda\rm / \circ'); ylabel('\itLatitude\rm / \circ'); 

figure,             %画出俯仰误差角曲线
plot(Xkk(1:kerr-1,1)/glv.deg, '-b'), grid on
xlabel('\itt/s'); ylabel('\it\theta\rm / \circ'); grid on

figure,             %画出俯横滚差角曲线
plot(Xkk(1:kerr-1,2)/glv.deg, '-b'), grid on
xlabel('\itt/s'); ylabel('\it\gamma\rm / \circ');

figure,             %画出俯方位差角曲线
plot(Xkk(1:kerr-1,3)/glv.deg, '-b'), grid on
xlabel('\itt/s'); ylabel('\it\psi\rm / \circ');

figure,             %画出东北向速度误差
subplot(2,1,1), plot(Zk_kalman(1:kerr-1,1)), grid on
xlabel('\itt/s'); ylabel('\it\delta Ve\rm /m/s'); 
subplot(2,1,2), plot(Zk_kalman(1:kerr-1,2)), grid on
xlabel('\itt/s'); ylabel('\it\delta Vn\rm /m/s'); 

figure,             %画出纬度、经度误差
subplot(2,1,1), plot(Zk_kalman(1:kerr-1,4)*glv.Re), grid on
xlabel('\itt/s'); ylabel('\it\delta Latitude\rm /m'); 
subplot(2,1,2), plot(Zk_kalman(1:kerr-1,5)*glv.Re), grid on
xlabel('\itt/s'); ylabel('\it\delta lambda\rm /m'); 

toc
