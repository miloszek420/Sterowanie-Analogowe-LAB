clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_0.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = (1.5+data(:,3))/2; %wyjście

t = t(207:50:end);
y = y(207:50:end);
u = u(207:50:end);


err_fun = @(p) sum((y - p(1)*(1 - exp(-t/p(2)))).^2);

p0 = [max(y), mean(diff(t))];  % początkowe przybliżenie [Kp, Tp]
p_opt = fminsearch(err_fun, p0);

Kp = p_opt(1);
Tp = p_opt(2);

fprintf('Dopasowane parametry:\nKp = %.4f\nTp = %.4f s\n', Kp, Tp);

s = tf('s');
sys = Kp / (1 + Tp*s);

% --- sygnał wejściowy: od -1 do 1 w t=0 ---
u_model = ones(size(t));  % domyślnie 1
u_model = u_model * 2 - 1;      % zamiana na skok z -1 do 1
% Wyjaśnienie: u*2 daje 2, a -1 przesuwa początek do -1

f = [20 40 60 110 310 640];              % [Hz]
mag = [(5.54/4) (5.132/4) (5.06/4) (4.20/4) (2.13/4) (1.1/4)]      % amplituda 
phase_deg = [-9 -17.4 -25.4 -40.6 -67.8 -79]; % faza w stopniach

omega = 2*pi*f;                         % rad/s

% --- Dane zespolone ---
G_exp = mag .* exp(1j*deg2rad(phase_deg));

% --- Funkcja błędu dla fminsearch ---
err_fun = @(p) sum(abs(G_exp - (p(1)./(1 + (2*1j*omega*p(2)))).^2);

% --- Startowe przybliżenie: [Kp, Tp]
p0 = [1, 1];

% --- Dopasowanie ---
p_opt = fminsearch(err_fun, p0);

Kp_f = p_opt(1);
Tp_f = p_opt(2);

fprintf('Dopasowane parametry:\nKp = %.4f\nTp = %.4f\n', Kp_f, Tp_f);

% --- Tworzenie modelu i wykresy ---
s_f = tf('s');
sys_f = (Kp_f / (1 + Tp_f*s_f));



% --- symulacja ---

figure;
lsim(sys, u_model, t);
xlabel('Czas [s]');
ylabel('Wyjście');
hold on
lsim(sys_f, u_model, t);
hold on
plot(t,y,'ro','LineWidth',1.2);
hold on
yline(1.4407,'b--','LineWidth',1.2)
hold on
xline(0.0012,'r--','LineWidth',1.2)
title ('Odpowiedź skokowa układu');
grid on
legend('Model zidentyfikowany przy pomocy odpowiedzi skokowej', 'Model zidentyfikowany przy pomocy charakterystyki częstoliwościowej', 'Dane pomiarowe','Kp','Tp')

f_max=10^4;
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
