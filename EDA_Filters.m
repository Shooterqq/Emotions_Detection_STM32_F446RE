function EDA_F = EDA_Filters(edaf)
    load('LPF_EDA.mat');
    outputEDA = filter(LPF_EDA, 1, edaf);
    filtered_eda = movmean(outputEDA, 15);
    
    % Odjęcie wartości średniej
    mean_value = mean(filtered_eda);
    filtered_eda = filtered_eda - mean_value;
    
    EDA_F = filtered_eda;
end

