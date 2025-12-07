%% --- Load Data ---
load('stepperfreq000_1.mat'); freq000_1data = squeeze(out.simout2.signals.values);
load('stepperfreq000_2.mat'); freq000_2data = squeeze(out.simout2.signals.values);
load('stepperfreq000_3.mat'); freq000_3data = squeeze(out.simout2.signals.values);

load('stepperfreq001_1.mat'); freq001_1data = squeeze(out.simout2.signals.values);
load('stepperfreq001_2.mat'); freq001_2data = squeeze(out.simout2.signals.values);
load('stepperfreq001_3.mat'); freq001_3data = squeeze(out.simout2.signals.values);

load('stepperfreq010_1.mat'); freq010_1data = squeeze(out.simout2.signals.values);
load('stepperfreq010_2.mat'); freq010_2data = squeeze(out.simout2.signals.values);
load('stepperfreq010_3.mat'); freq010_3data = squeeze(out.simout2.signals.values);

time = out.tout;

%% --- Take only 5s to 20s segment ---
startIndex = find(time >= 5, 1);
endIndex   = find(time >= 20, 1) - 1;

tSeg = time(startIndex:endIndex);

%% --- Filter design ---
fs = 1 / (time(2) - time(1));
cutoff = 10;
[b,a] = butter(2, cutoff/(fs/2));

%% ---- Helper for filtering ----
filterData = @(x) filtfilt(b,a, x(startIndex:endIndex));

%% --- Filter all signals ---
f000 = [ filterData(freq000_1data), ...
         filterData(freq000_2data), ...
         filterData(freq000_3data) ];

f001 = [ filterData(freq001_1data), ...
         filterData(freq001_2data), ...
         filterData(freq001_3data) ];

f010 = [ filterData(freq010_1data), ...
         filterData(freq010_2data), ...
         filterData(freq010_3data) ];

%% --- Average 3 signals ---
f000_avg = mean(f000, 2);
f001_avg = mean(f001, 2);
f010_avg = mean(f010, 2);

%% --- 1-Second Averaging (Binning) ---
bin_edges = 5:1:20;       % 1-second bins
nBins = length(bin_edges)-1;

f000_bin = zeros(nBins,1);
f001_bin = zeros(nBins,1);
f010_bin = zeros(nBins,1);
t_bin    = zeros(nBins,1);

for i = 1:nBins
    idx = tSeg >= bin_edges(i) & tSeg < bin_edges(i+1);
    f000_bin(i) = mean(f000_avg(idx));
    f001_bin(i) = mean(f001_avg(idx));
    f010_bin(i) = mean(f010_avg(idx));
    t_bin(i)    = mean([bin_edges(i), bin_edges(i+1)]); % center of bin
end

%% --- Compute linear fit + R² ---

[m000, b000, R2_000] = linearFitWithR2(t_bin, f000_bin);
[m001, b001, R2_001] = linearFitWithR2(t_bin, f001_bin);
[m010, b010, R2_010] = linearFitWithR2(t_bin, f010_bin);

%% Create equation strings
eq000 = sprintf('000: y = %.3fx + %.3f  (R^2 = %.4f)', m000, b000, R2_000);
eq001 = sprintf('001: y = %.3fx + %.3f  (R^2 = %.4f)', m001, b001, R2_001);
eq010 = sprintf('010: y = %.3fx + %.3f  (R^2 = %.4f)', m010, b010, R2_010);

%% --- Plot ---
%% --- Plot ---
figure;
plot(t_bin, f000_bin, 'or-', 'LineWidth', 1.5, 'DisplayName','freq000');
hold on;
plot(t_bin, f001_bin, 'ok-', 'LineWidth', 1.5, 'DisplayName','freq001');  % ← changed to black
plot(t_bin, f010_bin, 'ob-', 'LineWidth', 1.5, 'DisplayName','freq010');

grid on;
xlabel('Time (s)');
ylabel('Averaged Value');
title('1-Second Averaged Stepper Frequency Data');

% Display R-squared text
text(5.1, max([f000_bin; f001_bin; f010_bin]) * 0.95, eq000, 'Color','r');
text(5.1, max([f000_bin; f001_bin; f010_bin]) * 0.90, eq001, 'Color','k');  % ← changed to black
text(5.1, max([f000_bin; f001_bin; f010_bin]) * 0.85, eq010, 'Color','b');

legend show;



%% --- R-SQUARE helper ---
function [m, b, R2] = linearFitWithR2(x, y)
    p = polyfit(x, y, 1);   % linear fit
    m = p(1);
    b = p(2);

    yfit = polyval(p, x);
    SSres = sum((y - yfit).^2);
    SStot = sum((y - mean(y)).^2);

    R2 = 1 - SSres/SStot;
end
