% function Resp = RESP_Filters(resp)
% 
%     load('LPF_RESPIRATION.mat');
%     
%     % filtracja dolnoprzepustowa
%     filtered_resp = MetodaFalkowa2(resp);
%     
%     % filtr usredniajacy
%     filtered_resp = movmean(filtered_resp, 25);
%     
%     % Odjęcie wartości średniej
%     mean_value = mean(filtered_resp);
%     filtered_resp = filtered_resp - mean_value;
%     
%     Resp = filtered_resp;
% end


function Resp = RESP_Filters(resp)

    load('LPF_RESPIRATION.mat');
    load('HPF_RESPIRATION.mat');
    
    % filtracja dolno przepustowa
    filtered_resp = filter(LPF_RESPIRATION, 1, resp);

    % filtracja górno przepustowa
    filtered_resp = filter(HPF_RESPIRATION, 1, filtered_resp);
    
    filtered_resp = filtered_resp(1000:end);
    
    % filtr usredniajacy
    filtered_resp = movmean(filtered_resp, 250);
    
    % Odjęcie wartości średniej
    mean_value = mean(filtered_resp);
    filtered_resp = filtered_resp - mean_value;
    
    Resp = filtered_resp;
end


