clear all;
close all;
clc;


% Inicjalizacja struktury
data = struct();

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
        if size(file_data, 2) == 17
            % Zapisanie danych do struktury
            
            % Filtracja i zapis sygnału EDA
            data(i).signal1 = file_data(:, 2);
            data(i).signal1 = EDA_Filters(data(i).signal1);
            
            % Filtracja i zapis sygnału EKG
            data(i).signal2 = file_data(:, 4);
            data(i).signal2 = data(i).signal2;
            
            % Filtracja i zapis sygnału respiracji
            data(i).signal3 = file_data(:, 6);
            data(i).signal3 = RESP_Filters(data(i).signal3);
            data(i).signal3 = Wavelet_Filters(data(i).signal3);
            
            % Filtracja i zapis sygnału respiracji
            data(i).signal4 = file_data(:, 8);
            
            % Filtracja i zapis sygnału respiracji
            data(i).signal5 = file_data(:, 10);
            
            
            % Zapis metadanych dotyczących sygnału
            data(i).age = file_data(1, 11);
            data(i).height = file_data(1, 12);
            data(i).weight = file_data(1, 13);
            data(i).gender = file_data(1, 14);
            data(i).fs = file_data(1, 15);
            data(i).emotion = file_data(1, 16);
            data(i).id = file_data(1, 17);
            
            % Wizualizacja wyfiltrowanych sygnałów
            %             grid on;
            %             plot(data(i).signal3);
            %             hold on;
            %             plot(data(i).signal2);
            %             plot(data(i).signal1);
            %
            %             findpeaks(data(i).signal3, fs, 'MinPeakWidth', 0.495, 'MinPeakDistance', 0.95, 'MinPeakHeight', mean(data(i).signal3));
            %             grid on;
            
        else
            fprintf('Nieprawidłowy format pliku: %s\n', files(i).name);
        end
    catch
        fprintf('Błąd odczytu pliku: %s\n', files(i).name);
    end
end

save("data.mat", "data");


% % Wygenerowanie wektora czasu dla całego sygnału
% t = (0:length(data(4).signal2)-1) / fs;
%
% % Określenie zakresu czasu do wyświetlenia (od 40 do 90 sekundy)
% start_time = 50; % Sekundy
% end_time = 80;   % Sekundy
%
% % Indeksowanie fragmentu sygnału w wybranym zakresie czasu
% idx = (t >= start_time) & (t <= end_time);
% t_subset = t(idx);
% output_LPF_subset = data(5).signal2(idx);
% orginalecg_subset = data(5).signal6(idx);
%
% % qw = data(2).signal2(idx);
% % we = data(2).signal6(idx);
%
% % Narysowanie wykresu sygnału w wybranym zakresie czasu
% figure;
% plot(t_subset, output_LPF_subset);
% hold on;
% plot(t_subset, orginalecg_subset);
%
% % plot(t_subset, qw);
% % plot(t_subset, we);
%
% % Ustawienie etykiety dla osi x
% xlabel('Czas [s]');
%
% % Ustawienie etykiety dla osi y
% ylabel('Amplituda');
%
% % Dodanie tytułu wykresu
% title('Sygnał po filtracji (od 70 s do 80 s)');






