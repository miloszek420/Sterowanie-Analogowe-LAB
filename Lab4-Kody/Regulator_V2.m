close all;
clear;
clc;

%% --- USTAWIENIA ---
typ_reg = 'P';               % 'P', 'PI', lub 'PID, lub PD'

%% --- WCZYTANIE DANYCH I PRZYGOTOWANIE ---

% --- Identyfikacja parametrów dynamicznych ---
% Dla ćw 4 wszystkie parametry identyfikujemy "z ręki" nie z csv

% Odczytana z CSV stała czasowa

Tp = 0.155500000000000

% a) Charakterystyka obiektu sterowanego -> wyznaczenie kp

Ua = -10:1:10
nUa = [-25.5 , -25, -22.5, -19, -16.5, -13.5, -11, -8, -5, -2.5, 0, 3.5, 6, 9, 12, 15, 17.5, 21, 24, 26.5, 27]

p = polyfit(Ua, nUa, 1);
kp = p(1) * 6


% b) Charakterystyka tachoprądnicy

Ut = [-2.2, -1.8, -1.62, -1.39, -1.1, -0.89, -0.85, -0.65, -0.4, -0.25,0, 0.07, 0.27, 0.47, 0.7, 0.99, 1.2, 1.51, 1.85, 2.14, 2.22];
nUt = [-25.5 , -25, -22.5, -19, -16.5, -13.5, -11, -8, -5, -2.5, 0, 3.5, 6, 9, 12, 15, 17.5, 21, 24, 26.5, 27];

p2 = polyfit(nUt, Ut, 1);
kt = p2(1) / 6


% c) Zależność sygnału (napięcia) wyjściowego THETA od kąta PHI

%theta -> napięcie na wyjściu
%phi -> kąt położenia osi
%dla poprawnego obliczenia delty trzeba bylo odwrocic dane i interpretowac
%je jako -180stopni -> 180stopni
theta = [-10.02, -9.96, -9.4, -8.82, -8.24, -7.66, -7.15, -6.55, -5.97, -5.39, -4.8, -4.19, -3.6, -3.02, -2.41, -1.83, -1.21, -0.627, 0.0246, 0.06, 0.71, 1.31, 1.92, 2.47, 3.11, 3.64, 4.21, 4.77, 5.27, 5.85, 6.41, 6.97, 7.52, 8.12, 8.68, 9.27, 9.73];
phi = -180:10:180;


d_theta = diff(theta);
d_phi = diff(phi);
ks = mean(d_theta ./ d_phi)



% d) Zależność sygnału napięcia zadającego THETA od kąta PHI

%theta2 -> napięcie na wyjściu
%phi2 -> kąt położenia osi
%tez potrzebna jest kreatywna analiza danych
%phi2 do 100, bo byla martwa strefa, a tyle punktow wystarczy do
%prawidlowego policzenia delty

theta2 = [ -9.97, -9.38, -8.79, -8.22, -7.56, -6.99, -6.43, -5.82, -5.31, -4.7, -4.1, -3.43, -2.92, -2.33, -2.29, -1.76, -1.18, -0.61, 0.002, 0.13, 0.55, 1.13, 1.85, 2.26, 2.91, 3.53, 4.04, 4.55, 5.1];
phi2 = -180:10:100;

d_theta2 = diff(theta2);
d_phi2 = diff(phi2);
kr = mean(d_theta2 ./ d_phi2)




yplus10 = 1*0.9;
ymius10 = 1*1.1;


fprintf("=== Parametry identyfikacji ===\n");
fprintf("Tp = %.4f\nkp = %.4f\nkt = %.4f\nks_mean = %.4f\nkr_mean = %.4f\n\n", ...
     Tp, kp, kt, ks, kr) ;

%% --- PARAMETRY REGULATORA I SPRZĘŻEŃ ---
Kc = 10;     % wzmocnienie proporcjonalne
Ti_nastawa = 700;     % czas całkowania -> liczba obrotów
Td_nastawa = 3;     % czas różniczkowania -> liczba obrotów
kw = 3;     % wzmocnienie sprzężenia zwrotnego
kz = 2;     % dodatkowe sprzężenie (opcjonalnie)

%Td = (2.2 + Ti_nastawa*4.7)*2.2*10^-4 Wzór ze skryptu (w dodatku poprawiony)
Ti = (1.2+Ti_nastawa*3.16)*1.2*10^-4
Td = (1+Td_nastawa*3.16)*1*10^-4

Ti = 0.1

%% --- DEFINICJE BLOKÓW ---
s = tf('s');

% Model układu ze skryptu 4.4
% 
%  MODEL OBIEKTU – silnik DC:
%  Gp(s) = k_p / s* (1 + T_p*s)
%

G_kr = kr;
Gp = kp / (s*(1 + Tp*s));



% --- Regulator w zależności od trybu ---
switch typ_reg
    case 'P'
        Gc = Kc;
        disp('➡️ Symulacja regulatora P');
    case 'PI'
        % Według skryptu 
        %Gc = Kc + 1/(s*Ti);
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

% G_open_silnik = Gc*Gp;
% G_closed1 = feedback(G_open_silnik,(kt*s));
% G_closed2 = feedback(G_closed1,ks);
% 
% G_all = G_kr * G_closed2;

%% Układ regulacji położeniowej

% L = Gc * Gp;       % układ otwarty
% 
% H = kt*s;     % suma sprzężeń pochodząca z tachometru i czujnika położenia
% 
% G_closed1 = feedback(L, H);
% 
% G_all =feedback(ks * G_closed1, 1);  % Układ zamknięty z uwzględnieniem sprzężeń

%% Układ regulacji prędkościowej

G_open = Gc * Gp * kt*s;
G_all = feedback(G_open,1);


%% --- SYMULACJA ---
t = (0:0.001:5);
[y_sim, t_sim] = step(G_all, t);

%% --- CZAS USTALANIA 95% ---
y_final = y_sim(end);            % Wartość końcowa odpowiedzi
y_target = 0.95 * y_final;       % 95% wartości końcowej

% Znalezienie pierwszego momentu, w którym y_sim osiąga 95% wartości końcowej
idx = find(y_sim >= y_target, 1, 'first');  
t_settling_95 = t_sim(idx);

fprintf('Czas ustalania odpowiedzi do 95%%: %.4f s\n', t_settling_95);

%% --- PRZEREGULOWANIE ---
y_final = y_sim(end);                % wartość końcowa odpowiedzi
y_max = max(y_sim);                   % maksimum sygnału
overshoot = ((y_max - y_final)/y_final) * 100;   % przeregulowanie w %

fprintf('Przeregulowanie: %.2f %%\n', overshoot);


%% --- WYKRESY ---
figure;
hold on;
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
