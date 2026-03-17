function J=funm1t(x)

% funkcja kosztów dla modelu obiektu G(s)=K/(1+sT)*exp(-sTo)
%
%  x=[x(1) x(2) x(3)] poszukiwane parametry,  gdzie: x(1)=K, x(2)=T, x(3)=To


global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

K=x(1);
T=x(2);
To=x(3);
pulse=2*pi*freq;
    
% model
ReG=(K*(cos(To*pulse)-T*pulse.*sin(To*pulse)))./(1+pulse.^2*T^2);
ImG=-(K*(T*pulse.*cos(To*pulse)+sin(To*pulse)))./(1+pulse.^2*T^2);

% pomiar
ReGm=Uout.*cos(Phase.*pi./180);
ImGm=Uout.*sin(Phase.*pi./180);

J=sum(sqrt((ReG-ReGm).^2+(ImG-ImGm).^2)');