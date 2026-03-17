clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_12.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t = t(272:10:end);
y = 0.5+y(272:10:end)/2;
u = 0.5+u(272:10:end)/2;

T0 = 0.0002672
Tx = 1.2 * 10^-6
h0 = -2.0933
x = -h0;


Ty = T0 / (log(1+x)) 



figure;

plot(t,y,'r','LineWidth',1.2);
hold on
% Plot the input signal
plot(t, u, 'b', 'LineWidth', 1.2);
xlabel('Time (s)');
ylabel('Signal Amplitude');
title('Input and Output Signals');
legend('Output', 'Input');
grid on