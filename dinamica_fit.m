clear;
close all;

%voglio trovare funzione di trasfermineto V/Accellerazione (nei file scope l'acellerazione è un impulso quindi il segnale è la funzione di trasferimento)
fileName="scope (5).csv";
% Leggi il file CSV saltando le prime due righe

opts = detectImportOptions(fileName, 'NumHeaderLines', 2);
opts.SelectedVariableNames = [1, 2];
data = readtable(fileName, opts);

% Estrai le colonne x e y
t = data{:, 1}; % Prima colonna
V = data{:, 2}; % Seconda colonna
% Definizione della funzione polinomiale inversa (dall'interpolazione precedente)
% Sostituire con i coefficienti trovati corretti
p_inv = [ 0.0008,-0.0153,0.0575]; % Coefficienti di esempio
f_inv = @(v) p_inv(1)*v.^2 + p_inv(2)*v + p_inv(3);

% 2. Convertire il voltaggio in posizione usando la funzione trovata in precedenza
posizione = f_inv(V);


data=[t posizione];



TempReg = data;


len=length(TempReg);

%***************************FILTRAGGIO*****************************************

fc = len/(TempReg(end,1)-TempReg(1,1));
ft = 0.5;


[Num,Den] = butter(3, ft/(fc/2));     % Calcolo dei coefficienti di un filtro di Butterworth  

TempRegFil = filtfilt(Num,Den,TempReg(:,2)); % Filtraggio senza introduzione di ritardo


%***************************************************************************************

		figure
		plot(TempReg(:,1),TempReg(:,2));
		title('Andamento con sistema a regime');
		xlabel('tempo [s]');
		ylabel('posizone');

		hold on;
		plot(TempReg(:,1),TempRegFil,'m','LineWidth',2); %Visualizzazione dati filtrati
        legend('Dati originali','Dati Filtrati')
		grid on


%*****************************************************************************************
%======   Utilizzo della trasformata  per la compensazione dinamica =======
%*****************************************************************************************


FreqCicliFil = fft(TempRegFil)/ len; % Trasformata di Fourier del segnale filtrato

% Definizione del vettore delle frequenze:
t = 1:len;
f = linspace(-1, ceil(fc/2), ceil(len/2));
fneg = -fliplr(f(2:end));
fplot = [fneg f];

%********************** Visualizzazione del modulo della trasformata ***********************

		figure
		plot(fplot,abs(FreqCicliFil));      
		grid on
		title('Trasformata di Fourier del segnale filtrato');
		xlabel('frequenza [Hz]');
		ylabel('modulo');
		set(gca,'YScale','log')



%======= Costante di tempo per sistema primo ordine ==========

wn=77.35;
epsilon=0.02;
num = [1/wn^2];
den = [1/wn^2, 2*epsilon/wn, 1];
w=2i*pi*fplot;

FreqInvSonda = num/(w^2*den(1)+w*den(2)+den(3));%1 + 2i*pi*fplot'*tau;   % Calcolo della funzione di trasferimento inversa per frequenze positive

    %************************ Diagrmma di bode della FdT inversa ***********************************************************
		figure
		subplot(2,1,1)
        Mod = abs(FreqInvSonda);
        %Mod = Mod(end/2:end);
		plot(fplot , Mod)
		set(gca,'XScale','log')
		title('Modulo della funzione inversa ');
		grid on
		subplot(2,1,2)
        Fase = angle(FreqInvSonda)*180/pi;
        %Fase = Fase(end/2:end);
		plot(fplot, Fase)
        set(gca,'XScale','log')
		title('Fase della funzione inversa ');
		xlabel('frequenza [Hz]');
		grid on

                                             
%*****************************************************************************************
%===========   Qui avviene la compensazione della dinamica     ==============
%*****************************************************************************************

% Calcolo della trasformata di Fourier del segnale di temperatura all'ingresso
% della sonda (Inversione della dinamica)

FreqIngSonda = -FreqCicliFil.*FreqInvSonda;     
                                             
TempIngSonda = ifft(FreqIngSonda); % Antitrasformata di Fourier del segnale di temperatura

%*****************************************************************************************
                                             
		figure 
		plot(TempReg(:,1),TempReg(:,2));         % Visualizzazione dei risultati
		hold on
		plot(TempReg(:,1),(sign(real(TempIngSonda)).*abs(TempIngSonda)),'r','LineWidth',2);
		
		
		title('Inversione della dinamica');
        legend('Dati originali','Dati compensati')
		xlabel('tempo [s]');
		ylabel('Volt [V]');
		grid on
