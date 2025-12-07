data_speed = squeeze(out.simout2.signals.values);
data_time = squeeze(out.simout3.signals.values);

last_value = data_time(end);
t = out.tout;





fs = 1 / mean(diff(t));
fc = 10;
[b,a] = butter(2,fc/fs/2,"low");
data_speed_filt = filtfilt(b,a,data_speed);



% If your speed is RPM → convert to rad/s
omega = data_speed_filt * 2*pi/60;

% Compute acceleration (rad/s^2)
accel = gradient(omega, t);

% Plot results
figure;
subplot(2,1,1);
plot(t, data_speed_filt, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Speed (RPM)');
title('Speed vs Time');

subplot(2,1,2);
plot(t, accel, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('Acceleration (rad/s^2)');
title('Acceleration vs Time');
grid on;