clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_1.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = (1.5+data(:,3))/2; %wyjście

t_show = t(80:25:end);
y_show = y(80:25:end);
t = t(80:10:end);
y = y(80:10:end);
u = u(80:10:end);

% p = [Kp, Tp, T0]

err_fun = @(p) sum( ...
    (y - (p(1) * (1 - exp(-(t - p(3)) / p(2))) .* (t >= p(3)))).^2 );

p0 = [max(y), mean(diff(t)),0.0001];  % początkowe przybliżenie [Kp, Tp, T0]
p_opt = fminsearch(err_fun, p0);

Kp = p_opt(1);
Tp = p_opt(2);
T0 = p_opt(3);

fprintf('Model z odpowiedzi skokowej:\nKp = %.4f\nTp = %.4f s\nT0 = %.6f s\n', Kp, Tp, T0);

s = tf('s');
sys = (Kp*exp(-s*T0)) / (1 + Tp*s);

% --- sygnał wejściowy: od -1 do 1 w t=0 ---
u_model = ones(size(t));  % domyślnie 1
u_model = u_model * 2 - 1;      % zamiana na skok z -1 do 1
% Wyjaśnienie: u*2 daje 2, a -1 przesuwa początek do -1

f = [20 50 100 200 400 650 1100];              % [Hz]
mag = [(5.51/4) (5.21/4) (4.41/4) (3.02/4) (1.71/4) (1.1/4) (0.65/4)];     % amplituda 
phase_deg = [-11 -25.1 -45.3 -71.7 -99.9 -125 -160]; % faza w stopniach

omega = 2*pi*f;                         % rad/s

% --- Dane zespolone ---
G_exp = mag .* exp(1j*deg2rad(phase_deg));

% --- Funkcja błędu dla fminsearch ---
err_fun_f = @(p) sum(abs(G_exp - ...
    (p(1)*exp(-1j*omega*p(3)) ./ (1 + 1j*omega*p(2)))).^2);
% --- Startowe przybliżenie: [Kp, Tp, T0]
p0 = [1, 1, 0.001];

% --- Dopasowanie ---
p_opt = fminsearch(err_fun, p0);

Kp_f = p_opt(1);
Tp_f = p_opt(2);
T0_f = p_opt(3);

fprintf('Model z charakterystyki częstotliwościowej:\nKp = %.4f\nTp = %.4f s\nT0 = %.6f s\n', ...
    Kp_f, Tp_f, T0_f);

% --- Tworzenie modelu i wykresy ---
s_f = tf('s');
sys_f = ((Kp_f*exp(-s_f*T0)) / (1 + Tp_f*s_f));



% --- symulacja ---

figure;
lsim(sys, u_model, t);
xlabel('Czas [s]');
ylabel('Wyjście');
hold on
lsim(sys_f, u_model, t);
hold on
plot(t_show,y_show,'ro','LineWidth',1.2);
hold on
yline(Kp,'b--','LineWidth',1.2)
hold on
xline(Tp,'r--','LineWidth',1.2)
hold on
xline(T0,'g--','LineWidth',1.2);
hold on
title ('Odpowiedź skokowa układu');
grid on
legend('Model zidentyfikowany przy pomocy odpowiedzi skokowej', 'Model zidentyfikowany przy pomocy charakterystyki częstoliwościowej', 'Dane pomiarowe','Kp','Tp')

f_max=2000;
f_plot = logspace(log10(1), log10(f_max), 200);
omega_plot = 2*pi*f_plot;

% --- Model dopasowany z odpowiedzi skokowej ---
[mag_sys, phase_sys] = bode(sys, omega_plot);
mag_sys = squeeze(mag_sys);
phase_sys = squeeze(phase_sys);

% --- Model dopasowany z charakterystyki czestotliwosciowej ---
[mag_sysf, phase_sysf] = bode(sys_f, omega_plot);
mag_sysf = squeeze(mag_sysf);
phase_sysf = squeeze(phase_sysf);

mag_db=20*log10(mag);
mag_sys_db = 20*log10(mag_sys);
mag_sysf_db = 20*log10(mag_sysf);

db3 = mag_db(1) - 3.0;


% --- Rysowanie wykresu Bode ---
figure;

subplot(1,1,1); % amplituda
semilogx(f, mag_db, 'ro','MarkerSize',8,'LineWidth',1.2); hold on; % dane pomiarowe
semilogx(f_plot, mag_sys_db, '-', 'LineWidth',1.5); % model z odpowiedzi skokowej
semilogx(f_plot, mag_sysf_db, '--', 'LineWidth',1.5); % model z charakterystyki częstotliwościowej
yline(db3, 'm--', '-3 dB', 'LineWidth',1.2);
ylabel('Amplituda [dB]'); grid on;
xlabel('f [Hz]')
legend('Dane pomiarowe','Model zidentyfikowany przy pomocy odpowiedzi skokowej','Model zidentyfikowany przy pomocy charakterystyki częstoliwościowej','Location','best');
title('Porównanie amplitudowej charakterystyki Bodego');







figure;
subplot(1,1,1); % faza
semilogx(f, phase_deg, 'ro','MarkerSize',8,'LineWidth',1.2); hold on; % dane pomiarowe
semilogx(f_plot, phase_sys, '-', 'LineWidth',1.5); % model z odpowiedzi skokowej
semilogx(f_plot, phase_sysf, '--', 'LineWidth',1.5); % model z charakterystyki
xlabel('f [Hz]');
ylabel('Faza [°]'); grid on;
legend('Dane pomiarowe','Model zidentyfikowany przy pomocy odpowiedzi skokowej','Model zidentyfikowany przy pomocy charakterystyki częstoliwościowej','Location','best');
title('Porównanie fazowej charakterystyki Bodego');
