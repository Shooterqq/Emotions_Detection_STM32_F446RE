clear all;
close all;
clc;

load('data.mat')
fs = 1000;
for i=1:length(data)
    ecg = data(i).signal2;
    ecgsig = (ecg)/200; %normalize gain
    t = 1:length(ecgsig);
    tx = t./fs;
    
    wt = modwt(ecgsig, 4, 'sym4');
    wtrec = zeros(size(wt));
    wtrec(3:4, :) = wt(3:4, :);
    
    y = imodwt(wtrec, 'sym4');
    y = abs(y).^2;
    
    avg = mean(y);
    
    [Rpeaks, Rlocs] = findpeaks(y, t, 'MinPeakHeight', 6 * avg, 'MinPeakDistance' , 50);
    
    nohb = length(Rlocs);
    timelimit = length(ecgsig)/fs;
    hbpermin = (nohb * 60) / timelimit;
    disp(strcat('Heart Rate = ', num2str(hbpermin)));


subplot(211)
plot(tx, ecgsig);
xlim([0, timelimit]);
grid on;
xlabel('Seconds')
title('ECG Signal')

subplot(212)
plot(t, y)
grid on;
xlim([0, length(ecgsig)]);
hold on;
plot(Rlocs, Rpeaks, 'ro')
xlabel('Samples')
title(strcat('R Peaks found and Heart Rate: ', num2str(hbpermin)));

end



