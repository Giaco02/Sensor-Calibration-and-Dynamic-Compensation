clear;
close all;
% 1. Caricamento dei dati dal file CSV
fileName = "scope (6).csv";
opts = detectImportOptions(fileName, 'NumHeaderLines', 2);
opts.SelectedVariableNames = [1, 2];
data = readtable(fileName, opts);

% Supponiamo che le colonne si chiamino 'Tempo' e 'Volt'
tempo = data{:, 1}; % Prima colonna: tempo
volt = data{:, 2}; % Seconda colonna: voltaggio

% Definizione della funzione polinomiale inversa (dall'interpolazione precedente)
% Sostituire con i coefficienti trovati corretti
p_inv = [ 0.0015   -0.0254    0.0878]; % Coefficienti di esempio
f_inv = @(v) p_inv(1)*v.^2 + p_inv(2)*v + p_inv(3);
% 2. Convertire il voltaggio in posizione usando la funzione trovata in precedenza
posizione = f_inv(volt);


%filtro
fs = 1/mean(diff(tempo)); % Frequenza di campionamento (Hz), assumendo intervallo uniforme
cutoff = 25; % Frequenza di taglio (Hz)
order = 4; % Ordine del filtro

% Progettazione del filtro Butterworth
[b, a] = butter(order, cutoff / (fs / 2), 'low');
posizione = filter(b, a, posizione);


% 3. Eseguire la trasformata di Fourier sui dati convertiti (posizione)
n = length(posizione);
Y = fft(posizione)/n;
%f = (0:n-1)*(fs/n); % Vettore delle frequenze

f = linspace(-1, ceil(fs/2), ceil(n/2));
fneg = -fliplr(f(1:end));
f = [fneg f]; 

% Definizione della funzione di trasferimento
wn=77.35;
epsilon=0.02;
num = [1/wn^2];
den = [1/wn^2, 2*epsilon/wn, 1];
G_inv = tf(den,num);
[mag, phase, w] = bode(G_inv, 2*pi*f);  % Calcolo della risposta in frequenza
mag = squeeze(mag);  % Rimuove dimensioni singleton dalla magnitudine
phase = squeeze(phase);  % Rimuove dimensioni singleton dalla fase

unwrapped_phase = unwrap(phase * pi/180) * 180/pi;  % Unwrap della fase mantenendo i gradi

% Conversione della fase smarginata da gradi a radianti per il calcolo complesso
unwrapped_phase_rad = unwrapped_phase * pi/180;

G_inv_complex = mag .* exp(1i * unwrapped_phase_rad);  % Crea la rappresentazione complessa


% 5. Moltiplicare la trasformata di Fourier dei dati convertiti per l'inversa della funzione di trasferimento
Y_mod = Y .* G_inv_complex;
% figure;
% 
% Plot magnitude in dB
% subplot(2, 1, 1);
% semilogx(w, 20 * log10(abs(Y)));
% xlabel('Frequency (rad/s)');
% ylabel('Magnitude (dB)');
% title('Transfer Function Magnitude (dB)');
% grid on;
% 
% Plot phase
% subplot(2, 1, 2);
% semilogx(w, angle(Y)*180/pi);
% xlabel('Frequency (rad/s)');
% ylabel('Phase (radians)');
% title(' Transfer Function Phase');
% grid on;

% bode(G_inv);
% 6. Eseguire l'antitrasformata di Fourier sui dati risultanti (per ottenere accelerazione)
acceleration = ifft(Y_mod);

% %7. Visualizzare i risultati
figure;
plot(tempo, real(acceleration));
xlabel('Tempo (s)');
ylabel('Accelerazione (m/s^2)');
title('Signal after inverse Fourier transform (Acceleration)');
grid on;

figure;
subplot(2, 1, 1);
plot(tempo, volt);
xlabel('Tempo (s)');
ylabel('Volt');
title('Volt');
grid on;

subplot(2, 1, 2);
plot(tempo, posizione);
xlabel('Tempo (s)');
ylabel('Posizione (m)');
title('Position');
grid on;



% 1. Caricamento dei dati dal file CSV
file_path = 'g_5.csv';
data = readtable(file_path);

% Supponiamo che le colonne si chiamino 'Tempo', 'Accel_x', 'Accel_y', 'Accel_z'
tempo = data{:, 1}; % Prima colonna: tempo
accel_x = data{:, 2}; % Seconda colonna: accelerazione x
accel_y = data{:, 3}; % Terza colonna: accelerazione y
accel_z = data{:, 4}; % Quarta colonna: accelerazione z

% 2. Visualizzare le accelerazioni per ciascuna coordinata
figure;

%subplot(3, 1, 3);
plot(tempo, accel_z);
xlabel('Tempo (s)');
ylabel('Accelerazione Z (m/s^2)');
title('real acceleration Z');
grid on;
