function filtered_signal = Wavelet_Filters(in_sig)

    wavelet_type = 'sym4'; % Typ falki
    level = 12;            % Ilość detali
    det_cofs = [];

    [cofs, levels] = wavedec(in_sig, level, wavelet_type);
    for k = 1:level
        det_cofs(:, k) = wrcoef('d', cofs, levels, wavelet_type, k);
    end

    det_sum = sum(det_cofs(:, 8:12), 2); % Suma detali użytych do rekonstrukcji sygnału
    
    % Zastosowanie filtru usredniającego
    filtered_det_sum = movmean(det_sum, 100);

    filtered_signal = filtered_det_sum;
end





% function R = Wavelet_Filters(ir)
% 
%     wavelet = 'sym4';    % Typ falki
%     n = 12;              % Ilość detali
%     D = [];
% 
%     [C, L] = wavedec(ir, n, wavelet);
%     for k = 1:n
%         D(:, k) = wrcoef('d', C, L, wavelet, k);
%     end
% 
%     ir_dc = wrcoef('a', C, L, wavelet);
%     ir_ac = D(:, 8) + D(:, 9) + D(:, 10) + D(:, 11) + D(:, 12); % Detale uzyte do rekonstrukcji sygnału
%     
%     % Zastosowanie filtru usredniającego
%     filtered_ir_ac = movmean(ir_ac, 100);
% 
%     R = filtered_ir_ac;
% end