% Function to feature signal

function SignalTwoFeatures = SignalTwoFeatures(file_path)

fs = 1000;
Tp = 1/fs;

SignalTwoFeatures = [];


data = load(file_path);

data = data.data;

for signal_idx = 1:length(data) % wczytywanie po sygnale do analizy
    signal = data(signal_idx); % przypisanie sygnalu do zmiennej
    
    
    t = (0:length(data(1).signal2)-1) / fs;
    
    window_len_s = 10; % czas okna w s
    window_len_samples = window_len_s * fs;
    overlapp_percent = 50; % proc nakładania sie okien
    
    [windows, ~] = buffer(signal.signal2, window_len_samples, floor(window_len_samples * overlapp_percent / 100), 'nodelay'); % podzielenie sygnalu na okna
    [~, windows_count] = size(windows); %wyznaczenie ilosci okien z sygnału
    
    
        % zdefiniowanie zmiennych do przechowywania parametrow
    means = [];
    stds = [];
    skewness = [];
    medians = [];
    PTP_kurtosis = [];
    kurtosis = [];
    ppgHeartRate = [];
    ppgHeartRateAC = [];
    ppgktEnergy = [];
    ppgktEnergy320 = [];
    logEnergy = [];
    ppgLogE_IRQ = [];
    ppgLogE_mean = [];
    ppgLogE_var = [];
    ppgAR5 = [];
    ppgAR5_2 = [];
    ppgFFT = [];
    ppgPSD = [];
    ppgSpectralEntropy = [];
    SpectralEntr = [];
    PPAmad = [];
    td = [];
    PX = [];
    SE = [];
    Q_25 = [];
    Q_50 = [];
    
    
     for i = 1:windows_count
        window = windows(:,i);
        t1 = (0:Tp:(length(window) - 1) * Tp); % zmienna pomocnicza
        m = mean(window);   % średnia
        s = std(window);    % odchylenie standardowe
        skew = sum((window - m).^3) / ((length(window)-1) * s^3); % skośność
        med = median(window); % mediana
        kurt = sum((window - m).^4) / ((length(window)-1) * s^4) - 3; % kurtoza
        [peaks,locs] = findpeaks(window,'MinPeakDistance',round(fs*0.7)); % Obliczanie tętna sygnału PPG
        
        mptp = mean(peaks);% srednia wartosci szczytowych
        PTP_kurt = sum((peaks - mptp).^4) / ((length(peaks)-1) * std(peaks).^4); % kurtoza wartosci szczytowych
        
        % przypisywanie wartosci parametrow do zmiennych tymczasowych
        means = [means, m];
        stds = [stds, s];
        skewness = [skewness, skew];
        medians = [medians, med];
        PTP_kurtosis = [PTP_kurtosis, PTP_kurt];
        ppgHeartRate = [length(peaks)*60/(window_len_samples/fs), ppgHeartRate]; % Obliczanie pulsu za pomocą funkcji findpeaks
        kurtosis = [kurtosis, kurt];
        medpeaks = median(peaks);
        
        % Średnie Bezwzględne Odchylenie (MAD) amplitud od szczytu do szczytu (PPA)
        mad = (1/length(peaks)) * sum(abs(peaks - medpeaks));
        PPAmad = [PPAmad,(1/length(peaks)) * sum(abs(peaks - medpeaks))];
        
        % standard deviation of peak-to-peak amplitudes
        ptp = sqrt((1/length(peaks))*sum((peaks - mptp).^2));
        % sigma = sqrt((1/length(peaks))*(sum((x - mu).^2)));
        
        td = [td, ptp];
        
        % kwantyle okna
        Q_25 = [Q_25, quantile(window, 0.25)];
        Q_50 = [Q_50, quantile(window, 0.50)];
        
         % Obliczenie Kaiser Teager Energy sygnału PPG dla każdego okna
        windowKTEnergy = zeros(size(window));
        for j = 2:length(window)-1
            windowKTEnergy(j) = window(j)^2 - window(j-1)*window(j+1);
        end
        ppgktEnergy = [ppgktEnergy, sum(windowKTEnergy)];
        ppgktEnergy320 = [ppgktEnergy320, windowKTEnergy];
        % obliczenie wartości energii logarytmicznej dla każdej ramki
        logE = log(sum(window.^2));
        
        % Wartość średnia LogE
        ppgLogE_mean = [ppgLogE_mean, mean(logE)];
        
        % wariancja LogE
        ppgLogE_var = [ppgLogE_var, var(logE)];
        
        logEnergy = [logEnergy, logE];
        
        % Wsp. autoregresji 5 rzedow
        p = 5; % stopień modelu AR
        ppgAutoReg = aryule(window, p);
        
        ppgAR5 = [ppgAR5, ppgAutoReg'];
        
        % 2 sposob AR5
        % obliczanie macierzy autokorelacji
        
        %normalized_signal = normalize(window, 'range', [-1 1]);
        
        r = zeros(1, p+1);
        for AR = 0:p
            
            % można wybrać czy liczymy AR5 dla sygnalu czy KTE
            
            %r(AR+1) = sum(window(1:end-AR) .* window(AR+1:end));
            r(AR+1) = sum(windowKTEnergy(1:end-AR) .* windowKTEnergy(AR+1:end));
        end
        
        % tworzenie macierzy Toeplitza
        R = zeros(p);
        for T = 1:p
            for P = 1:p
                R(T, P) = r(abs(T-P)+1);
            end
        end
        
        % obliczanie wektora współczynników autoregresji
        a = -inv(R)*r(2:end)';
        
        ppgAR5_2 = [ppgAR5_2 a(1:end)];
        
        % Obliczenie szybkiej jednostronnej transformaty fouriera
        FFT = fft(window);
        FFT =  FFT(1:round(length(window)/2)+1);
        PSD = (1/(fs*length(FFT))) * abs(FFT).^2; % obliczenie rozkładu mocy sygnału
        f = fs*(0:length(FFT)-1)/length(FFT); % Zdefiniowanie osi czestotliwosci
        
        frequencies = [1.19, 2.39, 4.78, 7.17, 11.96, 15.95, 19.93]; % Zadane częstotliwości (Desired frequencies)
        
        FFTval = zeros(size(frequencies)); % Inicjalizacja wektora na znalezione wartości (Initialize vector for found values)
        
        for i = 1:length(frequencies)
            [~, index] = min(abs(f - frequencies(i))); % Znajdź indeks najbliższej wartości częstotliwości (Find the index of the nearest frequency value)
            FFTval(i) = FFT(index); % Zapisz wartość FFT dla danej częstotliwości (Save the FFT value for the corresponding frequency)
        end
        
        
        for i = 1:length(frequencies)
            [~, index] = min(abs(f - frequencies(i))); % Znajdź indeks najbliższej wartości częstotliwości
            switch frequencies(i)
                case 1.19
                    FFT_1_19 = FFT(index);
                case 2.39
                    FFT_2_39 = FFT(index);
                case 4.78
                    FFT_4_78 = FFT(index);
                case 7.17
                    FFT_7_17 = FFT(index);
                case 11.96
                    FFT_11_96 = FFT(index);
                case 15.95
                    FFT_15_95 = FFT(index);
                case 19.93
                    FFT_19_93 = FFT(index);
            end
        end
        
        [values, indices] = findpeaks(PSD, 'SortStr', 'descend', 'NPeaks', 4);
        
        % rozproszenie położenia znalezionych maksimów
        PSD_VarPeaks = var(values);
        
        % Moc względem położenia
        power_ratio = sum(values.^2)/sum(indices.^2);
        
        weighted_average = sum(values .* indices.^2) / sum(indices.^2);
        
        
        logPSD = abs(log(sum(PSD.^2)));
        
        % Znormalizowanie wartości logPSD
        min_logPSD = 0;
        max_logPSD = 40;
        logPSD = (logPSD - min_logPSD) / (max_logPSD - min_logPSD);
        
        % Obliczanie centrum ciężkości widma
        centroid = sum(f .* PSD) / sum(PSD);
                
        centroid_interpl = interp1(f, PSD, centroid, 'pchip');
        
        ppgFFT = [ppgFFT, FFT];
        ppgPSD = [ppgPSD, PSD]; % widmowa gestosc mocy sygnalu
        
        RealFFT = real(FFT);
        
        
        % Obliczanie entropii widmowej
        
%         for F = 1: length(FFT)
%             Px = (abs(FFT(F))^2)/(sum(abs(FFT).^2));
%             Se = -sum(Px * log(Px));
%             %             p1 = [p1, Px(1,:)];
%             %             p2 = [p2, Se(1,:)];
%         end
%         
%         PX = [PX, Px];
%         SE = [SE, Se];
        
        % Rozstęp międzykwantyrowy PSD (IQR)
        % Sortowanie danych
        sorted_data = sort(PSD);
        
        % Obliczenie mediany
        median_value = median(PSD);
        
        % Podział danych na dwie połowy
        first_half = sorted_data(sorted_data <= median_value);
        second_half = sorted_data(sorted_data > median_value);
        
        % Obliczenie kwartyli Q1 i Q3
        Q1 = median(first_half);
        Q3 = median(second_half);
        
        IQR = Q3 - Q1;
        ppgLogE_IRQ = [ppgLogE_IRQ, IQR];
        
        
        % Normalizacja PSD do stworzenia dystrybucji prawdopodobieństwa
        PSD_norm = PSD / sum(PSD);
        
        % Wyliczenie entropii widmowej
        entropy = -sum(PSD_norm .* log2(PSD_norm + eps));
        
        %SE = -sum(PSD.*log2(PSD));
        SpectralEntr = [SpectralEntr, entropy];
        
        KTEmean = mean(windowKTEnergy);
        KTEvar = var(windowKTEnergy);
        
        LOGEmean = mean(logE);
        LOGEvar = var(logE);
        
        FFTmean = mean(FFT);
        FFTvar = var(FFT);
        
        PSDmean = mean(PSD);
        PSDvar = var(PSD);
        

        
        BMI = data(signal_idx).weight/(data(signal_idx).height^2);
        AGE = data(signal_idx).age;
        
        % Znormalizowanie wartości wieku
        min_age = 0;
        max_age = 120;
        AGE = (AGE - min_age) / (max_age - min_age);
        
        Gender = data(signal_idx).gender;
        
        % wypełnianie wektora krasyfikującego i referencyjnego
        SignalTwoFeatures = [SignalTwoFeatures; KTEmean, KTEvar, PSDmean, PSDvar, var(SE), mean(SE), ptp, PTP_kurt, mptp, max(centroid_interpl), a(end,:), logPSD];

        
%         G1_FFT_ClasificationVectorPro = [G1_FFT_ClasificationVectorPro; FFT_1_19, FFT_2_39, FFT_4_78, FFT_7_17, FFT_11_96, FFT_15_95, FFT_19_93];

     end      
end

save("SignalTwoFeatures.mat", "SignalTwoFeatures");


end

