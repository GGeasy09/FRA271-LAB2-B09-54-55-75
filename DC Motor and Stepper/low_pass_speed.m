data_speed = squeeze(out.simout2.signals.values);
data_current = squeeze(out.simout4.signals.values);
% data_currentabs = squeeze(out.simout.signals.values);
% data_weight = squeeze(out.simout1.signals.values);
% storage = [storage, data(:)];
data_time = squeeze(out.simout3.signals.values);
% last_value = data_time(end)
t = out.tout;
data_speed_fft = fft(data_speed);
data_current_fft = fft(data_current);
% data_currentabs_fft = fft(data_currentabs);
% data_weight_fft = fft(data_weight);
% --- แสดงผลข้อมูล ---
% figure;
% hold on;
% plot(t, data_weight);
% title('Data vs Time');
% xlabel('Time (s)');
% ylabel('Amplitude');
% grid on;




% --- สร้างกราฟ ---
figure;
plot(abs(data_speed_fft), 'LineWidth', 2);   % Make line thicker
title('FFT of Data');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
grid on;

% 
fs = 1 / mean(diff(t));
fc = 10;
[b,a] = butter(2,fc/fs/2,"low");
data_current_filt = filtfilt(b,a,data_current);
data_speed_filt = filtfilt(b,a,data_speed);
% data_currentabs_filt = filtfilt(b,a,data_currentabs);
% data_weight_filt = filtfilt(b,a,data_weight);

% speed = mean(data_speed_filt);
current = mean(data_current_filt);
% currentabs = mean(data_currentabs_filt);
% weight = (mean(data_weight_filt)-293.07)*2.9;
% fprintf('Mean Speed: %.2f\n', speed);
% fprintf('Mean Current: %.2f\n', current);
% fprintf('Mean Currentabs: %.2f\n', currentabs);
% fprintf('Mean weight: %.2f\n', weight); 
% --- แสดงผลข้อมูลที่กรองแล้ว ---
figure;
plot(t, data_speed, 'b', t, data_speed_filt, 'r');
legend('Original Data', 'Filtered Data');
title('Original vs Filtered Data');
xlabel('Time (s)');
ylabel(['Amplitude']);
hold off;

% speed = mean(data_filt);
% disp(mean(data_current));

