% Glowny plik wykonawczy do obserwacji wyników 

clear all;
close all;
clc;



file_path = 'data.mat';

% Obliczanie wektora cech dla kazdej dlugosci fali
SignalOneFeatures = SignalOneFeatures(file_path);
SignalTwoFeatures = SignalTwoFeatures(file_path);
SignalThreeFeatures = SignalThreeFeatures(file_path);
SignalFourFeatures = SignalFourFeatures(file_path);
SignalFiveFeatures = SignalFiveFeatures(file_path);

