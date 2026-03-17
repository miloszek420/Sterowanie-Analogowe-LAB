function gvidm1t(x)

global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

Kp=x(1);
Tp=x(2);
T0=x(3)
pulse=2*pi*freq;

[n_t,d_t]=pade(T0,3);
n=Kp*n_t;
d=conv([Tp 1],d_t);


[m,p]=bode(n,d,pulse);

subplot(2,1,1)
semilogx(pulse,20*log10(Uout),'or','MarkerFace','r','MarkerSize',2)
hold
semilogx(pulse,20*log10(m),'b')
xlabel('\omega [rad/s]')
ylabel('|G(j\omega)|')
title(['K_p = ',num2str(K),'   T_p = ',num2str(T*1000), 'ms   T_0 =',num2str(T0*1e6),'\mus'])

subplot(2,1,2)
semilogx(pulse,Phase,'or','MarkerFace','r','MarkerSize',2)
hold
semilogx(pulse,p,'b')
xlabel('\omega [rad/s]')
ylabel('\Phi(\omega)')
legend('punkty pomiarowe','model zidentyfikowany')