function Resp = RESP_Filters(resp)

    load('LPF_RESPIRATION.mat');
    
    % filtracja dolnoprzepustowa
    filtered_resp = filter(LPF_RESPIRATION, 1, resp);
    
    % filtr usredniajacy
    filtered_resp = movmean(filtered_resp, 20);
    
    % Odjęcie wartości średniej
    mean_value = mean(filtered_resp);
    filtered_resp = filtered_resp - mean_value;
    
    Resp = filtered_resp;
end

