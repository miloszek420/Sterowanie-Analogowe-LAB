close all;
clear;
clc;

% --- Wczytaj dane i zidentyfikuj obiekt ---
filename1 = 'scope_62.csv';
[wyjscie1_skorygowane, time_vector1] = csv_parse(filename1);

% --- Identyfikacja ---


tau = 0.0005122;

zeta = 0.2215;
wn = 1 / tau;

Tw = 0.001562;
Tz = 0.0004537;



% --- Parametry regulatora ---
Kc = 4;     % Wzmocnienie proporcjonalne
Ti = 5;     % Czas całkowania [s]
Td = 1;     % Czas różniczkowania [s]

% --- Parametry sprzężeń ---
kw = 3;     % Wzmocnienie sprzężenia wewnętrznego
kz = 0;     % (opcjonalne)

% --- Operator Laplace'a ---
s = tf('s');

% --- Obiekt całkująco–inercyjny ---
G_obj = 1 / ((1 + Tw*s) * (Tz*s));

% ================================================================
% 🔧 WYBÓR TYPU REGULATORA
 typ_reg = 'P';   % tylko proporcjonalny
% typ_reg = 'PI';  % proporcjonalno–całkujący
% typ_reg = 'PID';   % pełny PID
% ================================================================

switch typ_reg
    case 'P'
        Gc = Kc;
        disp('➡️ Symulacja regulatora P');
    case 'PI'
        Gc = Kc * (1 + 1/(Ti*s));
        disp('➡️ Symulacja regulatora PI');
    case 'PID'
        Gc = Kc * (1 + 1/(Ti*s) + Td*s);
        disp('➡️ Symulacja regulatora PID');
    otherwise
        error('Nieznany typ regulatora. Wybierz: P, PI lub PID.');
end

% --- Układ otwarty ---
G_open = Gc * G_obj;

% --- Układ zamknięty ze sprzężeniem kw ---
G_closed = feedback(G_open, kw);

% --- Symulacja ---
t = 0:0.01:50;
[y, t] = step(G_closed, t);

% --- Wykres ---
figure;
plot(t, y, 'LineWidth', 1.5);
grid on;
xlabel('Czas [s]');
ylabel('Odpowiedź c(t)');
title(['Odpowiedź układu dla regulatora ', typ_reg]);
legend('c(t)');


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