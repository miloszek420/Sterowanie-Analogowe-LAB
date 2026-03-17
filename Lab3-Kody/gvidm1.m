function gvidm1(x)

global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

Kp=x(1);
Tp=x(2);
pulse=2*pi*freq;

[m,p]=bode([Kp],[Tp 1],pulse);

subplot(2,1,1)
semilogx(pulse,20*log10(Uout),'or','MarkerFace','r','MarkerSize',2)
hold
semilogx(pulse,20*log10(m),'b')
xlabel('\omega [rad/s]')
ylabel('M(omega) [dB]')
title(['K_p = ',num2str(K),'        T_p = ',num2str(T*1000), 'ms'])

subplot(2,1,2)
semilogx(pulse,Phase,'or','MarkerFace','r','MarkerSize',2)
hold
semilogx(pulse,p,'b')
xlabel('\omega [rad/s]')
ylabel('\Phi(\omega) [\circ]')
legend('punkty pomiarowe','model zidentyfikowany')