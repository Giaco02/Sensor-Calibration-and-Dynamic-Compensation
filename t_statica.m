% 1. Caricamento dei dati dal file Excel
file_path = 't_statica.xlsx';
data = readtable(file_path);

% Specifica l'intervallo di celle da leggere
rangey = 'A2:A21';
rangex = 'C2:C21';

% Leggi i dati dal file Excel
posizione = readmatrix(file_path, 'Range', rangey);
voltaggio = readmatrix(file_path, 'Range', rangex);

% 2. Interpolazione dei dati (voltaggio -> posizione)
p_inv = polyfit(voltaggio, posizione, 2);

% 3. Visualizzazione della funzione polinomiale inversa
disp('Coefficiente del polinomio inverso:');
disp(p_inv);

% Definizione del polinomio inverso
f_inv = @(v) p_inv(1)*v.^2 + p_inv(2)*v + p_inv(3);

% Visualizzazione della funzione inversa
disp('Funzione di taratura inversa tra voltaggio (input) e posizione (output):');
disp(f_inv);

% Creazione di un vettore di voltaggi per il grafico del polinomio inverso
voltaggio_fit = linspace(min(voltaggio), max(voltaggio), 100);
posizione_fit = polyval(p_inv, voltaggio_fit);

% 4. Grafico dei dati originali e del polinomio inverso interpolato
figure;
scatter(voltaggio, posizione, 'filled');
hold on;
plot(voltaggio_fit, posizione_fit, 'r-', 'LineWidth', 2);
xlabel('Voltaggio del sensore');
ylabel('Posizione della mensola');
title('Interpolazione polinomiale inversa di secondo grado');
legend('Dati originali', 'Polinomio inverso di secondo grado', 'Location', 'Best');
grid on;
hold off;
