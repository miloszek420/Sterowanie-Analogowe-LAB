%% --- PORÓWNANIE RÓŻNYCH TOPOLOGII OBIEKTU ---
s = tf('s');

% parametry (użyj tych, które masz)
Tw = 0.001562;
Tz = 0.0004537;
kw = 3;
kz = 2;
Kc = 42;
Ti = (1.2+0*3.16)*1.2*10^-4;
Td = (1+3*3.16)*1*10^-4;

% regulator P (tak jak masz w typ_reg='P')
Gc = Kc;

% --- 1) Twoja aktualna implementacja (co masz w kodzie: feedback na kazdym + kaskada) ---
G_obj1 = 1 / (1 + Tw*s);
G_obj2 = 1 / (Tz*s);     % <-- oryginalnie w Twoim kodzie
G_obj1_closed = feedback(G_obj1, kw);
G_obj2_closed = feedback(G_obj2, kz);
G_obj_impl = G_obj1_closed * G_obj2_closed;   % to, co masz teraz w G_open bez Gc

% --- 2) Wariant równoległy (sumowanie torów) - interpretacja z rysunku ---
G1 = (kw) / (1 + Tw*s);   % tor inercyjny * Kw
G2 = (kz) / (s*Tz);       % tor całkujący * Kz
G_obj_parallel = G1 + G2;

% --- 3) Wariant kaskadowy prosty (G_obj1 * G_obj2) bez zamknięć wewnętrznych ---
G_obj_cascade = G_obj1 * G_obj2;

% Połącz z regulatorem i policz pętle zamknięte
G_closed_impl = feedback(Gc * G_obj_impl, 1);
G_closed_parallel = feedback(Gc * G_obj_parallel, 1);
G_closed_cascade = feedback(Gc * G_obj_cascade, 1);

% policz dcgain (wzmocnienie w stanie ustalonym)
dc_impl = dcgain(G_closed_impl);
dc_par = dcgain(G_closed_parallel);
dc_cas = dcgain(G_closed_cascade);

fprintf('DC gains (zamk. pętla) - impl: %.4f, parallel: %.4f, cascade: %.4f\n', dc_impl, dc_par, dc_cas);

% symuluj step dla wszystkich (ten sam wektor czasu co u Ciebie)
t = (0:0.000001:0.005);
[y_impl, ~] = step(G_closed_impl, t);
[y_par, ~]  = step(G_closed_parallel, t);
[y_cas, ~]  = step(G_closed_cascade, t);

% załaduj dane (twoja funkcja csv_parse powinna już być w skrypcie)
[wyjscie_norm, time_vector] = csv_parse(filename1);

% porównanie steady-state (ostatnie 20 próbek)
sim_ss_impl = mean(y_impl(end-19:end));
sim_ss_par  = mean(y_par(end-19:end));
sim_ss_cas  = mean(y_cas(end-19:end));
data_ss = mean(wyjscie_norm(end-19:end));

fprintf('Steady-state: data=%.4f, impl=%.4f, parallel=%.4f, cascade=%.4f\n', ...
    data_ss, sim_ss_impl, sim_ss_par, sim_ss_cas);

% błąd offsetu (data - sim)
err_impl = data_ss - sim_ss_impl;
err_par  = data_ss - sim_ss_par;
err_cas  = data_ss - sim_ss_cas;
fprintf('Offset errors (data - sim): impl=%.4f, parallel=%.4f, cascade=%.4f\n', err_impl, err_par, err_cas);

% rysuj porównanie na jednym wykresie
figure; hold on;
plot(time_vector(1:50:end), wyjscie_norm(1:50:end), 'bo', 'DisplayName','Dane pomiarowe');
plot(t, y_impl, 'r-', 'LineWidth', 1.2, 'DisplayName','Impl (feedbackEach * cascade)');
plot(t, y_par, 'g--', 'LineWidth', 1.2, 'DisplayName','Parallel (G1+G2)');
plot(t, y_cas, 'm-.', 'LineWidth', 1.2, 'DisplayName','Cascade (G1*G2)');
xlabel('Czas [s]'); ylabel('h(t)');
legend('Location','best'); grid on; title('Porównanie topologii modelu z danymi');
hold off;


%% --- FUNKCJA WCZYTANIA I NORMALIZACJI ---
function [wyjscie, time_vector] = csv_parse(filename)
    % Wczytaj dane, pomijając nagłówki (od 3 wiersza)
    data = csvread(filename, 2, 0);
    time_vector = data(3:end, 1);
    wejscie = data(3:end, 2);
    wyjscie_raw = data(3:end, 3);
    
    % Wyrównanie czasu
    time_vector = time_vector - time_vector(1);
    dt = time_vector(2) - time_vector(1);

    % Znajdź moment skoku na wejściu
    idx_step = find(abs(wejscie - wejscie(1)) > 0.3, 1);
    if isempty(idx_step)
        error('Nie znaleziono momentu skoku w danych.');
    end

    % Oblicz wartość skoku
    du = mean(wejscie(end-25:end)) - mean(wejscie(1:25));
    fprintf("Wartość skoku na wejściu: %.4f\n", du);

    % Przytnij i przeskaluj sygnał
    wyjscie_cut = wyjscie_raw(idx_step:end);
    wyjscie_cut = (wyjscie_cut - wyjscie_cut(1)) / du;

    % Normalizacja względem końcowej wartości
    h_inf = mean(wyjscie_cut(end-50:end));
    wyjscie = wyjscie_cut / h_inf;

    % Ustal wektor czasu po przycięciu
    time_vector = (0:length(wyjscie)-1) * dt;
end