
clear;
clc;

% Wczytaj dane z pliku .csv
filename1 = 'scope_66.csv';

[wyjscie1_skorygowane, time_vector1] = csv_parse(filename1);

% Znajdź wartość maksimum i jego indeks
kp=1;
[max_val, max_idx] = max(wyjscie1_skorygowane);
h_max = max_val;
Tk = time_vector1(max_idx);
K = ((h_max - kp) / kp);
zeta = (abs(log(K))) / sqrt(pi^2 + log(K)^2);
tau = -(zeta * Tk) / (log(K));
wn = 1 / tau;
%Tw = Tau/2*zeta
%Tz = 2 * zeta * Kc * Tau   Kc -> wzmocnienie na sterowniku P -> kc = kp
Tw=tau/(2*zeta);
Tz=2*zeta*tau*2;

yplus10 = 1.1;
ymius10 = 0.9;



fprintf("hmax = %.10f\nTk = %.10f\nK = %.10f\nzeta = %.10f\ntau = %.10f\nwn = %.10f\nTw = %.4e\nTz = %.4e\n",h_max,Tk,K,zeta,tau,wn,Tw,Tz);



% Definicja układu przekładniowego
licznik = 1;
mianownik = [tau^2, 2*zeta*tau, 1];
sys = tf(licznik, mianownik);

[y_sim, t_sim] = step(sys, time_vector1);



% Tworzenie wykresu czasowego
figure;
hold on;

% Wykres danych pomiarowych jako wykres punktowy co 25 wartości w kolorze jasno niebieskim
%plot(time_vector1(1:50:end), wyjscie1_skorygowane(1:50:end), 'bo', 'DisplayName', 'Dane pomiarowe');
plot(time_vector1(1:25:end), wyjscie1_skorygowane(1:25:end),'o', 'DisplayName', 'Dane pomiarowe (CSV)');
% Wykres modelu odpowiedzi skokowej
plot(t_sim, y_sim, 'LineWidth', 1.5, 'DisplayName', 'Symulacja układu');



% Wykres modelu z charakterystyki częstotliwościowej
% plot(time_vector1, y_fmins, 'LineWidth', 1.5, 'DisplayName', 'Model z charakterystyki czestotliwosciowej');

% Dodanie linii poziomej dla kp
% yline(kp, 'k--', 'LineWidth', 1.5, 'DisplayName', 'h(\infty)');
xline(Tk, 'r--', 'DisplayName', 'Tk');
yline(yplus10,'b--','DisplayName', '+ 10%')
yline(ymius10,'g--','DisplayName', '- 10%')

% Ustawienia wykresu
xlabel('Czas [s]');
ylabel('Odpowiedź h(t) [V]');
title('Odpowiedź skokowa układu')
legend('Location', 'best');
grid on;
hold off;



function [wyjscie, time_vector] = csv_parse(filename)
data1 = csvread(filename, 2, 0);
wejscie1 = data1(3:end, 2);
wyjscie1 = data1(3:end, 3);
time_vector = data1(3:end, 1);
time_vector = time_vector - time_vector(1);
time_increment1 = time_vector(2)-time_vector(1);

indeks_skoku1 = find(abs(wejscie1 - wejscie1(1)) > 0.3, 1);
% indeks_skoku1 = indeks_skoku1(4);
wartosc_skoku1 = (mean(wejscie1(end-24:end)) - mean(wejscie1(1:25))); % Oblicz wartość skoku na wejściu jako średnia z 50 ostatnich i 50 pierwszych wartości


% Wyświetl wartość skoku
fprintf('Wartość skoku na wejściu dla NewFile1.csv: %.4f\n', wartosc_skoku1);

% Przeskaluj dane, aby zaczynały się od momentu skoku
wejscie1 = wejscie1(indeks_skoku1) / wartosc_skoku1;
wejscie1 = wejscie1 + wartosc_skoku1 / 2;
wyjscie1_skorygowane = (wyjscie1(indeks_skoku1:end)) / wartosc_skoku1;
% kp = mean(wyjscie1_skorygowane(end-20:end));
% wyjscie1_skorygowane = wyjscie1_skorygowane/kp;
wyjscie1_skorygowane = (wyjscie1_skorygowane(1:end-1) + wyjscie1_skorygowane(2:end)) / 2;
wyjscie1_skorygowane = wyjscie1_skorygowane - wyjscie1_skorygowane(1);
h_inf = mean(wyjscie1_skorygowane(end-50:end));
wyjscie = wyjscie1_skorygowane/h_inf;

time_vector = (0:length(wyjscie)-1)*time_increment1;
end
