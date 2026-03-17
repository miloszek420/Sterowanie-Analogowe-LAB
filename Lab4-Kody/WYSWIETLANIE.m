

clear;
clc; 
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_1.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście



t = t(1:1:end);
u = u(1:1:end);
y = y(1:1:end);

y_inf = mean(y(end-100:end));     % wartość ustalona
y_63 = 0.632 * y_inf

% znajdź indeks kiedy pierwszy raz y >= y_63
idx = find(y >= y_63, 1, 'first');

Tp = t(idx)
figure;



plot(t,y,'r','LineWidth',1.2);
hold on
yline(y_63,'g--','Y_{63%} = 1,21');
xline(Tp,'b--','Tp = 0,155');
xlabel('Czas [s]');
ylabel('Amplituda [V]');
title('Napięcie tachoprądnicy');
legend('Wyjście');
grid on
xlim([0 max(t)]);