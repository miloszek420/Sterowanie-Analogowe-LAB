close all;
clear;
clc;

%Symulacja dzia³ania uk³adu sterowania z sterownikiem PID

% Parametry modelu sterownika
% Parametry sterownika PID zgodne z konwencj¹ zapisan¹ w skrypcie
Kp = 0.196;%2.9375;
Ti = 5.4e-3;
Td = 3.4e-3;
% Parametry sterownika PID w innym zapisie
kp = Kp;
ki = Kp/Ti;
kd = Kp*Td;
% Wyznaczenie modelu sterownika
if ki>0,
    Lc = [kd kp ki];
    Mc = [1 0];
else
    Lc = [kd kp];
    Mc = 1;
end;

% Sterownik LEAD/LAG
%Kc = 0.6622;
%Tz = 1.8e-3;
%Tp = 0.88613e-3;
%Lc = Kc*[Tz 1];
%Mc = [Tp 1];
%Lc = 1.8*conv([0.012 1],[0.00052 1]);
%Mc = conv([0.018 1],[0.000019 1]);

% Model obiektu
Kp = 1.4;
Tx = 1.8e-3;
Ty = 0.16e-3;
Tp = 1.41e-3;
Ti = 1.66e-3;
L = 0.285;
M = 0.71e-3*[3.4e-7 9.28e-4 1 0]; 
%L  = 2.147e5;
%M  = [1.104e-6 0.0021 2.545 1097];
Top = 0;%3.55e-3; % Opoznienie transportowe obiektu
Umax = 10e10; % Ograniczenie na wartoœæ sygna³u steruj¹cego
% Model obiektu drugiego (w pêtli pomiarowej)
L2 = 1;
M2 = 1;
% Stworzenie interesujacych nas sygna³ów
dT = 1e-6;
o_dT = 2/dT;
T = 0:dT:0.2;
N = length(T);
R = ones(size(T));  % sygna³ zadaj¹cy
%R = T;
Rf = R;
E = zeros(size(T)); % Uchyb
dE = E;             % Pochodna uchybu
U  = E;             % sygna³ steruj¹cy
Y  = E;             % wyjœcie obiektu
Uop = E;            % wyjœcie czujnika
Uc = E;             % Wyjœcie cz³onu ca³kuj¹cego
% Stworzenie modelu stanowego sterownika i obiektu
%s = tf(Lc,Mc);
%[Ac,Bc,Cc,Dc] = ssdata(s);
s = tf(L,M);
[A1,B1,C1,D1] = ssdata(s);
s = tf(L2,M2);
[A2,B2,C2,D2] = ssdata(s);
Lf = 1;
Mf = [0.000002 1];
sf = tf(Lf,Mf);
[Af,Bf,Cf,Df] = ssdata(sf);
% Modyfikacja modelu stanowego
%Ac = dT*Ac; Bc = dT*Bc;
A1 = dT*A1; B1 = dT*B1;
A2 = dT*A2; B2 = dT*B2;
Af = dT*Af; Bf = dT*Bf;
% Stworzenie wektorow stanu obiektow
%Xc = zeros(size(Bc));
Xc2 = 0;
X1 = zeros(size(B1));



Xf = zeros(size(Bf));
% Stworzenie tablic realizujacych opoznienie transportowe
Nop = Top/dT;
Nop = round(Nop); %zaokraglanie wartosci
PamTop1 = zeros(1,Nop);
PamTop2 = zeros(1,Nop);
poz_op = 1;
op_b = 0;

% Symulacja ukladu zamknietego
for t = 1:N-1,
    
    % Formowanie sygna³u steruj¹cego --------------------------------------
    %Rf(t) = Cf*Xf + Df*R(t);
    %Xf_p = Xf + Af*Xf + Bf*R(t+1);
    %Xf   = Xf + 0.5*(Af*Xf + Bf*R(t) + Af*Xf_p + Bf*R(t+1));
    %Rf(t+1) = Cf*Xf + Df*R(t+1);
    
    % Symulacja detektora uchybu ------------------------------------------
    % Przewidywanie przysz³ego wyjœcia obiektu
    X1_p = X1 + A1*X1 + B1*Uop(t);
    Y(t+1) = C1*X1_p + D1*Uop(t);
    % Wyznaczenie sygna³u na wyjœciu detektora uchybu
    E(t)   = R(t) - Y(t);
    E(t+1) = R(t+1) - Y(t+1);
    
    % Wyznaczenie pochodnej uchybu
%    if t==1,
%        dE(t) = 0;
%    else
%        dE(t) = -dE(t-1) + o_dT*(E(t)-E(t-1));
%    end;
%    dE(t+1) = -dE(t) + o_dT*(E(t+1)-E(t));
    
    % Symulacja sterownika PID
    if t==1,
        U(t) = kp*E(t) + ki*Xc2 + kd*dE(t);
        Xc2  = Xc2 + 0.5*dT*(E(t) + E(t+1));
        U(t+1) = kp*E(t+1) + ki*Xc2 + kd*dE(t+1);
        Uc(t) = Xc2;
    else
        U(t) = kp*E(t) + ki*Xc2 + 0.5*kd*(dE(t)+dE(t-1));
        Xc2  = Xc2 + 0.5*dT*(E(t) + E(t+1));
        U(t+1) = kp*E(t+1) + ki*Xc2 + 0.5*kd*(dE(t+1)+dE(t));
        Uc(t) = Xc2;
    end;
    
    % Symulacja dynamiki sterownika -------------------------------
%    U(t) = Cc*Xc + Dc*E(t);
%    Xc_p = Xc + Ac*Xc + Bc*E(t+1);
%    Xc   = Xc + 0.5*(Ac*Xc + Bc*E(t) + Ac*Xc_p + Bc*E(t+1));
%    U(t+1) = Cc*Xc + Dc*E(t+1);

    % Ograniczenie wartoœci sygna³u steruj¹cego
    if U(t)<-Umax,
        U(t) = -Umax;
    end;
    if U(t)>Umax,
        U(t) = Umax;
    end;
    if U(t+1)<-Umax,
        U(t+1) = -Umax;
    end;
    if U(t+1)>Umax,
        U(t+1) = Umax;
    end;

    % Symulacja opóŸnienia transportowego obiektu pierwszego --------------
    if Nop>0,
        if t+Nop<=N,
            Uop(t+Nop) = U(t);
        end;
    else
        Uop(t)   = U(t);
        Uop(t+1) = U(t+1);
    end;
    
    % Symulacja dynamiki obiektu pierwszego -------------------------------
    Y(t) = C1*X1 + D1*Uop(t);
    X1_p = X1 + A1*X1 + B1*Uop(t+1);
    X1   = X1 + 0.5*(A1*X1 + B1*Uop(t) + A1*X1_p + B1*Uop(t+1));
    Y(t+1) = C1*X1 + D1*Uop(t+1);
    
    % Symulacja dynamiki obiektu drugiego ---------------------------------
    %Y2(t) = C2*X2 + D2*Y(t);
    %X2_p  = X2 + A2*X2 + B2*Y(t+1);
    %X2    = X2 + 0.5*(A2*X2 + B2*Y(t) + A2*X2_p + B2*Y(t+1));
    %Y2(t+1) = C2*X2 + D2*Y(t+1);
end;

plot(T,Y); 
grid on;

% Test dzia³ania symulacji
Lo = conv(Lc,L);
Mo = conv(Mc,M);
% Wyznaczenie transmitacji uk³adu zamkniêtego
Lz = conv(Lo,M2);
Lt = conv(Lo,L2);
Mt = conv(Mo,M2);
N_l = length(Lt);
N_m = length(Mt);
for i=1:N_m-N_l,
    Lt = [0 Lt];
end;
Mz = Lt + Mt;
Lz = conv(Lf,Lz);
Mz = conv(Mf,Mz);
% Wykonanie symulacji dzia³ania uk³adu zamkniêtego
%[YY] = step(Lz,Mz,T);

Gc = tf(Lc,Mc);
Gp = tf(L,M);
Gop = ss(tf(L,M,'inputdelay',Top));
Gz = feedback(Gc*Gp,1);
[YY] = step(Gz,T);
%[UU] = step(conv(Lc,M),Mz,T);
% Porównanie wyników symulacji
plot(T,Y,T,YY); grid on; 
title('Odpowiedz skokowa ukladu zamknietego');
pause; clf;
plot(T,U); grid on;
%plot(T,U,T,UU); grid on;
title('Sygnal sterujacy');
pause; clf;
plot(T,Y-YY'); grid on;
%plot(T,Y-YY',T,U-UU'); grid on;
title('Roznica wyjscia miedzy symulacja za pomoca STEP i petla FOR');

% Wyznaczenie przeregulowania i czasu pierwszego maksimum
Tmax = 0;
Ymax = 0;
Yost = Y(N);
for t = 1:N-1,
    if Y(t)>Ymax,
        Tmax = T(t);
        Ymax = Y(t);
    end;
end;

% Wyœwietlenie wyniku
disp('Przeregulowanie');
disp(100*(Ymax-1)/1);
disp('Czas maksimum');
disp(Tmax);

% Wyznaczenie przeregulowania i czasu pierwszego maksimum
Tmax = 0;
Ymax = 0;
Yost = YY(N);
for t = 1:N-1,
    if YY(t)>Ymax,
        Tmax = T(t);
        Ymax = YY(t);
    end;
end;

% Wyœwietlenie wyniku
disp('Przeregulowanie');
disp(100*(Ymax-1)/1);
disp('Czas maksimum');
disp(Tmax);