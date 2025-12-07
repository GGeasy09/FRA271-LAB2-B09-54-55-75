% ---------------- Load Data ----------------
load('stepperramp50_1.mat'); ramp50_1_data = squeeze(out.simout2.signals.values);
load('stepperramp50_2.mat'); ramp50_2_data = squeeze(out.simout2.signals.values);
load('stepperramp50_3.mat'); ramp50_3_data = squeeze(out.simout2.signals.values);
tramp50  = out.tout;
load('stepperramp100_1.mat'); ramp100_1_data = squeeze(out.simout2.signals.values);
load('stepperramp100_2.mat'); ramp100_2_data = squeeze(out.simout2.signals.values);
load('stepperramp100_3.mat'); ramp100_3_data = squeeze(out.simout2.signals.values);
tramp100  = out.tout;
load('stepperramp500_1.mat'); ramp500_1_data = squeeze(out.simout2.signals.values);
load('stepperramp500_2.mat'); ramp500_2_data = squeeze(out.simout2.signals.values);
load('stepperramp500_3.mat'); ramp500_3_data = squeeze(out.simout2.signals.values);
tramp500  = out.tout;

% ---------------- Filtering ----------------
fs = 1000;
fc = 10;
[b,a] = butter(2, fc/(fs/2));

% 50 Hz
f50_1  = filtfilt(b,a,ramp50_1_data);
f50_2  = filtfilt(b,a,ramp50_2_data);
f50_3  = filtfilt(b,a,ramp50_3_data);

% 100 Hz
f100_1 = filtfilt(b,a,ramp100_1_data);
f100_2 = filtfilt(b,a,ramp100_2_data);
f100_3 = filtfilt(b,a,ramp100_3_data);

% 500 Hz
f500_1 = filtfilt(b,a,ramp500_1_data);
f500_2 = filtfilt(b,a,ramp500_2_data);
f500_3 = filtfilt(b,a,ramp500_3_data);

% ---------------- Compute Mean RPM ----------------
mean50  = mean([f50_1 f50_2 f50_3],2);
mean100 = mean([f100_1 f100_2 f100_3],2);
mean500 = mean([f500_1 f500_2 f500_3],2);

accel50 = gradient(mean50, tramp50);
accel100 = gradient(mean100, tramp100);
accel500 = gradient(mean500, tramp500);




% % ---------------- Plot Mean Speed Graphs ----------------
% figure;
% 
% % Define frequency variables in Hz
% freq50 = tramp50 * 50 / (2 * pi);
% freq100 = tramp100 * 100 / (2 * pi);
% freq500 = tramp500 * 500 / (2 * pi);
% 
% % Plot for 50 Hz
% subplot(3, 1, 1);
% plot(freq50, mean50);
% title('Mean Speed for 50 Hz');
% xlabel('Frequency (Hz)');
% ylabel('Mean Speed (rad/s)');
% grid on;
% 
% % Plot for 100 Hz
% subplot(3, 1, 2);
% plot(freq100, mean100);
% title('Mean Speed for 100 Hz');
% xlabel('Frequency (Hz)');
% ylabel('Mean Speed (rad/s)');
% grid on;
% 
% % Plot for 500 Hz
% subplot(3, 1, 3);
% plot(freq500, mean500);
% title('Mean Speed for 500 Hz');
% xlabel('Frequency (Hz)');
% ylabel('Mean Speed (rad/s)');
% grid on;

% ---------------- Plot Acceleration Graphs ----------------
figure;

% Plot for 50 Hz
subplot(3, 1, 1);
plot(freq50, accel50);
title('Acceleration for 50 Hz');
xlabel('Frequency (Hz)');
ylabel('Acceleration (rad/s^2)');
grid on;

% Plot for 100 Hz
subplot(3, 1, 2);
plot(freq100, accel100);
title('Acceleration for 100 Hz');
xlabel('Frequency (Hz)');
ylabel('Acceleration (rad/s^2)');
grid on;

% Plot for 500 Hz
subplot(3, 1, 3);
plot(freq500, accel500);
title('Acceleration for 500 Hz');
xlabel('Frequency (Hz)');
ylabel('Acceleration (rad/s^2)');
grid on;