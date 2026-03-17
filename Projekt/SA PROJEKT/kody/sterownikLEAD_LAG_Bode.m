
clear; close all; clc;

s = tf('s');

a1p = -7.274253e-01;
a0p = 1.378812e+03;
b2p = 7.384625e-07;
b1p = 1.296655e-03;
b0p = 6.605551e-01;

Gp =(a1p*s + a0p) / ( s*(b2p*s^2 + b1p*s + b0p) );

%regulator P
Kp = 0.1103;
Go_P = Kp * Gp;
Gcl_P = feedback(Go_P, 1);

%regulator P
[GM_P, PM_P, Wcg_P, Wcp_P] = margin(Go_P);


% LEAD – poprawa zapasu fazy
% OPTYMALNE NASTAWY LEAD-LAG:
z1 = 125.39
p1 = 1816.2536
z2 = 0.68609
p2 = 95.5291
kc = 1.0387

Gc = kc * ...
     (s + z1)/(s + p1) * (s + z2)/(s + p2);

Go_LL = Gc * Gp;
Gcl_LL = feedback(Go_LL, 1);


[GM_LL, PM_LL, Wcg_LL, Wcp_LL] = margin(Go_LL);

%Bode
figure;
margin(Go_P); hold on;
margin(Go_LL);
grid on;
title('Charakterystyki Bodego układu otwartego');
legend('Układ otwarty – regulator P', ...
       'Układ otwarty – regulator LEAD-LAG');

Kpos_P  = dcgain(Go_P);
Kpos_LL = dcgain(Go_LL);

disp('--- Wzmocnienie statyczne ---');
disp(['Kp (P):        ', num2str(Kpos_P)]);
disp(['Kp (LEAD-LAG): ', num2str(Kpos_LL)]);


%Wyniki liczbowe
disp('--- Zapasy stabilności ---');
disp(['PM P        = ', num2str(PM_P),  ' deg']);
disp(['PM LEAD-LAG = ', num2str(PM_LL), ' deg']);
disp(['GM P        = ', num2str(20*log10(GM_P)),  ' dB']);
disp(['GM LEAD-LAG = ', num2str(20*log10(GM_LL)), ' dB']);

disp('--- Odpowiedź skokowa ---');
disp(['Overshoot P        = ', num2str(info_P.Overshoot),  ' %']);
disp(['Overshoot LEAD-LAG = ', num2str(info_LL.Overshoot), ' %']);
disp(['Ts P        = ', num2str(info_P.SettlingTime),  ' s']);
disp(['Ts LEAD-LAG = ', num2str(info_LL.SettlingTime), ' s']);
