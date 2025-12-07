function modified_signal = delete_first_half(signal)
    signal_length = length(signal);
    half_index = ceil(signal_length / 2);
    modified_signal = signal(half_index + 1:end);
end

function maximum_efficiency = calculate_efficiency(noloadcurrent, stallcurrent)
    
    if stallcurrent == 0
        maximum_efficiency = 0;
        return;
    end

    ratio = noloadcurrent ./ stallcurrent;   % element-wise division
    ratio(ratio < 0) = 0;

    maximum_efficiency = (1 - sqrt(ratio)) ./ (1 + sqrt(ratio));
end


% --- Only cut CURRENT, do NOT cut PWM ---

half_noloadcurrent50  = delete_first_half(noloadcurrent50);
half_noloadcurrent100 = delete_first_half(noloadcurrent100);
half_noloadcurrent1k  = delete_first_half(noloadcurrent1k);
half_noloadcurrent10k = delete_first_half(noloadcurrent10k);

stall_current50_adj  = stall_current50  + half_noloadcurrent50(1);
stall_current100_adj = stall_current500 + half_noloadcurrent100(1);
stall_current1k_adj  = stall_current1k  + half_noloadcurrent1k(1);
stall_current10k_adj = stall_current10k + half_noloadcurrent10k(1);


% Compute efficiency (vector)
maxeff50  = calculate_efficiency(half_noloadcurrent50,  stall_current50_adj);
maxeff100 = calculate_efficiency(half_noloadcurrent100, stall_current100_adj);
maxeff1k  = calculate_efficiency(half_noloadcurrent1k,  stall_current1k_adj);
maxeff10k = calculate_efficiency(half_noloadcurrent10k, stall_current10k_adj);



% --- PWM must match length, so trim PWM to last half ---
PWM50_trim  = PWM50(end-length(maxeff50)+1:end);
PWM100_trim = PWM100(end-length(maxeff100)+1:end);
PWM1k_trim  = PWM1k(end-length(maxeff1k)+1:end);
PWM10k_trim = PWM10k(end-length(maxeff10k)+1:end);

% --- Plot stall current adjusted with noload current ---
% figure;
% hold on;
% plot(PWM50_trim, stall_current50_adj, 'LineWidth', 2, 'DisplayName', '50 Hz');
% plot(PWM50_trim, half_noloadcurrent50, 'LineWidth', 2, 'DisplayName', '1000 Hz');
% hold off;
% 
% title('Adjusted Stall Current vs PWM');
% xlabel('PWM (%)');
% ylabel('Adjusted Stall Current');
% legend('show');
% grid on;
% % % --- Plot ---
figure;
hold on;
plot(PWM50_trim,  maxeff50,  'LineWidth', 2);
plot(PWM100_trim, maxeff100, 'LineWidth', 2);
plot(PWM1k_trim,  maxeff1k,  'LineWidth', 2);
plot(PWM10k_trim, maxeff10k, 'LineWidth', 2);
hold off;

title('1-Second max efficiency vs PWM at 12V');
xlabel('PWM (%)');
ylabel('Efficiency (%)');
legend('50 Hz', '100 Hz', '1000 Hz', '10000 Hz');
grid on;
