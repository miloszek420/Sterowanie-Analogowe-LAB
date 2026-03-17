clc;
clear;
close all;


%Załaduj dane z CSV
data = readmatrix(['scope_1.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
y = (1.5+data(:,3))/2; %wyjście

t = t(207:50:end);
y = y(207:50:end);



%% Analiza odpowiedzi skokowej na podstawie charakterystyki częstotliwościowej


%% --- 1. Dane pomiarowe ---
% Możesz też wczytać z pliku CSV, np.:
% data = readmatrix('char_freq.csv');
% f = data(:,1); mag_dB = data(:,2); phase_deg = data(:,3);

f = [20 40 60 110 310 640];              % [Hz]
mag = [(5.54/4) (5.132/4) (5.06/4) (4.20/4) (2.13/4) (1.1/4)]      % amplituda 
phase_deg = [-9 -17.4 -25.4 -40.6 -67.8 -79]; % faza w stopniach

omega = 2*pi*f;                         % rad/s

% --- Dane zespolone ---
G_exp = mag .* exp(1j*deg2rad(phase_deg));

% --- Funkcja błędu dla fminsearch ---
err_fun = @(p) sum(abs(G_exp - (p(1)./(1 + 1j*omega*p(2)))).^2);

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


figure;

plot(t,y,'ro','LineWidth',1.2);

xlabel('Czas [s]');
ylabel ('Napięcie [V]');
title ('Odpowiedź skokowa układu');
legend('Sygnał wyjściowy', 'Location', 'Best');
grid on
hold on
step((sys_f))
grid on



% --- Porównanie charakterystyki ---
[mag_fit, phase_fit, ~] = bode(sys_f, omega);
mag_fit = squeeze(mag_fit);
phase_fit = squeeze(phase_fit);

figure;
subplot(2,1,1);
semilogx(f, mag, 'o', f, mag_fit, '-');
ylabel('|G(jw)|');
grid on;
legend('Pomiar','Model');

subplot(2,1,2);
semilogx(f, phase_deg, 'o', f, phase_fit, '-');
xlabel('f [Hz]');
ylabel('Faza [°]');
grid on;
legend('Pomiar','Model');



