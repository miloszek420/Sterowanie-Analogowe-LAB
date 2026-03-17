
%Załaduj dane z CSV
data = readmatrix(['scope_2.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejście
y = data(:,3); %wyjście

t_show = t(1:50:end);
y_show = y(1:50:end);
t = t(1:50:end);
y = 0.5+y(1:50:end)/2;
u = 0.5+u(1:50:end)/2;

x_tg = 0.0127 - 0.0007
y_tg = 12.9729 - (-13.1687)

Ti = (x_tg/(y_tg*(1/3)))