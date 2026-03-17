
%Załaduj dane z CSV
data = readmatrix(['scope_2.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t = t(1:50:end);
y = y(1:50:end);
u = u(1:50:end);
figure;

plot(t,y,'r','LineWidth',1.2);
hold on
% Plot the input signal
plot(t, u, 'b', 'LineWidth', 1.2);
xlabel('Czas [s]');
ylabel('Amplituda');
title('Wejście i wyjście sygnału');
legend('Wyjście', 'Wejście');
grid on