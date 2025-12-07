%% --- Load All Files ---
load('DC50HzLoadcell_1.mat');    d50_1 = out;
load('DC50HzLoadcell_2.mat');    d50_2 = out;
load('DC50HzLoadcell_3.mat');    d50_3 = out;

load('DC500HzLoadcell_1.mat');   d500_1 = out;
load('DC500HzLoadcell_2.mat');   d500_2 = out;
load('DC500HzLoadcell_3.mat');   d500_3 = out;

load('DC1000HzLoadcell_1.mat');  d1k_1 = out;
load('DC1000HzLoadcell_2.mat');  d1k_2 = out;
load('DC1000HzLoadcell_3.mat');  d1k_3 = out;

load('DC10000HzLoadcell_1.mat'); d10k_1 = out;
load('DC10000HzLoadcell_2.mat'); d10k_2 = out;
load('DC10000HzLoadcell_3.mat'); d10k_3 = out;


%% --- Function to average and filter ---
process = @(d1,d2,d3) ...
    filter_and_avg( ...
        squeeze(d1.simout1.signals.values), ...
        squeeze(d2.simout1.signals.values), ...
        squeeze(d3.simout1.signals.values), ...
        d1.tout );


%% --- Process all groups ---
[t50, stall_current50]     = deal([]);
[PWM50,  stall_current50]  = process_and_bin(squeeze(d50_1.simout4.signals.values),  squeeze(d50_2.simout4.signals.values),  squeeze(d50_3.simout4.signals.values),  d50_1.tout);
[PWM500, stall_current500] = process_and_bin(squeeze(d500_1.simout4.signals.values), squeeze(d500_2.simout4.signals.values), squeeze(d500_3.simout4.signals.values), d500_1.tout);
[PWM1k,  stall_current1k]  = process_and_bin(squeeze(d1k_1.simout4.signals.values),  squeeze(d1k_2.simout4.signals.values),  squeeze(d1k_3.simout4.signals.values),  d1k_1.tout);
[PWM10k, stall_current10k] = process_and_bin(squeeze(d10k_1.simout4.signals.values), squeeze(d10k_2.simout4.signals.values), squeeze(d10k_3.simout4.signals.values), d10k_1.tout);



%% --- Plot All Together ---
figure;
hold on;
plot(PWM50,  stall_current50,  'LineWidth', 2);
plot(PWM500, stall_current500, 'LineWidth', 2);
plot(PWM1k,  stall_current1k,  'LineWidth', 2);
plot(PWM10k, stall_current10k, 'LineWidth', 2);
hold off;

title('1-Second Averaged Stall Current Signals vs PWM');
xlabel('PWM (%)');
ylabel('Stall Current (A)');
legend('50 Hz', '100 Hz', '1000 Hz', '10000 Hz');
grid on;


%% --- Helper Function ---
function [PWM_out, y_out] = process_and_bin(sig1, sig2, sig3, t)

    % 1) Average 3 signals
    avg = (sig1 + sig2 + sig3) / 3;

    % 2) Low-pass filter
    fs = 1 / mean(diff(t));
    fc = 10;
    [b,a] = butter(2, fc/(fs/2), 'low');
    avg_filt = filtfilt(b,a,avg);

    % 3) Convert time → PWM
    PWM = 5 * t;

    % 4) Bin into 1-second intervals
    bin_edges = 0:1:max(t);
    y_out   = zeros(length(bin_edges)-1,1);
    PWM_out = zeros(length(bin_edges)-1,1);

    for i = 1:length(bin_edges)-1
        idx = t >= bin_edges(i) & t < bin_edges(i+1);
        y_out(i)   = mean(avg_filt(idx));      % torque avg in that 1-sec window
        PWM_out(i) = mean(PWM(idx));           % PWM avg for that window
    end
    % 5) Remove offset → make first value = 0
    y_out = y_out - y_out(1);
end