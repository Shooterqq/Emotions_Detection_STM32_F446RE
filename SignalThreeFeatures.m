% Function to feature Respiration signal

function SignalThreeFeatures = SignalThreeFeatures(file_path)

fs = 1000;
RESP_FEATURES_SIGNAL = [];

data = load(file_path);
data = data.data;


for signal_idx = 1:length(data) % wczytywanie po sygnale do analizy
    signal = data(signal_idx); % przypisanie sygnalu do zmiennej
    
    
    % Znalezienie maksimów sygnału o zadanej szerokości szczytu 0,83 hz
    %     [peaks, locs] = findpeaks(signal.signal3,fs,'MinPeakWidth',0.2, 'MinPeakDistance', 0.95);
    [peaks, locs] = findpeaks(signal.signal3, fs, 'MinPeakWidth', 0.495, 'MinPeakDistance', 0.95, 'MinPeakHeight', mean(signal.signal3));
    
    % ilosc od szczytu do 1 szczytu do ostatniego -1 // czas = ilosc oddechow
    
    % Oblicz odstępy RR (czas między kolejnymi szczytami)
    rr_intervals = diff(locs) / fs;
    
    % Oblicz średnią długość odstępu RR
    mean_rr_interval = mean(rr_intervals);
    
    % Oblicz kwadraty różnic
    squared_diffs = (rr_intervals - mean_rr_interval) .^ 2;
    
    % Zsumuj kwadraty różnic
    sum_squared_diffs = sum(squared_diffs);
    
    % Oblicz SDNN
    SDNN = sqrt(sum_squared_diffs / (length(rr_intervals) - 1));
    
    % Obliczenie ilosci oddechow wykonywanych w ciagu minuty
    signal_mins = (locs(end) - locs(1))/60; % Obliczenie czasu sygnalu w minutach
    resp_per_min = (length(locs)/signal_mins) - 1; % Obliczenie ilosci oddechów na minutę
    
    mean_resp_amp = mean(peaks);
    
    mean_resp_signal = mean(signal.signal3);
    
    % Mediana z szczytów
    medpeaks = median(peaks);
    
    % Obliczenie Średnie Bezwzględne Odchylenie (MAD) amplitud od szczytu do szczytu (PPA)
    PPAmad = (1/length(peaks)) * sum(abs(peaks - medpeaks));
    
    
    RESP_FEATURES_SIGNAL = [RESP_FEATURES_SIGNAL; resp_per_min,...
        data(signal_idx).emotion, data(signal_idx).id, SDNN, mean_resp_amp, mean_resp_signal, PPAmad];
    
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













