clear; clc; close all;
s = tf('s');

Kp = 1.42;
Tp = 1.25e-3;
Ti = 0.68e-3;
a1 = 6.89e-4;
a2 = 2.54e-7;
T0 = 0.14e-3;

Gp = Kp / ((s*Ti) * (1 + s*Tp) * (1 + s*a1 + s^2*a2));
Gt = 1/(1 + s*0.2*Tp);

Gp_delay = Gp * exp(-4*T0*s);

G = feedback(Gp_delay, Gt);

t = 0:1e-5:0.05;
[y, t] = step(G, t);
figure;
plot(t, y, 'b', 'LineWidth', 2); hold on; grid on;
yline(1, '--k');
xlabel('Czas [s]');
ylabel('Wyjście');
title('Odpowiedź skokowa układu zamkniętego');
legend('Odpowiedź','Sygnał zadany','Location','best');

kappa_max = 30;   
Ts_max = 0.02;    

kp_vec = linspace(0.01, 5, 200);

Ts_vec = nan(size(kp_vec));
kappa_vec = nan(size(kp_vec));
stable_vec = false(size(kp_vec));

for i = 1:length(kp_vec)

    kp = kp_vec(i);
    Gc = kp;

    G_open = Gc * Gp_delay;
    G_cl = feedback(G_open, Gt);

    try
        info = stepinfo(G_cl);
        Ts = info.SettlingTime;
        kappa = info.Overshoot;

        if ~isnan(Ts) && Ts > 0 && kappa < 200
            Ts_vec(i) = Ts;
            kappa_vec(i) = kappa;
            stable_vec(i) = true;
        end
    catch
        stable_vec(i) = false;
    end
end

valid = stable_vec & (kappa_vec <= kappa_max) & (Ts_vec <= Ts_max);

if any(valid)
    valid_kp = kp_vec(valid);
    valid_Ts = Ts_vec(valid);

    [~, idx] = min(valid_Ts);
    kp_best = valid_kp(idx);
else
    error('Brak wzmocnienia kp spełniającego wymagania projektowe');
end

disp(['Wybrane wzmocnienie kp = ', num2str(kp_best)])

Gc = kp_best;
G_ref = feedback(Gc * Gp_delay, Gt);


t = 0:1e-5:0.1;
[y, t] = step(G_ref, t);

info = stepinfo(y, t);

y_ss = y(end);           
y_max = max(y);          
Ts = info.SettlingTime;   
kappa = info.Overshoot;   

ep = abs(1 - y_ss);

disp(['Uchyb ustalony dla skoku e_p = ', num2str(ep)])


figure;
plot(t, y, 'LineWidth', 1.5); hold on; grid on;

yline(y_ss, '--k', 'Stan ustalony');
plot(t(y == y_max), y_max, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
xline(Ts, '--r', 'T_s');

t_ep = t(end)-0.02;

plot(t_ep, y_ss, 'rx', 'MarkerSize',8, 'LineWidth',2);

xlabel('Czas [s]');
ylabel('Wyjście');
title(['Odpowiedź skokowa – regulator P, kp = ', num2str(kp_best)]);
legend('Odpowiedź', 'Stan ustalony', 'Maksimum', 'T_s', 'uchyb');

text(Ts*1.02, y_ss*0.95, ...
    sprintf('T_s = %.4f s', Ts), ...
    'Color','r','FontSize',10);

text(t(y == y_max)*0.9, y_max*1.03, ...
    sprintf('\\kappa = %.1f %%', kappa), ...
    'Color','r','FontSize',10,'HorizontalAlignment','right');

text(t_ep*0.85, (1+y_ss)/2, ...
    sprintf('e_p = %.4f', ep), ...
    'Color','r', ...
    'FontSize',10);


figure;
yyaxis left
plot(kp_vec, Ts_vec,'x-b','LineWidth',1.5)
ylabel('Czas ustalania T_s [s]')

yyaxis right
plot(kp_vec, kappa_vec,'x-r','LineWidth',1.5)
ylabel('Przeregulowanie \kappa [%]')

ax = gca;
ax.YAxis(1).Color = 'b';
ax.YAxis(2).Color = 'r';

xlabel('Wzmocnienie k_p')
title('Wpływ wzmocnienia regulatora P na parametry odpowiedzi')
grid on;



t_ramp = 0:1e-5:0.1;
r = t_ramp; 

[y_ramp, t_ramp] = lsim(G_ref, r, t_ramp);

ev = abs(r(end) - y_ramp(end));
disp(['Uchyb ustalony dla rampy e_v = ', num2str(ev)])

figure;
plot(t_ramp, r,'k--','LineWidth',1.5); hold on;
plot(t_ramp, y_ramp,'b','LineWidth',2);
grid on;

plot(t_ramp(end), y_ramp(end),'ro','MarkerSize',8,'LineWidth',2);
line([t_ramp(end) t_ramp(end)], ...
     [y_ramp(end) r(end)], ...
     'Color','r','LineWidth',2);

xlabel('Czas [s]');
ylabel('Sygnał');
title('Uchyb ustalony e_v dla pobudzenia rampowego');
legend('Rampa r(t)','Wyjście y(t)','Uchyb e_v','Location','best');

text(t_ramp(end)*0.8,(r(end)+y_ramp(end))/2, ...
    sprintf('e_v = %.4f', ev), ...
    'Color','r','FontSize',11,'FontWeight','bold');


G_ol = Gc * Gp_delay * Gt;

[GM, PM, Wcg, Wcp] = margin(G_ol);

Delta_g = 20*log10(GM);
Delta_p = PM;            

disp(['Zapas fazy Δp = ', num2str(Delta_p), ' deg'])
disp(['Zapas modułu Δg = ', num2str(Delta_g), ' dB'])


opts = bodeoptions;
opts.PhaseWrapping = 'on';
opts.Grid = 'on';
w = logspace(1, 4, 500); 
figure;
margin(G_ol, w, opts);
grid on;
title('Charakterystyka Bodego – zapasy stabilności');


