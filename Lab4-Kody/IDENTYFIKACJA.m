clc;
clear;
close all;



Tp = 0.155500000000000

% a) Charakterystyka obiektu sterowanego -> wyznaczenie kp

Ua = -10:1:10
nUa = [-25.5 , -25, -22.5, -19, -16.5, -13.5, -11, -8, -5, -2.5, 0, 3.5, 6, 9, 12, 15, 17.5, 21, 24, 26.5, 27]

p = polyfit(Ua, nUa, 1);
kp = p(1) * 6
nUa_fit = polyval(p, Ua)



% b) Charakterystyka tachoprądnicy

Ut = [-2.2, -1.8, -1.62, -1.39, -1.1, -0.89, -0.85, -0.65, -0.4, -0.25,0, 0.07, 0.27, 0.47, 0.7, 0.99, 1.2, 1.51, 1.85, 2.14, 2.22];
nUt = [-25.5 , -25, -22.5, -19, -16.5, -13.5, -11, -8, -5, -2.5, 0, 3.5, 6, 9, 12, 15, 17.5, 21, 24, 26.5, 27];

p2 = polyfit(nUt, Ut, 1);
kt = p2(1) / 6
Ut_fit = polyval(p2,nUt)


% c) Zależność sygnału (napięcia) wyjściowego THETA od kąta PHI

%theta -> napięcie na wyjściu
%phi -> kąt położenia osi
%dla poprawnego obliczenia delty trzeba bylo odwrocic dane i interpretowac
%je jako -180stopni -> 180stopni
theta = [-10.02, -9.96, -9.4, -8.82, -8.24, -7.66, -7.15, -6.55, -5.97, -5.39, -4.8, -4.19, -3.6, -3.02, -2.41, -1.83, -1.21, -0.627, 0.0246, 0.06, 0.71, 1.31, 1.92, 2.47, 3.11, 3.64, 4.21, 4.77, 5.27, 5.85, 6.41, 6.97, 7.52, 8.12, 8.68, 9.27, 9.73];
phi = -180:10:180;

% --- Dopasowanie liniowe polyfit ---
p_theta = polyfit(phi, theta, 1);
ks_fit = p_theta(1);   % współczynnik kierunkowy dopasowanej prostej
b_fit = p_theta(2);    % wyraz wolny

theta_fit = polyval(p_theta, phi);

d_theta = diff(theta);
d_phi = diff(phi);
ks = mean(d_theta ./ d_phi)

% d) Zależność sygnału napięcia zadającego THETA od kąta PHI

%theta2 -> napięcie na wyjściu
%phi2 -> kąt położenia osi
%tez potrzebna jest kreatywna analiza danych
%phi2 do 100, bo byla martwa strefa, a tyle punktow wystarczy do
%prawidlowego policzenia delty

theta2 = [-2.29, -1.76, -1.18, -0.61, 0.13, 0.55, 1.13, 1.85, 2.26, 2.91, 3.53, 4.04, 4.55, 5.1, 6.88,7.49,8.04, 8.65, 9.2, 9.71]
phi2 = [360,350,340,330,320,310,300,290,280,270,260,250,240,230,200,190,180,170,160,150]

d_theta2 = diff(theta2);
d_phi2 = diff(phi2);
kr = mean(d_theta2 ./ d_phi2)

p_theta2 = polyfit(phi2, theta2, 1);
kr_fit = p_theta2(1);   % współczynnik kierunkowy
b_fit2 = p_theta2(2);   % wyraz wolny


theta2_fit = polyval(p_theta2, phi2);




yplus10 = 1*0.9;
ymius10 = 1*1.1;


fprintf("=== Parametry identyfikacji ===\n");
fprintf("Tp = %.4f\nkp = %.4f\nkt = %.4f\nks_mean = %.4f\nkr_mean = %.4f\n\n", ...
     Tp, kp, kt, ks, kr) ;

figure;
plot(nUt, Ut, 'ro', 'DisplayName','Dane pomiarowe');
hold on
plot(nUt, Ut_fit, 'b-', 'LineWidth', 2, 'DisplayName','Model');
grid on
legend
xlabel('Prędkość obrotowa [obr/min]');
ylabel('Napięcie na szczotkach tachoprądnicy [V]');
title('Charakterystyka obiektu sterowanego');

% --- Wykres c ---
figure;
plot(phi, theta, 'ro', 'DisplayName', 'Dane pomiarowe');
hold on
plot(phi, theta_fit, 'b-', 'LineWidth', 2, 'DisplayName', sprintf('Model', ks_fit));
grid on
xlabel('Kąt położenia osi sterowanej [\circ]');
ylabel('Napięcie na wyjściu czujnika położenia [V]');
legend;
title('Charakterystyka czujnika położenia');

% --- Wykres d ---
figure;
plot(phi2, theta2, 'ro', 'DisplayName', 'Dane pomiarowe');
hold on
plot(phi2, theta2_fit, 'b-', 'LineWidth', 2, ...
     'DisplayName', sprintf('Model', kr_fit));
grid on
xlabel('Kąt położenia potencjometru zadającego [\circ]');
ylabel('Napięcie na wyjściu potencjometru zadającego [V]');
title('Charakterystyka zadajnika położenia');
legend;

