function J=funm2(x)

% funkcja kosztów dla modelu obiektu G(s)=1/(1+a1*s+a2*s^2)
%
%  x=[x(1) x(2)] poszukiwane parametry,  gdzie: x(1)=a1, x(2)=a2


global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

a1=x(1);
a2=x(2);
pulse=2*pi*freq;
    
% model
ReG=(1-pulse.^2*a2)./((1-pulse.^2*a2).^2+pulse.^2*a1^2);
ImG=-a1*pulse./((1-pulse.^2*a2).^2+pulse.^2*a1^2);

% pomiar
ReGm=Uout.*cos(Phase.*pi./180);
ImGm=Uout.*sin(Phase.*pi./180);

J=sum(sqrt((ReG-ReGm).^2+(ImG-ImGm).^2)');