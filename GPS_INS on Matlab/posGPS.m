clc
clear
pos = load('data\BESTPOS.txt');
vel = load('data\BESTVEL.txt');
% plot(vel(:,3))
% len = length(pos);
% plot(pos(1000:1257,4), pos(1000:1257,3),'-');
% ���ɵ�һ�׶��ܳ�·��
figure, plot(pos(1:1262,4), pos(1:1262,3)), grid on
xlabel('\it\lambda\rm / \circ'); ylabel('\itLatitude\rm / \circ');

% ���ɵڶ��׶��ܳ�·��
figure, plot(pos(2035:3346,4), pos(2035:3346,3)), grid on

