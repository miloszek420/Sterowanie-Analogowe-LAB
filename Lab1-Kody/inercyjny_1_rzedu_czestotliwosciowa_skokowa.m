
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

Kp = p_opt(1);
Tp = p_opt(2);

fprintf('Dopasowane parametry:\nKp = %.4f\nTp = %.4f\n', Kp, Tp);

% --- Tworzenie modelu i wykresy ---
s = tf('s');
sys = Kp / (1 + Tp*s);

figure;
step(sys);
title('Odpowiedź skokowa dopasowanego modelu');
grid on;

%{
% --- Porównanie charakterystyki ---
[mag_fit, phase_fit, ~] = bode(sys, omega);
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
%}