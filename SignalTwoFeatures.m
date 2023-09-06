% Function to feature ECG signal

function SignalTwoFeatures = SignalTwoFeatures(file_path)


%% ----- Wczytanie sygnału do analizy oraz deklaracja zmiennych ----- %%

fs = 1000;
ECG_FEATURES_SIGNAL = [];

data = load(file_path);
data = data.data;

%% ----- Analiza sygnałów EKG (ECG) dla każdej z emocji ----- %%

for signal_idx = 1:length(data) % wczytywanie po sygnale do analizy
    signal = data(signal_idx); % przypisanie sygnalu do zmiennej
    
    
    %% ---- Wyznaczanie załamków R z wykorzystaniem DWT (Discrete Wavelet Transform) ---- %%
    
    % Normalizacja sygnału EKG
    ecgsig = (signal.signal2)/200; % Normalizacja wzmocnienia
    t = 1:length(ecgsig); % Wektor czasu
    
    % Analiza za pomocą Dyskretnej Transformacji Falkowej (DWT)
    wt = modwt(ecgsig, 4, 'sym4'); % DWT z wykorzystaniem falki sym4
    wtrec = zeros(size(wt)); % Inicjalizacja wektora rekonstrukcji falkowej
    wtrec(3:4, :) = wt(3:4, :); % Zachowanie określonej skali falkowej
    
    % Rekonstrukcja sygnału po DWT
    y = imodwt(wtrec, 'sym4'); % Odwrotna Transformacja Falkowa
    y = abs(y).^2; % Kwadrat wartości amplitudy
    avg = mean(y); % Średnia wartość kwadratu
    
    if avg > 0.15
        
        [Rpeaks, Rlocs] = findpeaks(y, t, 'MinPeakHeight',...
            4 * avg, 'MinPeakDistance' , 50); % Wyszukanie pików R
        nohb = length(Rlocs);
        timelimit = length(ecgsig)/fs; % Czas trwania sygnału w sekundach
        QRS_per_min = (nohb * 60) / timelimit; % Liczba pików R na minutę
        
    else
        
        %% --- Wyznaczanie załamków R z wykorzystaniem algorytmu Pan-Tompkins --- %%     
        [Rpeaks, Rlocs, delay] = pan_tompkin(signal.signal2, fs, 0);
        signal_QRS = length(signal.signal2)/(fs*60); % Obliczenie czasu sygnału w minutach
        QRS_per_min = length(Rpeaks)/signal_QRS; % Liczba pików R na minutę
        
    end
    
    %% --- Wyznaczanie HRV (Heart Rate Variability) --- %%
    
      
    RR_diff = diff(Rlocs);% Obliczanie różnic między odstępami R-R
    mean_RR_diff = mean(RR_diff); % Obliczanie średnniej różnic między załamkami R-R
    
    
    % Obliczanie SDNN (Standard Deviation of NN Intervals)
    sum_squared_RR_diff = sum((RR_diff - mean_RR_diff).^2);
    SDNN = sqrt(sum_squared_RR_diff / (length(RR_diff) - 1));
    
    
    % Obliczanie RMSSD (Root Mean Square of Successive Differences)
    squared_RR_diff = (RR_diff - mean_RR_diff).^2;
    RMSSD = sqrt(mean(squared_RR_diff));
    
    % Obliczanie pRR50 (Percentage of RR Intervals > 50 ms)
    RR50_count = sum(abs(RR_diff) > 50);
    pRR50 = (RR50_count / length(RR_diff)) * 100;
    
    % Mediana z szczytów
    medpeaks = median(Rpeaks);
    
    % Obliczenie Średnie Bezwzględne Odchylenie (MAD) amplitud od szczytu do szczytu (PPA)
    PPAmad = (1/length(Rpeaks)) * sum(abs(Rpeaks - medpeaks));
    
    
    % Tworzenie macierzy parametrów klasyfikujących
    ECG_FEATURES_SIGNAL = [ECG_FEATURES_SIGNAL; QRS_per_min, SDNN,...
        data(signal_idx).emotion, data(signal_idx).id, PPAmad];
    
%     id_string = sprintf('%03s', data(signal_idx).id); % Zamiana liczby na łańcuch o długości 3 z wiodącymi zerami
%     ECG_people = [ECG_people; str2str(data(signal_idx).id)];

    
    save("ECG_FEATURES_SIGNAL.mat", "ECG_FEATURES_SIGNAL");
%     save("ECG_people.mat", "ECG_people");
    
    %% ----- Podział sygnału na okna do analizy ----- %%
    
    
    %     window_len_s = 5; % czas okna w s
    %     window_len_samples = window_len_s * fs;
    %     overlapp_percent = 50; % proc nakładania sie okien
    %
    %     [windows_ECG, ~] = buffer(signal.signal2, window_len_samples, floor(window_len_samples * overlapp_percent / 100), 'nodelay'); % podzielenie sygnalu na okna
    %     [~, windows_count] = size(windows_ECG); %wyznaczenie ilosci okien z sygnału
    %
    %
    %     for i = 1:windows_count
    %         window = windows_ECG(:,i);
    %
    %         [qrs_amp_raw, qrs_i_raw, delay] = pan_tompkin(window, 1000, 0);
    %
    %         m = mean(window);   % średnia
    %         s = std(window);    % odchylenie standardowe
    %         skew = sum((window - m).^3) / ((length(window)-1) * s^3); % skośność
    %         med = median(window); % mediana
    %         kurt = sum((window - m).^4) / ((length(window)-1) * s^4) - 3; % kurtoza
    %
    %
    %         % wypełnianie wektora klasyfikującego i referencyjnego
    %         ECG_FEATURES = [ECG_FEATURES; m, s, skew, med, kurt, QRS_per_min, SDNN, data(signal_idx).emotion];
    %         EmotionVector_ECG = [EmotionVector_ECG; data(signal_idx).emotion];
    %
    %     end
    %
    %     save("ECG_FEATURES.mat", "ECG_FEATURES");
    %     save("EmotionVector_ECG.mat", "EmotionVector_ECG");
    
end

SignalTwoFeatures = ECG_FEATURES_SIGNAL;

end












