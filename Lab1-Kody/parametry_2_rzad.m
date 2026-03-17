%Obliczanie parametrów dla układu II rzędu

hmax = 1.056;
hinf = 1;
K = (hmax-hinf)/hmax
Tk=2.17;



zeta = abs(log(K))/sqrt((pi)^2 + (log(K)^2))

tau = - (zeta * Tk) / log(K) 