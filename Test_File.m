clear all;
close all;
clc;

load('data.mat')
fs = 1000;
for i=1:length(data)
    ecg = data(i).signal2;
    ecgsig = (ecg)/200; %normalize gain
    t = 1:length(ecgsig);
    tx = t./fs;
    
    wt = modwt(ecgsig, 4, 'sym4');
    wtrec = zeros(size(wt));
    wtrec(3:4, :) = wt(3:4, :);
    
    y = imodwt(wtrec, 'sym4');
    y = abs(y).^2;
    
    avg = mean(y);
    
    [Rpeaks, Rlocs] = findpeaks(y, t, 'MinPeakHeight', 6 * avg, 'MinPeakDistance' , 50);
    
    nohb = length(Rlocs);
    timelimit = length(ecgsig)/fs;
    hbpermin = (nohb * 60) / timelimit;
    disp(strcat('Heart Rate = ', num2str(hbpermin)));


subplot(211)
plot(tx, ecgsig);
xlim([0, timelimit]);
grid on;
xlabel('Seconds')
title('ECG Signal')

subplot(212)
plot(t, y)
grid on;
xlim([0, length(ecgsig)]);
hold on;
plot(Rlocs, Rpeaks, 'ro')
xlabel('Samples')
title(strcat('R Peaks found and Heart Rate: ', num2str(hbpermin)));

end


% ------------Testowanie magnitudy filtrów-----------------%

% Wczytaj filtr FIR lub uruchom skrypt, aby załadować filtr
% HPF_RESPIRATION

% Parametry
fs = 1000;  % Częstotliwość próbkowania
N = 740;% Długość filtru

% Wykreślenie charakterystyki amplitudowej
frequencies = linspace(0, fs/2, 1000);  % Zakres częstotliwości do wykreślenia
[h, w] = freqz(HPF_RESPIRATION, 1, frequencies, fs);  % Obliczenie odpowiedzi częstotliwościowej

% Wykres
figure;
plot(frequencies, 20*log10(abs(h)));  % Wykres w skali decybelowej
title('Charakterystyka Amplitudowa Filtru FIR');
xlabel('Częstotliwość (Hz)');
ylabel('Amplituda (dB)');
grid on;











% Generowanie falki Symlet 4
wname = 'sym4';
[phi, psi, time] = wavefun(wname, 10);

% Wyświetlenie falki
subplot(2, 1, 1);
plot(time, phi);
title('Funkcja \phi (Aproksymująca) Symlet 4');
xlabel('Czas');
ylabel('Amplituda');
grid on;

subplot(2, 1, 2);
plot(time, psi);
title('Funkcja \psi (Detalizująca) Symlet 4');
xlabel('Czas');
ylabel('Amplituda');
grid on;

sgtitle('Falka Symlet 4');




% Wybór numeru próbki początkowej i końcowej dla 60-sekundowego fragmentu
start_sample = 1; % Próbka początkowa
end_sample = start_sample + 60 * fs - 1; % Próbka końcowa (60 sekund przy częstotliwości próbkowania fs)

% Tworzenie wektora czasu
time = (start_sample:end_sample) / fs;

% Wybór fragmentów sygnałów
signal10_fragment = data(i).signal10(start_sample:end_sample);
signal3_filtered_fragment = data(i).signal3(start_sample:end_sample);

% Tworzenie nowego okna wykresu
figure;

% Wykres sygnału signal10 po lewej stronie
subplot(2, 1, 1);
plot(time, signal10_fragment);
title('Sygnał respiracji przed filtracją');
xlabel('Czas [s]');
ylabel('Amplituda [mV]');
grid on;

% Wykres sygnału signal3 po prawej stronie
subplot(2, 1, 2);
plot(time, signal3_filtered_fragment);
title('Sygnał respiracji po filtracji');
xlabel('Czas [s]');
ylabel('Amplituda [mV]');
grid on;

% Dostosowanie rozmiaru wykresu
sgtitle('      Porównanie sygnałów przed oraz po filtracji', 'FontWeight', 'bold');




% Tworzenie wektora czasu dla pierwszych 30 sekund
time = (1:30 * fs) / fs;

% Wybór pierwszych 30 sekund sygnału signal1
signal1_fragment = data(i).signal20(1:30 * fs);

% Wybór pierwszych 30 sekund sygnału signal20
signal20_fragment = data(i).signal1(1:30 * fs);

% Tworzenie nowego okna wykresu
figure;

% Wykres sygnału signal20 po lewej stronie
subplot(2, 1, 1);
plot(time, signal1_fragment);
title('Sygnał EDA przed filtracją');
xlabel('Czas [s]');
ylabel('Amplituda [mV]');
grid on;

% Wykres sygnału signal1 po prawej stronie
subplot(2, 1, 2);
plot(time, signal20_fragment);
title('Sygnał EDA po filtracji');
xlabel('Czas [s]');
ylabel('Amplituda [mV]');
grid on;

% % Dostosowanie rozmiaru wykresu
% sgtitle('Porównanie pierwszych 30 sekund sygnału signal20 i signal1');














% Rysowanie pierwszych 60 sekund trzech sygnałów na jednej osi
figure;

% Sygnał toniczny (t) w niebieskim
plot((1:60*fs)/fs, t(1:60*fs), 'b', 'LineWidth', 2);
hold on;

% Sygnał fazowy (r) w czerwonym
plot((1:60*fs)/fs, r(1:60*fs), 'r', 'LineWidth', 2);

% Znormalizowany sygnał (normalized_signal) w czarnym
plot((1:60*fs)/fs, normalized_signal(1:60*fs), 'k', 'LineWidth', 2);

% Ustawienie etykiet i tytułu wykresu
xlabel('Czas [s]');
ylabel('Amplituda');

% Legenda
legend('Sygnał toniczny (t)', 'Sygnał fazowy (r)', 'Sygnał znormalizowany');

% Ustawienie siatki na wykresie
grid on;

% Przywróć domyślną konfigurację kolorów
set(groot, 'defaultAxesColorOrder', 'remove');

% Wyrównanie legendy
legend('Location', 'Best');






figure;
plot(t/fs, y); % Rysuj sygnał EKG w czasie (os X w sekundach)
hold on;
plot(t(Rlocs)/fs, Rpeaks + 0.05, 'kv', 'MarkerFaceColor', 'k'); % Czarne trójkąty, nieco uniesione (v)
xlabel('Czas [s]');
ylabel('Amplituda');
% title('Sygnał EKG z Wykrytymi Szczytami R');

% Usunięcie ostatnich 0.20 sekundy z wykresu
time_to_remove = 0.20; % Czas do usunięcia (w sekundach)
xlim([min(t/fs), max(t/fs) - time_to_remove]); % Ustawienie zakresu osi X



% Oblicz długość sygnału
signal_length = length(signal.signal2);

% Określ, ile próbek stanowi 1/4 sygnału
one_fourth_length = floor(signal_length / 4);

% Pobierz tylko pierwszą 1/4 sygnału (np. od początku do one_fourth_length)
first_fourth_signal = signal.signal2(1:one_fourth_length);

% Wywołaj funkcję pan_tompkin tylko na pierwszej 1/4 sygnału
[Rpeaks, Rlocs, delay] = pan_tompkin(first_fourth_signal, fs, 1);


figure;
plot(t, signal.signal3); % Rysuj sygnał EKG w czasie (os X w sekundach)
hold on;
% Skaluj locs do indeksów w t
scaled_locs = round(locs * fs); % Skaluj do indeksów czasowych
plot(t(scaled_locs), peaks + 0.05, 'kv', 'MarkerFaceColor', 'k'); % Czarne trójkąty, nieco uniesione (v)
xlabel('Czas [s]');
ylabel('Amplituda ');
title('Sygnał EKG z Wykrytymi Szczytami R');


figure;
plot(t, signal.signal3); % 
hold on;
% Skaluj locs do indeksów w t
scaled_locs = round(locs * fs); % Skaluj do indeksów czasowych
plot(t(scaled_locs), peaks + 0.05, 'kv', 'MarkerFaceColor', 'k'); % Czarne trójkąty, nieco uniesione (v)
xlabel('Czas [s]');
ylabel('Amplituda [mV]');







