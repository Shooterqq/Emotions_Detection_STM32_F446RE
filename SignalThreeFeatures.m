% Function to feature Respiration signal 

function SignalThreeFeatures = SignalThreeFeatures(file_path)

fs = 1000;
RESP_FEATURES_SIGNAL = [];

data = load(file_path);
data = data.data;


for signal_idx = 1:length(data) % wczytywanie po sygnale do analizy
    signal = data(signal_idx); % przypisanie sygnalu do zmiennej
    
    % Określenie minimalnego dystansu między szczytami (1750 próbek ~ 0.57Hz)
    min_distance = fs * 1.7;
    
    % Znajdź lokalne maksima w sygnale
    
    [peaks, locs] = findpeaks(signal.signal3, 'MinPeakDistance', min_distance, 'MinPeakHeight', mean(signal.signal3));
    
    % Znalezienie maksimów sygnału o zadanej szerokości szczytu 0,83 hz
    [peaks, locs] = findpeaks(signal.signal3,fs,'MinPeakWidth',0.2, 'MinPeakDistance', 0.95);
    
    % ilosc od szczytu do 1 szczytu do ostatniego -1 // czas = ilosc oddechow
    
    % Obliczenie ilosci oddechow wykonywanych w ciagu minuty
    signal_mins = (locs(end) - locs(1))/60; % Obliczenie czasu sygnalu w minutach
    resp_per_min = (length(locs)/signal_mins) - 1; % Obliczenie ilosci oddechów na minutę
    
    
    RESP_FEATURES_SIGNAL = [RESP_FEATURES_SIGNAL; resp_per_min, data(signal_idx).emotion, data(signal_idx).id];
    
    save("RESP_FEATURES_SIGNAL.mat", "RESP_FEATURES_SIGNAL");

    
%     m = mean(signal.signal3);   % średnia
%     s = std(signal.signal3);    % odchylenie standardowe
%     skew = sum((signal.signal3 - m).^3) / ((length(signal.signal3)-1) * s^3); % skośność
%     med = median(signal.signal3); % mediana
%     kurt = sum((signal.signal3 - m).^4) / ((length(signal.signal3)-1) * s^4) - 3; % kurtoza
    
    
%     % wypełnianie wektora klasyfikującego i referencyjnego
%     RESP_FEATURES = [RESP_FEATURES; m, s, skew, med, kurt];
%     EmotionVector_RESP = [EmotionVector_RESP; data(signal_idx).emotion];
%     
%     
%     save("RESP_FEATURES.mat", "RESP_FEATURES");
%     save("EmotionVector_RESP.mat", "EmotionVector_RESP");
    
end

SignalThreeFeatures = RESP_FEATURES_SIGNAL;

end













