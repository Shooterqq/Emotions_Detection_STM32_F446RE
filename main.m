% Glowny plik wykonawczy do obserwacji wyników 

clear all;
close all;
clc;



file_path = 'data.mat';

% Obliczanie wektora cech dla kazdej dlugosci fali
SignalToFeatures = SignalToFeatures(file_path);

