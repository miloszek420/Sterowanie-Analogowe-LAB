

clear;
clc; 
%Załaduj dane z CSV
data = readmatrix(['scope_1.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście


t = t(1:1:end);
y = y(1:1:end);
u = u(1:1:end);
figure;



plot(t,y,'r','LineWidth',1.2);
hold on
plot(t,u,'b','LineWidth',1.2);
xlabel('Czas [s]');
ylabel('Amplituda');
title('Wejście i wyjście sygnału');
legend('Wyjście', 'Wejście');
grid on