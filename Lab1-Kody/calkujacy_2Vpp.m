clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_2.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t_show = t(1:50:end);
y_show = y(1:50:end);
t = t(1:50:end);
y = y(1:50:end);
u = u(1:50:end);

x_tg = 0.0156 - 0.00185
y_tg = 8.54689 - (-11.7633)

Ti = (x_tg/y_tg)


s = tf('s');
sys_f = (1/(s*Ti))-13.19;


% --- symulacja ---

figure;
step(sys_f)
hold on
xlabel('Czas [s]');
ylabel('Wyjście [V]');
plot(t,y,'ro','LineWidth',1.2);
hold on
title ('Odpowiedź skokowa układu');
grid on
legend('Model zidentyfikowany przy pomocy odpowiedzi skokowej', 'Dane pomiarowe')


