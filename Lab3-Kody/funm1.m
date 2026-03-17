function J=funm1(x)

% funkcja kosztów dla modelu obiektu G(s)=Kp/(1+sTp)
%
%  x=[x(1) x(2)] poszukiwane parametry,  gdzie: x(1)=Kp, x(2)=Tp


global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

Kp=x(1);
Tp=x(2);
pulse=2*pi*freq;
    
% model
ReG=Kp./(1+pulse.^2*Tp^2);
ImG=-Kp*pulse*Tp./(1+pulse.^2*Tp^2);

% pomiar
ReGm=Uout.*cos(Phase.*pi./180);
ImGm=Uout.*sin(Phase.*pi./180);

J=sum(sqrt((ReG-ReGm).^2+(ImG-ImGm).^2)');