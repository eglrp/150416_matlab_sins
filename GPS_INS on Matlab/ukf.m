function [x,P]=ukf(fstate,Q,x,P,hmeas,z,R)
% UKF Unscented Kalman Filter for nonlinear dynamic systems
% [x, P] = ukf(f,x,P,h,z,Q,R) returns state estimate, x and state covariance, P
% for nonlinear dynamic system (for simplicity, noises are assumed as additive):
% x_k+1 = f(x_k) + w_k
% z_k = h(x_k) + v_k
% where w ~ N(0,Q) meaning w is gaussian noise with covariance Q
% v ~ N(0,R) meaning v is gaussian noise with covariance R
% Inputs: f: function handle for f(x)
% x: "a priori" state estimate
% P: "a priori" estimated state covariance
% h: fanction handle for h(x)
% z: current measurement
% Q: process noise covariance
% R: measurement noise covariance
% Output: x: "a posteriori" state estimate
% P: "a posteriori" state covariance
%
% By Yi Cao at Cranfield University, 04/01/2008
% Modified by JD Liu 2010-4-20


if nargin< 7
       L=numel(x); %numer of states
       alpha=1e-3; %default, tunable
       ki=0; %default, tunable
       beta=2; %default, tunable
       lambda=alpha^2*(L+ki)-L; %scaling factor
       c=L+lambda; %scaling factor
       Wm=[lambda/c 0.5/c+zeros(1,2*L)]; %weights for means
       Wc=Wm;
       Wc(1)=Wc(1)+(1-alpha^2+beta); %weights for covariance
       c=sqrt(c);
       X=sigmas(x,P,c); %sigma points around x
       [x1,X1,P1,X2]=ut(fstate,X,Wm,Wc,L,Q);
       x = x1;
       P = P1;
else
        L=numel(x); %numer of states
        m=numel(z); %numer of measurements
        alpha=1e-3; %default, tunable
        ki=0; %default, tunable
        beta=2; %default, tunable
        lambda=alpha^2*(L+ki)-L; %scaling factor
        c=L+lambda; %scaling factor
        Wm=[lambda/c 0.5/c+zeros(1,2*L)]; %weights for means
        Wc=Wm;
        Wc(1)=Wc(1)+(1-alpha^2+beta); %weights for covariance
        c=sqrt(c);
        X=sigmas(x,P,c); %sigma points around x
        [x1,X1,P1,X2]=ut(fstate,X,Wm,Wc,L,Q);
        % [x1,X1,P1,X2]=ut(fstate,X,Wm,Wc,L,Q); %unscented transformation of process
        % X1=sigmas(x1,P1,c); %sigma points around x1
        % X2=X1-x1(:,ones(1,size(X1,2))); %deviation of X1
        [z1,Z1,P2,Z2]=ut(hmeas,X1,Wm,Wc,m,R); %unscented transformation of measurments
        P12=X2*diag(Wc)*Z2'; %transformed cross-covariance
        K=P12*P2^-1;
        x=x1+K*(z-z1); %state update
        P=P1-K*P2*K'; %covariance update
end

