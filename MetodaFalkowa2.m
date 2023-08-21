function R = MetodaFalkowa2(ir)
    wavelet = 'db1';    % Typ falki
    n = 12;
    D = [];

    [C, L] = wavedec(ir, n, wavelet);
    for k = 1:n
        D(:, k) = wrcoef('d', C, L, wavelet, k);
    end

    ir_dc = wrcoef('a', C, L, wavelet);
    ir_ac = D(:, 8) + D(:, 9) + D(:, 10) + D(:, 11) + D(:, 12);
    
    % Zastosowanie filtru usredniającego w oknie o długości 5 próbek
    filtered_ir_ac = movmean(ir_ac, 15);

    R = filtered_ir_ac;
end
