% Function to feature EDA signal

function SignalOneFeatures = SignalOneFeatures(file_path)

%% ----- Wczytanie sygnału do analizy oraz deklaracja zmiennych ----- %%

fs = 1000;
Features_EDA = [];

data = load(file_path);
data = data.data;


%% ----- Analiza sygnałów EDA dla każdej z emocji ----- %%


for signal_idx = 1:length(data) % wczytywanie po sygnale do analizy
    signal = data(signal_idx); % przypisanie sygnalu do zmiennej
    signal.signal1  = signal.signal1(100:end); % Usunięcie zakłóconego fragmentu sygnału przez filtr LPF
    
    normalized_signal = zscore(signal.signal1); % Normalizacja sygnał EDA (zalecane)
    
    %% ----- Separacja sygnału na składową toniczną i fazową ----- %%
    
    % Ustalenie parametrów dla funkcji cvxEDA
    tau0 = 1.2;       % slow time constant of the Bateman function
    tau1 = 0.01;       % fast time constant of the Bateman function
    delta_knot = 2.97;  % time between knots of the tonic spline function
    alpha = 0.005;   % penalization for the sparse SMNA driver
    gamma = 0.1;     % penalization for the tonic spline coefficients
    solver = 'quadprog'; % sparse QP solver to be used, 'quadprog' or 'sedumi'
    
    % Wywołanie funkcji cvxEDA do analizy sygnału
    [r, p, t, l, d, e, obj] = cvxEDA(normalized_signal, 1/fs, tau0, tau1, delta_knot, alpha, gamma, solver);
    
    %% --------------------- Ekstrakcja cech --------------------- %%
    
    % Znalezienie maksimów sygnału fazowego o zadanej szerokości szczytu
    [peaks, locs] = findpeaks(r,fs,'MinPeakWidth',0.2);
    
    % Obliczenie wartości średnich składowej tonicznej i fazowej
    mean_t = mean(t);
    mean_r = mean(r);
    
    % Obliczenie ilości maksimów powyżej ustalonego progu detekcji (0.2)
    peak_tab = 0;
    
    for peakses = 1:length(peaks)
        peak = peaks(peakses);
        
        threshold = 1; % Ustalony prog detekcji maksimów
        
        if peak > threshold 
            
            peak_tab = peak_tab+1;
            
        end       
    end
    
    signal_mins = length(signal.signal1)/(fs*60); % Obliczenie czasu sygnalu w minutach
    
    num_peaks = length(peaks); % Ilość znalezionych maksimów
    peaks_per_min = num_peaks/signal_mins; % Obliczenie ilosci oddechów na minutę
    
    mean_peaks_amplitude = mean(peaks); % Średnia amplituda znalezionych maksimow
    mean_peaks_amplitude_per_min =  mean_peaks_amplitude/signal_mins; % Średnia amplituda znalezionych maksimow na minutę
    
    std_peaks = std(peaks); % Odchylenie standardowe maksimów
    std_peak_per_min = std_peaks/signal_mins; % Odchylenie standardowe maksimów na minutę
    
    kurt = sum((peaks - mean_peaks_amplitude).^4) / ((num_peaks-1) * std_peaks^4) - 3; % kurtoza maksimów
    
    high_peaks_per_min = peak_tab/signal_mins; % ilość maksimow powyzej ustalonego progu detekcji (threshold = 1) na minutę
    
    mean_r_per_min = mean_r/signal_mins; % Wartość srednia składowej fazowej na minutę
    
    % Tworzenie macierzy parametrów klasyfikujących
    Features_EDA = [Features_EDA; peaks_per_min, high_peaks_per_min, ...
        mean_peaks_amplitude_per_min, mean_r_per_min, ...
        data(signal_idx).emotion, data(signal_idx).id];
    
    save("Features_EDA.mat", "Features_EDA");
    
    
    %% ----- Podział sygnału na okna do analizy ----- %%
    %
    %
    %     window_len_s = 5; % czas okna w s
    %     window_len_samples = window_len_s * fs;
    %     overlapp_percent = 50; % proc nakładania sie okien
    %
    %     [windows_SCL, ~] = buffer(t, window_len_samples, floor(window_len_samples * overlapp_percent / 100), 'nodelay'); % podzielenie sygnalu na okna
    %
    %     [windows_SCR, ~] = buffer(r, window_len_samples, floor(window_len_samples * overlapp_percent / 100), 'nodelay'); % podzielenie sygnalu na okna
    %     [~, windows_count] = size(windows_SCR); %wyznaczenie ilosci okien z sygnału
    %
    %
    %     %% ----- Analiza okien składowej fazowej ----- %%
    %
    %
    %     for i = 1:windows_count
    %         window = windows_SCR(:,i);
    %
    %         m = mean(window);   % średnia
    %         s = std(window);    % odchylenie standardowe
    %         skew = sum((window - m).^3) / ((length(window)-1) * s^3); % skośność
    %         med = median(window); % mediana
    %         kurt = sum((window - m).^4) / ((length(window)-1) * s^4) - 3; % kurtoza
    %
    %
    %         % wypełnianie wektora klasyfikującego i referencyjnego
    %         SCR_FEATURES = [SCR_FEATURES; m, s, skew, med, kurt];
    %         EmotionVector_EDA = [EmotionVector_EDA; data(signal_idx).emotion];
    %
    %     end
    %
    %     save("SCR_FEATURES.mat", "SCR_FEATURES");
    %     save("EmotionVector_EDA.mat", "EmotionVector_EDA");
    %
    %
    %      %% ----- Analiza okien składowej tonicznej ----- %%
    %
    %
    %     for i = 1:windows_count
    %         window = windows_SCL(:,i);
    %
    %         m = mean(window);   % średnia
    %         s = std(window);    % odchylenie standardowe
    %         skew = sum((window - m).^3) / ((length(window)-1) * s^3); % skośność
    %         med = median(window); % mediana
    %         kurt = sum((window - m).^4) / ((length(window)-1) * s^4) - 3; % kurtoza
    %
    %
    %         % wypełnianie wektora klasyfikującego
    %         SCL_FEATURES = [SCL_FEATURES; m, s, skew, med, kurt];
    %
    %     end
    %
    %     save("SCL_FEATURES.mat", "SCL_FEATURES");
    %
    
end

SignalOneFeatures = Features_EDA;

end











