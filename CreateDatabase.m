clear all;
close all;
clc;

% Inicjalizacja struktury
data = struct('signal1', {}, 'signal2', {}, 'signal3', {}, 'signal4', {}, 'signal5', {});

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
        if size(file_data, 2) == 10
            % Zapisanie danych do struktury
            data(i).signal1 = file_data(:, [2]);
            data(i).signal2 = file_data(:, [4]);
            data(i).signal3 = file_data(:, [6]);
            data(i).signal4 = file_data(:, [8]);
            data(i).signal5 = file_data(:, [10]);
        else
            fprintf('Nieprawidłowy format pliku: %s\n', files(i).name);
        end
    catch
        fprintf('Błąd odczytu pliku: %s\n', files(i).name);
    end
end

save("data.mat", "data");

