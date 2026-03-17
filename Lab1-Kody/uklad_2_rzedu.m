clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_9.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t_show = t(1:50:end);
y_show = y(1:50:end);
t = t(1:50:end);
y = 0.5+y(1:50:end)/2;
u = 0.5+u(1:50:end)/2;

Kp_f = 1;
tau = 0.0005046;
zeta = 0.6829;
Tk = 2.17 * 10^-3;
hmax = 1.056;



s = tf('s');
sys_f = Kp_f / (1 + 2*s*zeta*tau + (s^2)*tau^2);


% --- symulacja ---

figure;
step(sys_f)
hold on
xlabel('Czas [s]');
ylabel('Wyjście');
plot(t,y,'ro','LineWidth',1.2);
hold on
yline(hmax,'m--','LineWidth',1.2);
hold on
xline(Tk,'c--','LineWidth',1.2);
title ('Odpowiedź skokowa układu');
grid on
legend('Model zidentyfikowany przy pomocy odpowiedzi skokowej', 'Dane pomiarowe','hmax','Tk')


f_max=10^4;
f_plot = logspace(log10(1), log10(f_max), 200);
omega_plot = 2*pi*f_plot;

f = [20 80 200 300 450 700];              % [Hz]
mag = [(2/2) (2/2) (1.93/2) (1.7/2) (0.92/2) (0.4/2)];     % amplituda 
phase_deg = [-4.7 -20 -54.4 -85.2 -117.7 -143]; % faza w stopniach

omega = 2*pi*f;     


% --- Model dopasowany z charakterystyki czestotliwosciowej ---
[mag_sysf, phase_sysf] = bode(sys_f, omega_plot);
mag_sysf = squeeze(mag_sysf);
phase_sysf = squeeze(phase_sysf);

mag_db=20*log10(mag);
mag_sysf_db = 20*log10(mag_sysf);

db3 = mag_db(1) - 3.0;


% --- Rysowanie wykresu Bode ---
figure;

subplot(1,1,1); % amplituda
semilogx(f, mag_db, 'ro','MarkerSize',8,'LineWidth',1.2); hold on; % dane pomiarowe
semilogx(f_plot, mag_sysf_db, '--', 'LineWidth',1.5); % model z charakterystyki częstotliwościowej
yline(db3, 'm--', '-3 dB', 'LineWidth',1.2);
ylabel('Amplituda [dB]'); grid on;
xlabel('f [Hz]')
legend('Dane pomiarowe','Model zidentyfikowany przy pomocy odpowiedzi skokowej','Location','best');
title('Porównanie amplitudowej charakterystyki Bodego');


figure;
subplot(1,1,1); % faza
semilogx(f, phase_deg, 'ro','MarkerSize',8,'LineWidth',1.2); hold on; % dane pomiarowe
semilogx(f_plot, phase_sysf, '--', 'LineWidth',1.5); % model z charakterystyki
xlabel('f [Hz]');
ylabel('Faza [°]'); grid on;
legend('Dane pomiarowe','Model zidentyfikowany przy pomocy odpowiedzi skokowej','Location','best');
title('Porównanie fazowej charakterystyki Bodego');
