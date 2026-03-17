function J=funmnf(x)

% funkcja kosztów dla modelu obiektu G(s)=(1-s*Tx)/(1+s*Ty)
%
%  x=[x(1) x(2)] poszukiwane parametry,  gdzie: x(1)=Tx, x(2)=Ty


global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

Tx=x(1);
Ty=x(2);
pulse=2*pi*freq;
    
% model
ReG=(1-pulse.^2*Tx*Ty)./(1+pulse.^2*Ty^2);
ImG=-pulse.*(Ty+Tx)./(1+pulse.^2*Ty^2);

% pomiar
ReGm=Uout.*cos(Phase.*pi./180);
ImGm=Uout.*sin(Phase.*pi./180);

J=sum(sqrt((ReG-ReGm).^2+(ImG-ImGm).^2)');