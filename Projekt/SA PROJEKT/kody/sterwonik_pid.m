clear; clc; close all;

s = tf('s');

Kp = 1.42;
Tp = 1.25e-3;
Ti = 0.68e-3;
a1 = 6.89e-4;
a2 = 2.54e-7;
T0 = 0.14e-3;

Gp = Kp / ((s*Ti)*(1 + s*Tp)*(1 + s*a1 + s^2*a2));
Gt = 1/(1 + 0.2*s*Tp);

Gp_delay = Gp * exp(-4*T0*s);

kappa_max = 30;
Ts_max    = 0.02;

Td = 0.001;
t = 0:1e-4:0.05;

cost = @(x) ...
    local_cost(x, s, Gp_delay, Gt, Td, kappa_max, Ts_max, t);

x0 = [0.05 0 0.00009];

options = optimset('Display','iter','TolX',1e-4,'TolFun',1e-4);
x_opt = fminsearch(cost, x0, options);

kp_opt = x_opt(1);
ki_opt = x_opt(2);
kd_opt = x_opt(3);

disp('==============================');
disp('OPTYMALNE NASTAWY PID:');
disp(['kp = ', num2str(kp_opt)]);
disp(['ki = ', num2str(ki_opt)]);
disp(['kd = ', num2str(kd_opt)]);
disp('==============================');

Gc = kp_opt + ki_opt/s + (kd_opt*s)/(1 + Td*s);
Gcl = feedback(Gc*Gp_delay, Gt);

[y, t_out] = step(Gcl, t);
info = stepinfo(y, t_out, 'RiseTimeLimits',[0.1 0.9]);

y_ss = y(end);
[y_max, idx_max] = max(y);
t_max = t_out(idx_max);

ep = abs(1 - y_ss) 

info = stepinfo(Gcl, 'RiseTimeLimits',[0.1 0.9]);

disp(['Ts = ', num2str(info.SettlingTime)]);
disp(['kappa = ', num2str(info.Overshoot), ' %']);

STERP = feedback(0.1103*Gp_delay, Gt);
t = 0:1e-5:0.05; 
[y_p, t] = step(STERP, t);

figure; hold on; grid on;


plot(t, y_p, 'c', 'LineWidth', 1.5)
plot(t_out, y, 'b', 'LineWidth', 1.5);

yline(y_ss, '--k');


xline(info.SettlingTime, '--r');
text(info.SettlingTime, 0.05, ...
    sprintf('T_s = %.4f s', info.SettlingTime), ...
    'Rotation',90,'VerticalAlignment','bottom','Color','r');

plot(t_out(end), y_ss, 'rx', 'MarkerSize', 8, 'LineWidth', 2);
plot(t_max, y_max, 'ro', 'MarkerSize', 8, 'LineWidth', 2);


dy = 0.03; 

text(t_max, y_max, ...
    sprintf('\\kappa = %.5f %%', info.Overshoot), ...
    'VerticalAlignment','bottom','HorizontalAlignment','right','Color','r');

text(t_max, y_max - dy, ...
    sprintf(' e_p = %.4f', ep), ...
    'VerticalAlignment','top','HorizontalAlignment','right','Color','r');

xlabel('Czas [s]');
ylabel('Wyjście');
title({ ...
    'Odpowiedź skokowa – regulator PID', ...
    sprintf('kp = %.4f,  ki = %.6f,  kd = %.8f', kp_opt, ki_opt, kd_opt) ...
});
legend('Sterwonik P','Odpowiedź PID','Stan ustalony','Maksimum','T_s','Uchyb', ...
       'Location','best');


r = t;

[y_pid, t_out] = lsim(Gcl, r, t);

e_pid = r - y_pid;
ep = e_pid(end);

figure;
plot(t, r, 'k--', 'LineWidth', 1.5); hold on;
plot(t_out, y_pid, 'b', 'LineWidth', 2);

plot(t_out(end), y_pid(end), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
text(t_out(end), y_pid(end), ...
    sprintf(' e_v = %.4f', ep), ...
    'VerticalAlignment','bottom', ...
    'HorizontalAlignment','right', ...
    'Color','r');

grid on;
xlabel('Czas [s]');
ylabel('Sygnał');
title('Uchyb ustalony e_v dla pobudzenia rampowego – regulator PID');

legend('Rampa r(t)', 'Wyjście y(t)', 'Uchyb e_v', 'Location','southeast');


Gc_pid = kp_opt + ki_opt/s + (kd_opt*s)/(1 + Td*s);

L_pid = Gc_pid * Gp_delay * Gt;


margin(L_pid);

grid on;

title('Charakterystyka Bodego – regulator PID');

function J = local_cost(x, s, Gp_delay, Gt, Td, kappa_max, Ts_max, t)

    kp = x(1); ki = x(2); kd = x(3);

    if any(x < 0) || any(x > 1e4)
        J = 1e9;
        return
    end

    Gc = kp + ki/s + (kd*s)/(1 + Td*s);
    Gcl = feedback(Gc*Gp_delay, Gt);

    try
        [y, ~] = step(Gcl, t);
        info = stepinfo(y, t);
    catch
        J = 1e9;
        return
    end

    if any(isnan(y)) || any(isinf(y)) || max(abs(y)) > 10
        J = 1e8;
        return
    end

    J = 0;

    J = J + max(0, info.Overshoot - kappa_max)^2 * 1e3;
    J = J + max(0, info.SettlingTime - Ts_max)^2 * 1e4;

end

