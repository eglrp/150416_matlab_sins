function [y,Y,P,Y1] = ut(f,X,Wm,Wc,n,R)
    L=size(X,2);%sigma��ĸ���--��2n+1
    y=zeros(n,1);%ϵͳ�������߹۲�����ĳ�ʼ��
    Y=zeros(n,L);%sigma��һ��Ԥ��ĳ�ʼ��
    for k=1:L
%         Y(:,k)=f(X(:,k),kx,ky,g,Ts);%sigma����߹۲�����һ��Ԥ��
        Y(:,k) = f(X(:,k));
        y=y+Wm(k)*Y(:,k);%sigma����߹۲�������ƽ��
    end
    Y1=Y-y(:,ones(1,L));%һ��Ԥ�����ʵֵ���������
    P=Y1*diag(Wc)*Y1'+R;%ϵͳ����Э�����һ��Ԥ��


    