clear;
clc;
close all;
%Załaduj dane z CSV
data = readmatrix(['scope_9.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t = t(1:50:end);
y = 0.5+y(1:50:end)/2;
u = 0.5+u(1:50:end)/2;

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