function motorSpec = createMotorSpec(noloadspeed, noloadcurrent, stalltorque, stallcurrent)
    motorSpec = struct('noloadspeed', noloadspeed, ...
                       'noloadcurrent', noloadcurrent, ...
                       'stalltorque', stalltorque, ...
                       'stallcurrent', stallcurrent);
end

PWM3V = createMotorSpec(437.42,0.357,530.05,1.32);
PWM6V = createMotorSpec(1088.37,0.353,1034.16,2.77);
PWM9V = createMotorSpec(1716.71,0.53,1545.68,4.09);
PMW12V = createMotorSpec(2335.22,0.41,1949.71,5.27);

function [speed_constant,offset] = speedequation(noloadspeed,stall_torque)
    speed_constant = -noloadspeed/(stall_torque);
    offset = noloadspeed;
end

function [current_constant,offset] = currentequation(noloadcurrent,stallcurrent,stall_torque)
    current_constant = (stallcurrent-noloadcurrent)/(stall_torque);
    offset = noloadcurrent;
end

[speedConstant3V, offset3V] = speedequation(PWM3V.noloadspeed, PWM3V.stalltorque);
[currentConstant3V, offsetCurrent3V] = currentequation(PWM3V.noloadcurrent, PWM3V.stallcurrent, PWM3V.stalltorque);
[speedConstant6V, offset6V] = speedequation(PWM6V.noloadspeed, PWM6V.stalltorque);
[currentConstant6V, offsetCurrent6V] = currentequation(PWM6V.noloadcurrent, PWM6V.stallcurrent, PWM6V.stalltorque);
[speedConstant9V, offset9V] = speedequation(PWM9V.noloadspeed, PWM9V.stalltorque);
[currentConstant9V, offsetCurrent9V] = currentequation(PWM9V.noloadcurrent, PWM9V.stallcurrent, PWM9V.stalltorque);
[speedConstant12V, offset12V] = speedequation(PMW12V.noloadspeed, PMW12V.stalltorque);
[currentConstant12V, offsetCurrent12V] = currentequation(PMW12V.noloadcurrent, PMW12V.stallcurrent, PMW12V.stalltorque);

% Define torque values for plotting
torque_values = linspace(0, max([PWM3V.stalltorque, PWM6V.stalltorque, PWM9V.stalltorque, PMW12V.stalltorque]), 100);

% Calculate speed for each motor using the speed equation
speed_3V = speedConstant3V * torque_values + offset3V;
speed_6V = speedConstant6V * torque_values + offset6V;
speed_9V = speedConstant9V * torque_values + offset9V;
speed_12V = speedConstant12V * torque_values + offset12V;

% Plotting the results
figure;
hold on;
plot(torque_values, speed_3V, 'DisplayName', '3V/25%PWM', 'LineWidth', 3);
plot(torque_values, speed_6V, 'DisplayName', '6V/50%PWM', 'LineWidth', 3);
plot(torque_values, speed_9V, 'DisplayName', '9V/75%PWM', 'LineWidth', 3);
plot(torque_values, speed_12V, 'DisplayName', '12V/100%PWM', 'LineWidth', 3);
hold off;

% Adding labels and legend
xlabel('Torque (Nm)');
ylabel('Speed (RPM)');
title('Speed vs Torque for Different Motors');
legend show;
grid on;

