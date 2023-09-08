% Glowny plik wykonawczy do ekstrakcji cech

% Rozpoczęcie pomiaru czasu trwania programu
tic;

clear all;
close all;
clc;

%% ----------- Ekstrakcja parametrów klasyfikujących ----------- %%

file_path = 'data.mat';

SignalOneFeatures = SignalOneFeatures(file_path);
SignalTwoFeatures = SignalTwoFeatures(file_path);
SignalThreeFeatures = SignalThreeFeatures(file_path);

%% -------- Tworzenie macierzy z wszystkimi parametrami -------- %%

% Wczytanie obliczonych parametrów
load('data.mat');
load('Features_EDA.mat');
load('ECG_FEATURES_SIGNAL.mat');
load('RESP_FEATURES_SIGNAL.mat');


% Stworzenie macierzy z danymi
data_matrix = [RESP_FEATURES_SIGNAL(:, 1), ECG_FEATURES_SIGNAL(:, 1:2),...
    Features_EDA(:, 1:4), Features_EDA(:, 6), Features_EDA(:, 5)...
     RESP_FEATURES_SIGNAL(:, 3:8), ECG_FEATURES_SIGNAL(:, 5:6)];

%% ------ Usunwanie wybranych emocji z macierzy parametrów ------ %%
 
values_to_remove = [3,1,2,4,6]; % Wybierz emocje do usunięcia

% Indeks kolumny, w której sprawdzamy wartości
column_index = 8;

% Tworzenie wektora logicznego wskazującego, które wiersze mają wartości do usunięcia
rows_to_remove = ismember(data_matrix(:, column_index), values_to_remove);

% Usuwanie wierszy
filtered_data_matrix = data_matrix(~rows_to_remove, :);

%% ---------- Usuwanie osoby z macierzy z pomocą ID ---------- %%

values_to_remove_from_column_9 = [15]; % podaj ID osoby do usunięcia

% Indeks kolumny 9
column_index_9 = 9;

% Tworzenie wektora logicznego wskazującego, które wiersze mają wartości do usunięcia z kolumny 9
rows_to_remove_column_9 = ismember(filtered_data_matrix(:, column_index_9),...
    values_to_remove_from_column_9);

% Usuwanie wierszy z kolumny 9
filtered_data_matrix = filtered_data_matrix(~rows_to_remove_column_9, :);


%% -------- Normalizacja danych (nie używane) ---------------- %%

% % Indeksy kolumn do znormalizowania (wszystkie poza kolumnami 8 i 9)
% columns_to_normalize = setdiff(1:size(filtered_data_matrix, 2), [8, 9]);
%
% % Znormalizuj wybrane kolumny za pomocą funkcji zscore
% normalized_data = zscore(filtered_data_matrix(:, columns_to_normalize));
%
% % Zaktualizuj znormalizowane dane w macierzy filtered_data_matrix
% filtered_data_matrix(:, columns_to_normalize) = normalized_data;

%% ------- Tworzenie tabeli do Classification Learner ------ %%

% Tworzenie tabeli z danymi
data_table = table(filtered_data_matrix(:, 1:7),...
    categorical(filtered_data_matrix(:, 8)),...
    categorical(filtered_data_matrix(:, 9)),...
    filtered_data_matrix(:, 10:16));

% % Zapisanie tabeli do pliku CSV
% writetable(data_table, 'dane_classificationlearner.csv');

%% ------- Tworzenie macierzy do Pattern Recognition ------- %% 

% 1,2,4,7,11,13,14
% Tworzenie macierzy parametrów wejściowych do aplikacji 
% Neural Net Pattern Recognition
pattern_data_matrix_in = [filtered_data_matrix(:, 1:2),...
    filtered_data_matrix(:, 4), filtered_data_matrix(:, 7),filtered_data_matrix(:, 11),...
    filtered_data_matrix(:, 13)];


% Tworzenie macierzy parametrów WYJSCIOWYCH do aplikacji 
% Neural Net Pattern Recognition
emotions = filtered_data_matrix(:, 8);
pattern_data_matrix_out = []';

for i = 1:length(emotions)
    
    switch emotions(i)
        case 0
            pattern_data_matrix_out = [pattern_data_matrix_out; [1, 0]];
        case 5
            pattern_data_matrix_out = [pattern_data_matrix_out; [0, 1]];
%         case 6
%             pattern_data_matrix_out = [pattern_data_matrix_out; [0, 0, 1]];
        otherwise
            disp("Błąd w danych");
    end
end

%%

% Zakończenie pomiaru czasu
elapsed_time = toc;

fprintf('Czas wykonania kodu: %.4f minut\n', elapsed_time/60);









































