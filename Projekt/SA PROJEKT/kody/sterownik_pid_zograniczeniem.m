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

t  = 0:1e-4:0.05;
dt = t(2)-t(1);

Umax = 5;
Td   = 0.001;

kappa_max = 30;
Ts_max    = 0.02;

Gp_ss = ss(Gp_delay);
Gt_ss = ss(Gt);

x0 = [0.05 0 0.00009];

options = optimset('Display','iter','TolX',1e-4,'TolFun',1e-4);

cost = @(x) pid_cost_nonlinear( ...
    x, Gp_ss, Gt_ss, t, dt, Umax, kappa_max, Ts_max);

x_opt = fminsearch(cost, x0, options);

kp = x_opt(1);
ki = x_opt(2);
kd = x_opt(3);

disp('==============================');
disp('PID STROJONY Z OGRANICZENIEM');
disp(['kp = ', num2str(kp)]);
disp(['ki = ', num2str(ki)]);
disp(['kd = ', num2str(kd)]);
disp('==============================');

r_step = ones(size(t));

[y, t_out] = simulate_pid_aw( ...
    kp, ki, kd, Gp_ss, Gt_ss, t, dt, Umax, r_step);

info = stepinfo(y, t_out);

y_ss = y(end);
[y_max, idx] = max(y);
t_max = t_out(idx);
ep = abs(1 - y_ss);

figure; hold on; grid on;
plot(t_out, y, 'b', 'LineWidth',1.8);

kp_ref = 0.0788;
ki_ref = 0.000375;
kd_ref = 0.00006975;

Gc_ref = kp_ref + ki_ref/s + (kd_ref*s)/(1 + Td*s);
Gcl_ref = feedback(Gc_ref*Gp_delay, Gt);

[y_ref, t_ref] = step(Gcl_ref, t_out);

plot(t_ref, y_ref, 'c', 'LineWidth',1.5);


yline(y_ss,'--k');
plot(t_max, y_max,'ro','LineWidth',2);

xline(info.SettlingTime,'--r');
text(info.SettlingTime,0.05,...
    sprintf('T_s = %.4f s',info.SettlingTime),...
    'Rotation',90,'Color','r');

text(t_max,y_max,...
    sprintf('\\kappa = %.2f %%',info.Overshoot),...
    'VerticalAlignment','bottom','HorizontalAlignment','right','Color','r');

text(t_max,y_max-0.04,...
    sprintf('e_p = %.4f',ep),...
    'VerticalAlignment','top','HorizontalAlignment','right','Color','r');

xlabel('Czas [s]');
ylabel('Wyjście');
title({ ...
    'Odpowiedź skokowa – PID z ograniczeniem (anti-windup)', ...
    sprintf('kp = %.4f,  ki = %.6f,  kd = %.6f', kp, ki, kd) ...
});
legend('PID z ograniczeniem','PID bez ograniczenia', 'Stan ustalony','Maksimum','T_s','Location','best');


a = 1;                
r_ramp = a * t_out;    

[y_ramp, ~] = simulate_pid_aw( ...
    kp, ki, kd, Gp_ss, Gt_ss, t_out, dt, Umax, r_ramp);

e_v = r_ramp(end) - y_ramp(end);

figure; hold on; grid on;
plot(t_out, r_ramp,'k--','LineWidth',1.5);
plot(t_out, y_ramp,'b','LineWidth',2);
plot(t_out(end),y_ramp(end),'ro','LineWidth',2);

text(t_out(end),y_ramp(end),...
    sprintf(' e_v = %.4f',e_v),...
    'VerticalAlignment','bottom','HorizontalAlignment','right','Color','r');

xlabel('Czas [s]');
ylabel('Sygnał');
title('Odpowiedź na rampę – PID z ograniczeniem');
legend('r(t)','y(t)','Uchyb e_v','Location','southeast');


Gc = kp + ki/s + (kd*s)/(1 + Td*s);
L = Gc * Gp_delay * Gt;


figure;
margin(L);

grid on;

title('Charakterystyka Bodego – PID z ograniczeniem');

function J = pid_cost_nonlinear( ...
    x, Gp_ss, Gt_ss, t, dt, Umax, kappa_max, Ts_max)

    kp = x(1); ki = x(2); kd = x(3);

    if any(x <= 0) || any(x > 100)
        J = 1e9; return
    end

    r = ones(size(t));

    [y, ~] = simulate_pid_aw( ...
        kp, ki, kd, Gp_ss, Gt_ss, t, dt, Umax, r);

    info = stepinfo(y, t);

    J = max(0, info.Overshoot-kappa_max)^2*1e3 + ...
        max(0, info.SettlingTime-Ts_max)^2*1e4;
end

function [y, t] = simulate_pid_aw( ...
    kp, ki, kd, Gp_ss, Gt_ss, t, dt, Umax, r)

    x_p = zeros(size(Gp_ss.A,1),1);
    x_t = zeros(size(Gt_ss.A,1),1);

    xi = 0;
    xi_max =  Umax/ki;
    xi_min = -Umax/ki;

    y = zeros(size(t));
    u = zeros(size(t));

    for k = 1:length(t)-1

        y(k) = Gp_ss.C*x_p + Gp_ss.D*u(k);
        y_meas = Gt_ss.C*x_t + Gt_ss.D*y(k);
        e = r(k) - y_meas;

        xi = xi + e*dt;
        xi = min(max(xi, xi_min), xi_max);

        if k == 1
            de = 0;
        else
            e_prev = r(k-1) - y(k-1);
            de = (e - e_prev)/dt;
        end

        u_pid = kp*e + ki*xi + kd*de;
        u(k+1) = min(max(u_pid,-Umax),Umax);

        x_p = x_p + dt*(Gp_ss.A*x_p + Gp_ss.B*u(k+1));
        x_t = x_t + dt*(Gt_ss.A*x_t + Gt_ss.B*y(k));
    end

    y(end) = y(end-1);
end

