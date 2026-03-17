clc; clear; close all;


s = tf('s');

Kp = 1.42;
Tp = 1.25e-3;
Ti = 0.68e-3;
a1 = 6.89e-4;
a2 = 2.54e-7;
T0 = 0.14e-3;

Gp = Kp / ((s*Ti)*(1 + s*Tp)*(1 + s*a1 + s^2*a2));
Gp_delay = Gp * exp(-4*T0*s);

t = 0:1e-5:0.03;         
[y_ref, t] = step(Gp_delay, t);


cost_fun = @(p) cost_step(p, t, y_ref);


p0 = [-1, 1000, 1e-6, 1e-3, 1]; 


options = optimset('Display','iter','TolX',1e-6,'TolFun',1e-6);
p_opt = fminsearch(cost_fun, p0, options);

a1p = p_opt(1);
a0p = p_opt(2);
b2p = p_opt(3);
b1p = p_opt(4);
b0p = p_opt(5);

Gp_prim = (a1p*s + a0p) / ( s*(b2p*s^2 + b1p*s + b0p) );


[y_id, ~] = step(Gp_prim, t);

figure;
plot(t, y_ref, 'b', 'LineWidth', 1.5); hold on;
plot(t, y_id,  'r--', 'LineWidth', 1.5);
grid on;
legend('Obiekt pełny','Model uproszczony');
xlabel('Czas [s]');
ylabel('Odpowiedź skokowa');
title('Identyfikacja G_p''(s) metodą fminsearch');

fprintf('\nWyznaczone współczynniki modelu Gp''(s):\n');
fprintf('a1'' = %.6e\n', a1p);
fprintf('a0'' = %.6e\n', a0p);
fprintf('b2'' = %.6e\n', b2p);
fprintf('b1'' = %.6e\n', b1p);
fprintf('b0'' = %.6e\n', b0p);

function J = cost_step(p, t, y_ref)

    s = tf('s');


    if p(1) >= 0
        J = 1e6;
        return;
    end

    Gp_prim = (p(1)*s + p(2)) / ( s*(p(3)*s^2 + p(4)*s + p(5)) );

    try
        y = step(Gp_prim, t);
        J = sum((y - y_ref).^2);
    catch
        J = 1e6;
    end
end
