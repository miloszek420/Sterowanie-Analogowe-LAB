clear;
clc;
close all;
%Zaaduj dane z CSV
data = readmatrix(['scope_1.csv'], 'NumHeaderLines',2);
t = data(:,1); %czas
u = data(:,2); %wejcie
y = (1.5+data(:,3))/2; %wyjcie

t = t(36:25:end);
y = y(36:25:end);
u = u(36:25:end);