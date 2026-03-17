function gvidm2(x)

global DATA_M

freq=DATA_M(:,1);
Uout=DATA_M(:,2);
Phase=DATA_M(:,3);

a1=x(1);
a2=x(2);
pulse=2*pi*freq;

[m,p]=bode([1],[a2 a1 1],pulse);

subplot(2,1,1)
semilogx(pulse,20*log10(Uout),'or','MarkerFace','r','MarkerSize',2)
hold
semilogx(pulse,20*log10(m),'b')
xlabel('\omega [rad/s]')
ylabel('|G(j\omega)|')
title(['a_1 = ',num2str(a1), '       a_2 = ',num2str(a2)])

subplot(2,1,2)
semilogx(pulse,Phase,'or','MarkerFace','r','MarkerSize',2)
hold
semilogx(pulse,p,'b')
xlabel('\omega [rad/s]')
ylabel('\Phi(\omega)')

legend('punkty pomiarowe','model zidentyfikowany')