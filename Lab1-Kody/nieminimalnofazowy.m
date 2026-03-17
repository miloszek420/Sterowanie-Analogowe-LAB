clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_12.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t_show = t(1:50:end);
y_show = y(1:50:end);
t = t(272:50:end);
y = 0.5+y(272:50:end)/2;
u = 0.5+u(272:50:end)/2;

T0 = 0.0002672

h0 = -2.101
x = -h0;


Ty = T0 / (log(1+x)) 
Tx = x * Ty




s = tf('s');
sys_f = (1-(s*Tx)) / (1 + s*Ty);


% --- symulacja ---

figure;
step(sys_f)
hold on
xlabel('Czas [s]');
ylabel('Wyjście');
plot(t,y,'ro','LineWidth',1.2);
hold on
xline(T0,'c--','LineWidth',1.2);
title ('Odpowiedź skokowa układu');
grid on
legend('Model zidentyfikowany przy pomocy odpowiedzi skokowej', 'Dane pomiarowe','T0')


f_max=10^4;
f_plot = logspace(log10(1), log10(f_max), 200);
omega_plot = 2*pi*f_plot;

f = [20 200 500 1100 3000];              % [Hz]
mag = [(4.1/4) (4.5/4) (5.7/4) (7/4) (7.7/4) ];     % amplituda 
phase_deg = [-5.5 -45.5 -90.6 -130.4 -160]; % faza w stopniach

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
ylabel('Amplituda [dB]'); grid on;
xlabel('f [Hz]')
legend('Dane pomiarowe','Model zidentyfikowany przy pomocy odpowiedzi skokowej','Location','best');
title('Porównanie amplitudowej charakterystyki Bodego');


figure;
subplot(1,1,1); % faza
semilogx(f, phase_deg, 'ro','MarkerSize',8,'LineWidth',1.2); hold on; % dane pomiarowe
semilogx(f_plot, phase_sysf - 360, '--', 'LineWidth',1.5); % model z charakterystyki
xlabel('f [Hz]');
ylabel('Faza [°]'); grid on;
legend('Dane pomiarowe','Model zidentyfikowany przy pomocy odpowiedzi skokowej','Location','best');
title('Porównanie fazowej charakterystyki Bodego');
