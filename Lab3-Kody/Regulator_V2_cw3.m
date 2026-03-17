%close all;
clear;
clc;

%% --- USTAWIENIA ---
filename1 = 'scope_66.csv';   % plik z danymi CSV
typ_reg = 'PID';               % 'P', 'PI', lub 'PID, lub PD'

%% --- WCZYTANIE DANYCH I PRZYGOTOWANIE ---
[wyjscie_norm, time_vector] = csv_parse(filename1);

% --- Identyfikacja parametrów dynamicznych ---
kp = 1;
[max_val, max_idx] = max(wyjscie_norm);
h_max = max_val;
Tk = time_vector(max_idx);

K = (h_max - kp) / kp;
zeta = 0.2214792370
tau = 0.0005121677
wn = 1952.4853507641
Tw = 1.1562e-03
Tz = 4.5374e-04


yplus10 = 1*0.9;
ymius10 = 1*1.1;

format long
Tw = 0.001562;
Tz = 0.0004537;


fprintf("=== Parametry identyfikacji ===\n");
fprintf("hmax = %.4f\nTk = %.4f\nK = %.4f\nzeta = %.4f\ntau = %.4f\nwn = %.4f\nTw = %.4f\nTz = %.4f\n\n", ...
    h_max, Tk, K, zeta, tau, wn, Tw, Tz);

%% --- PARAMETRY REGULATORA I SPRZĘŻEŃ ---
Kc = 16;     % wzmocnienie proporcjonalne
Ti_nastawa = 1;     % czas całkowania -> liczba obrotów
Td_nastawa = 3;     % czas różniczkowania -> liczba obrotów
kw = 3;     % wzmocnienie sprzężenia zwrotnego
kz = 2;     % dodatkowe sprzężenie (opcjonalnie)

%Td = (2.2 + Ti_nastawa*4.7)*2.2*10^-4 Wzór ze skryptu (w dodatku poprawiony)
Ti = (1.2+Ti_nastawa*3.16)*1.2*10^-4
Td = (1+Td_nastawa*3.16)*1*10^-4


%% --- DEFINICJE BLOKÓW ---
s = tf('s');

% Model obiektu całkująco–inercyjnego
G_obj1 = 1 / ((1 + Tw*s));
G_obj2 = 1 / ((Tz*s));

G_obj1_closed = feedback(G_obj1, kw);
G_obj2_closed = feedback(G_obj2, kz);

% --- Regulator w zależności od trybu ---
switch typ_reg
    case 'P'
        Gc = Kc;
        disp('➡️ Symulacja regulatora P');
    case 'PI'
        Gc = Kc * (1 + 1/(Ti*s));
        disp('➡️ Symulacja regulatora PI');
    case 'PID'
        Gc = Kc * (1 + 1/(Ti*s) + (1+Td*s));
        disp('➡️ Symulacja regulatora PID');
    case 'PD'
        % Regulator PD – proporcjonalno–różniczkujący
        % Czas różniczkowania Td określa wzmocnienie składnika D
        Gc = Kc * (1+ Td*s);
        disp('➡️ Symulacja regulatora PD');

    otherwise
        error('Nieznany typ regulatora. Wybierz: P, PI, PID lub PD.');
end

%% --- UKŁAD ZAMKNIĘTY ---
G_open = Gc * G_obj1_closed*G_obj2_closed;
G_closed = feedback(G_open, 1)

%% --- SYMULACJA ---
t = (0:0.00001:0.005);
[y_sim, t_sim] = step(G_closed, t);



 %Sygnał wejściowy (step do 0.4)
u_sim = 0.4 * ones(size(t_sim));

%% --- WYKRESY ---
figure;
hold on;
% Dane pomiarowe co 50 punktów
%plot(time_vector(1:50:end), wyjscie_norm(1:50:end), 'bo', 'DisplayName', 'Dane pomiarowe (CSV)');
% Dane pomiarowe co 25 punktów
plot(time_vector(1:25:end), wyjscie_norm(1:25:end), 'bo', 'DisplayName', 'Dane pomiarowe (CSV)');
% Model
plot(t_sim, y_sim, 'g-', 'LineWidth', 1.5, 'DisplayName', ['Model ', typ_reg]);
%plot(t_sim, u_sim, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Sygnał sterujący');
% yline(yplus10,'b--','DisplayName', '+ 10%')
% yline(ymius10,'g--','DisplayName', '- 10%')

xlabel('Czas [s]');
ylabel('Odpowiedź h(t) [V]');
title(['Porównanie danych i modelu (' typ_reg ')']);
legend('Location', 'best');
grid on;
hold off;

%% --- FUNKCJA WCZYTANIA DANYCH BEZ NORMALIZACJI ---
% function [wyjscie, time_vector] = csv_parse(filename)
%     % Wczytaj dane z pominięciem dwóch pierwszych wierszy (nagłówków)
%     data = csvread(filename, 2, 0);
%     time_vector = data(3:end, 1);
%     wejscie = data(3:end, 2);
%     wyjscie_raw = data(3:end, 3);
% 
%     % Wyrównanie czasu
%     time_vector = time_vector - time_vector(1);
%     dt = time_vector(2) - time_vector(1);
% 
%     % Znajdź moment skoku na wejściu
%     idx_step = find(abs(wejscie - wejscie(1)) > 0.3, 1);
%     if isempty(idx_step)
%         error('Nie znaleziono momentu skoku w danych.');
%     end
% 
%     % Oblicz wartość skoku na wejściu
%     du = mean(wejscie(end-25:end)) - mean(wejscie(1:25));
%     fprintf("Wartość skoku na wejściu: %.4f\n", du);
% 
%     % Przytnij sygnał od momentu skoku
%     wyjscie_cut = wyjscie_raw(idx_step:end);
%     time_vector = (0:length(wyjscie_cut)-1) * dt;
% 
%     % Usuń offset początkowy (żeby zaczynało się od zera)
%     wyjscie = wyjscie_cut - wyjscie_cut(1);
% 
%     % (opcjonalnie) — jeśli chcesz zachować oryginalny poziom sygnału, usuń powyższą linię
%end
%% --- FUNKCJA WCZYTANIA DANYCH Z NORMALIZACJĄ ---
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
