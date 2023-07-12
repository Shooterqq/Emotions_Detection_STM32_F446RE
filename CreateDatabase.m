clear all;
close all;
clc;

fs = 1000;
Tp = 1/fs;

load('HPF_ECG.mat');
load('LPF_ECG.mat');
load('matlab.mat');
load('LPF_EDA.mat');

% Inicjalizacja struktury
data = struct('signal1', {}, 'signal2', {}, 'signal3', {}, 'signal4', {}, 'signal5', {}, 'age', {}, 'height', {}, 'weight', {}, 'gender', {});

% Ścieżka do folderu z plikami CSV
folder = 'Signals';

% Lista plików CSV w folderze
files = dir(fullfile(folder, '*.csv'));

% Przetwarzanie każdego pliku
for i = 1:numel(files)
    try
        % Wczytanie danych z pliku CSV jako liczby
        file_data = dlmread(fullfile(folder, files(i).name), ';', 1, 0);
        
        % Sprawdzenie rozmiaru pliku
        if size(file_data, 2) == 14
            % Zapisanie danych do struktury
            data(i).signal1 = file_data(:, 2);
            data(i).signal1 = EDA_Filters(data(i).signal1);
            
            data(i).signal2 = file_data(:, 4);
            data(i).signal2 = MetodaFalkowa2(data(i).signal2);
            
            data(i).signal3 = file_data(:, 6);
            data(i).signal3 = RESP_Filters(data(i).signal3);
            
            data(i).signal4 = file_data(:, 8);
            data(i).signal4 = RESP_Filters(data(i).signal4);
            
            data(i).signal5 = file_data(:, 10);
            data(i).signal5 = RESP_Filters(data(i).signal5);
            
            data(i).age = file_data(1, 11);
            data(i).height = file_data(1, 12);
            data(i).weight = file_data(1, 13);
            data(i).gender = file_data(1, 14);
            
        else
            fprintf('Nieprawidłowy format pliku: %s\n', files(i).name);
        end
    catch
        fprintf('Błąd odczytu pliku: %s\n', files(i).name);
    end
end

save("data.mat", "data");


% Wygenerowanie wektora czasu dla całego sygnału
t = (0:length(data(1).signal2)-1) / fs;

% Określenie zakresu czasu do wyświetlenia (od 70 do 90 sekundy)
start_time = 550; % Sekundy
end_time = 600;   % Sekundy

% Indeksowanie fragmentu sygnału w wybranym zakresie czasu
idx = (t >= start_time) & (t <= end_time);
t_subset = t(idx);
output_LPF_subset = data(1).signal2(idx);

% Narysowanie wykresu sygnału w wybranym zakresie czasu
 plot(t_subset, output_LPF_subset);
 hold on;
% plot(t_subset, output_LPF_subset22);

% Ustawienie etykiety dla osi x
xlabel('Czas [s]');

% Ustawienie etykiety dla osi y
ylabel('Amplituda');

% Dodanie tytułu wykresu
title('Sygnał po filtrze LPF (od 70 s do 90 s)');




