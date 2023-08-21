function ECG_Filter = ECG_Filters(ecgf)

    load('LPF_ECG.mat');
    load('HPF_ECG.mat');
    
    outputECG1 = filter(LPF_ECG, 1, ecgf);
    outputECG = filter(HPF_ECG, 1, outputECG1);
    
    filtered_ecg = movmean(outputECG, 1);
    
    % Odjęcie wartości średniej
    
    mean_value = mean(filtered_ecg);
    filtered_ecg = filtered_ecg - mean_value;
    
    ECG_Filter = filtered_ecg;
    
end