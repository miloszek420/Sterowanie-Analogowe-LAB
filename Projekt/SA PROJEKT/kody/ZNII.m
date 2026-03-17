clear; clc; close all;
s = tf('s');

Kp_obj = 1.42;
Tp = 1.25e-3;
Ti_obj = 0.68e-3;
a1 = 6.89e-4;
a2 = 2.54e-7;
T0 = 0.14e-3;

Gp = Kp_obj / ((s*Ti_obj)*(1 + s*Tp)*(1 + s*a1 + s^2*a2));
Gt = 1/(1 + 0.2*s*Tp);
Gp_delay = Gp * exp(-4*T0*s);

Kp_P = 0.1103;
G_cl_P = feedback(Kp_P * Gp_delay * Gt, 1);

Kp = 0.222;
Ki = 42.5;
Kd = 0.0002873;
PID = Kp + Ki/s + Kd*s;
G_cl_PID = feedback(PID * Gp_delay * Gt, 1);

t = 0:1e-5:0.05;
[y_P, t]   = step(G_cl_P, t);
[y_PID, ~] = step(G_cl_PID, t);

y_ss = 1;                       
y_inf = y_PID(end);             
[y_max, idx] = max(y_PID);
t_max = t(idx);

kappa = (y_max - y_ss) * 100;   
ep = abs(y_ss - y_inf);         

info = stepinfo(y_PID, t);

figure; hold on; grid on;

plot(t, y_P,  'c', 'LineWidth', 1.5);
plot(t, y_PID,'b', 'LineWidth', 1.8);

yline(1,'--k');
plot(t_max, y_max,'ro','LineWidth',1.5);
xline(info.SettlingTime,'--r');

text(t_max, y_max+0.05, ...
    sprintf('\\kappa = %.2f %%', kappa), ...
    'Color','r','FontWeight','bold');

text(t(end)-0.01, y_inf-0.05, ...
    sprintf('e_p = %.3f', ep), ...
    'Color','r','FontWeight','bold');

text(info.SettlingTime, 0.1, ...
    sprintf('T_s = %.4f s', info.SettlingTime), ...
    'Rotation',90,'Color','r');

xlabel('Czas [s]');
ylabel('Wyjście');
title('Odpowiedź skokowa – regulator PID (II metoda ZN)');
legend('Sterownik P','Odpowiedź PID','Stan ustalony','Maksimum','T_s', ...
       'Location','best');

Kp = 0.222;
Ki = 42.5;
Kd = 0.0002873;

PID = Kp + Ki/s + Kd*s;

G_open = PID * Gp_delay * Gt;
G_cl = feedback(G_open, 1);

t = 0:1e-5:0.1;
r = t;                   

y = lsim(G_cl, r, t);

ev = r(end) - y(end);

figure;
plot(t, r, 'k--', 'LineWidth', 1.2); hold on;
plot(t, y, 'b', 'LineWidth', 1.5);
plot(t(end), y(end), 'ro', 'LineWidth', 1.5);

grid on;
xlabel('Czas [s]');
ylabel('Sygnał');
title('Uchyb ustalony e_v dla pobudzenia rampowego – PID (II metoda ZN)');

legend('Rampa r(t)', 'Wyjście y(t)', 'Uchyb e_v', 'Location', 'southeast');

text(0.75*t(end), y(end), ...
    sprintf('e_v = %.4f', ev), ...
    'Color','r','FontWeight','bold');


G_open_PID = PID * Gp_delay * Gt;


figure;
margin(G_open_PID);
grid on;

title('Charakterystyki Bodego – regulator PID (II metoda ZN)');

