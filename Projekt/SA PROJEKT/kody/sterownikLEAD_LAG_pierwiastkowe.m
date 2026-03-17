%% Regulator LEAD – strojenie numeryczne
clear; 

s = tf('s');

% Parametry obiektu
a1p = -7.274253e-01;
a0p = 1.378812e+03;
b2p = 7.384625e-07;
b1p = 1.296655e-03;
b0p = 6.605551e-01;

Gp = (a1p*s + a0p) / ( s*(b2p*s^2 + b1p*s + b0p) );

kappa_max = 30;  % max przeregulowanie [%]
Ts_max    = 0.02; % max czas ustalania [s]

% Funkcja kosztu dla LEAD
cost_fun = @(x) cost_lead(x, s, Gp,kappa_max, Ts_max);
% Punkt startowy [z, p, kc]
x0 = [100, 2000, 1]; 

options = optimset('Display','iter','TolX',1e-6,'TolFun',1e-6);
x_opt = fminsearch(cost_fun, x0, options);

z_opt  = x_opt(1);
p_opt  = x_opt(2);
kc_opt = x_opt(3);


disp('==============================');
disp('OPTYMALNE NASTAWY LEAD:');
disp(['z = ', num2str(z_opt)]);
disp(['p = ', num2str(p_opt)]);
disp(['kc = ', num2str(kc_opt)]);
disp('==============================');

% Definicja regulatora LEAD
Gc = kc_opt * (s + z_opt)/(s + p_opt);
Gcl = feedback(Gc*Gp, 1);

% Odpowiedź skokowa
t = 0:1e-5:0.05;
[y, t_out] = step(Gcl, t);
info = stepinfo(y, t_out)

y_ss = y(end);
[y_max, idx_max] = max(y);
t_max = t_out(idx_max);

% Do porownania P
Gc_p = 0.1103;
Gcl_p = feedback(Gc_p*Gp, 1);

t_p = 0:1e-5:0.05;
[y_p, t_p_out] = step(Gcl_p, t_p);
info_p = stepinfo(y_p, t_p_out)

%LEAD-LAG

% Funkcja kosztu LEAD-LAG
cost_fun = @(x) cost_leadlag(x, s, Gp, kappa_max, Ts_max);

% [z1 p1 z2 p2 kc]
x0 = [100, 2000, 1, 50, 1];

options = optimset('Display','iter','TolX',1e-6,'TolFun',1e-6);
x_opt = fminsearch(cost_fun, x0, options);

z1 = x_opt(1); p1 = x_opt(2);
z2 = x_opt(3); p2 = x_opt(4);
kc = x_opt(5);


disp('==============================');
disp('OPTYMALNE NASTAWY LEAD-LAG:');
disp(['z1 = ', num2str(z1)]);
disp(['p1 = ', num2str(p1)]);
disp(['z2 = ', num2str(z2)]);
disp(['p2 = ', num2str(p2)]);
disp(['kc = ', num2str(kc)]);
disp('==============================');

% Regulator LEAD-LAG
Gc = kc*(s+z1)/(s+p1)*(s+z2)/(s+p2);
Gcl = feedback(Gc*Gp,1);

% Odpowiedź skokowa
t = 0:1e-5:0.05;
[y_lead_lag,t_lead_lag] = step(Gcl,t);
info_lead_lag = stepinfo(y,t_out,'SettlingTimeThreshold',0.02)


% Rysowanie
figure; hold on; grid on;
plot(t_out, y, 'b', 'LineWidth', 2);
hold on
plot(t_lead_lag, y_lead_lag, 'r', 'LineWidth', 2);
hold on
plot(t_p_out, y_p, 'g', 'LineWidth', 2);
yline(y_ss, '--k');
xline(info.SettlingTime, '--r');
plot(t_max, y_max, 'ro', 'MarkerSize',8,'LineWidth',2);
text(t_max, y_max, sprintf('\\kappa = %.2f %%', info.Overshoot), 'VerticalAlignment','bottom');
xlabel('Czas [s]');
ylabel('Wyjście');
title('Odpowiedź skokowa – regulator LEAD-LAG');
legend('Regulator LEAD','Regulator LEAD-LAG','Sterownik P','Stan ustalony','T_s','Maksimum','Location','best');

% Funkcja kosztu LEAD
function J = cost_lead(x, s, Gp,  kappa_max, Ts_max)
    z  = abs(x(1));
    p  = max(z + 1e-3, x(2)); % p > z
    kc = abs(x(3));

    Gc = kc*(s + z)/(s + p);
    Gcl = feedback(Gc*Gp, 1);

    if ~isstable(Gcl)
        J = 1e9;
        return;
    end

    [y, t] = step(Gcl, 0:1e-5:0.05);
    info = stepinfo(y, t);

    J = max(0, info.Overshoot - kappa_max)^2 * 1e3 + ...
        max(0, info.SettlingTime - Ts_max)^2 * 1e4;
end

% === Funkcja kosztu LEAD-LAG ===
function J = cost_leadlag(x, s, Gp, kappa_max, Ts_max)

    z1 = abs(x(1));
    p1 = max(z1 + 1e-3, abs(x(2)));

    z2 = abs(x(3));
    p2 = max(z2 + 1e-3, abs(x(4)));

    kc = abs(x(5));

    % separacja LEAD / LAG
    if z2 > z1
        J = 1e9; return;
    end

    Gc = kc*(s+z1)/(s+p1)*(s+z2)/(s+p2);
    Gcl = feedback(Gc*Gp,1);

    if ~isstable(Gcl)
        J = 1e9; return;
    end

    [y,t] = step(Gcl,0:1e-5:0.05);
    info = stepinfo(y,t,'SettlingTimeThreshold',0.02);

    J = max(0,info.Overshoot - kappa_max)^2 * 1e3 + ...
        max(0,info.SettlingTime - Ts_max)^2 * 1e4;
end
