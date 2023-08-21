% Glowny plik wykonawczy do ekstrakcji cech 

% Rozpoczęcie pomiaru czasu trwania programu
tic;

clear all;
close all;
clc;

file_path = 'data.mat';


% SignalOneFeatures = SignalOneFeatures(file_path);
SignalTwoFeatures = SignalTwoFeatures(file_path);
SignalThreeFeatures = SignalThreeFeatures(file_path);






% Zakończenie pomiaru czasu
elapsed_time = toc;

fprintf('Czas wykonania kodu: %.4f sekund\n', elapsed_time);














