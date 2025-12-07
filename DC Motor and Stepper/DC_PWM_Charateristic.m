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

% Create arrays for plotting
noloadspeeds = [PWM3V.noloadspeed, PWM6V.noloadspeed, PWM9V.noloadspeed, PMW12V.noloadspeed];
stalltorques = [PWM3V.stalltorque, PWM6V.stalltorque, PWM9V.stalltorque, PMW12V.stalltorque];

plotMotorCharacteristics(437.42,0.357,530.05,1.32);
function plotMotorCharacteristics(noloadspeed, noloadcurrent, stalltorque, stallcurrent)
stalltorque = stalltorque/11.12/11.12
% plotMotorCharacteristics(noloadspeed, noloadcurrent, stalltorque, stallcurrent)
% Plots Speed (rpm), Current (A), Efficiency (%) and Power (W) vs Torque on
% a single figure using multiple overlaid axes.
%
% NOTE: This code assumes `stalltorque` units are mNm (millinewton-meter).
% If your torque is already in N*m change the line "torque_Nm = torque/1000;"
% to "torque_Nm = torque;"

    %% create torque vector (same units as stalltorque input)
    torque = linspace(0, stalltorque, 200);

    %% motor linear model
    speed = noloadspeed * (1 - torque / stalltorque);                       % rpm
    current = noloadcurrent + (stallcurrent - noloadcurrent) * (torque / stalltorque);

    %% Efficiency (simple estimate)
    % Here we compute mechanical power below more properly and compute efficiency
    % as Pout / (I * Vscale). Because we do not have V, we normalize efficiency
    % to percent by scaling with max(Pout) if desired. Keep as relative.
    % (You can replace Vscale if you know the supply voltage).
    omega_rad = speed * 2*pi/60;    % convert rpm -> rad/s

    % Torque units: convert to N*m if given in mNm
    torque_Nm = torque;      % <-- change/remove if input is in N*m

    % Mechanical output power (W)
    Pout = torque_Nm .* omega_rad;  % W

    % Simple input power proxy: use current scaled by a constant (no V known)
    Pin_proxy = current .* 12;   % arbitrary scaling so shapes sensible
    efficiency = zeros(size(Pout));
    valid = (Pin_proxy > 0);
    efficiency(valid) = (Pout(valid) ./ Pin_proxy(valid));  % % (relative)
    efficiency(~valid) = 0;
    efficiency(isnan(efficiency)) = 0;
    efficiency(efficiency < 0) = 0;

    %% create main axes
    fig = figure('Name','Motor Characteristics (multi-axis)','NumberTitle','off');
    ax1 = axes('Parent', fig);
    hold(ax1, 'on');

    % left y-axis -> Speed
    yyaxis(ax1, 'left');
    hSpeed = plot(torque, speed, 'b', 'LineWidth', 2);
    ylabel('Speed (RPM)');

    % right y-axis -> Current
    yyaxis(ax1, 'right');
    hCurrent = plot(torque, current, 'r', 'LineWidth', 2);
    ylabel('Current (A)');

    xlabel('Torque');
    title('Motor Characteristics: Speed, Current, Efficiency, Power vs Torque');

    % lock position
    pos = get(ax1, 'Position');
    set(ax1, 'Position', pos);

    %% overlay axis for efficiency (right side, shifted slightly right)
    axEff = axes('Position', pos, ...
                 'Color', 'none', ...
                 'YAxisLocation', 'right', ...
                 'XColor', 'none', ...
                 'YColor', [0 0.5 0]);   % green for efficiency
    hold(axEff, 'on');
    hEff = plot(axEff, torque, efficiency, '--', 'LineWidth', 1.8, 'Color', [0 0.5 0]);
    ylabel(axEff, 'Efficiency (%)');
    set(axEff, 'XTick', [], 'Box', 'off');
    % move efficiency axis labels outward
    axEff.Position = pos;
    axEff.YAxis.Label.Position(1) = axEff.YAxis.Label.Position(1) + 2.5;

    %% overlay axis for power (left side, shifted slightly left)
    axP = axes('Position', pos, ...
               'Color', 'none', ...
               'YAxisLocation', 'left', ...
               'XColor', 'none', ...
               'YColor', [0.6 0 0.8]);   % magenta-like for power
    hold(axP, 'on');
    hP = plot(axP, torque, Pout, '-.', 'LineWidth', 1.6, 'Color', [0.6 0 0.8]);
    ylabel(axP, 'Power (W)');
    set(axP, 'XTick', [], 'Box', 'off');

    % shift the power axis label slightly left so it doesn't overlap with speed
    axP.Position = pos;
    axP.YAxis.Label.Position(1) = axP.YAxis.Label.Position(1) - 1.8;

    %% ensure overlays don't capture x-axis ticks/labels
    set(axEff, 'XTick', []);
    set(axP,   'XTick', []);

    %% grid on the main axis
    grid(ax1, 'on');

    %% annotate maxima if useful
    [maxEff, idxEff] = max(efficiency);
    [maxP, idxP] = max(Pout);
    % note: text coordinates must be in the axis you want to display on.
    % put annotations on axEff and axP respectively
    text(axEff, torque(idxEff), maxEff, sprintf(' Max Eff: %.2f%%', maxEff), ...
         'VerticalAlignment','bottom', 'HorizontalAlignment','right', 'Color', [0 0.5 0], 'FontWeight','bold');
    text(axP, torque(idxP), maxP, sprintf(' Max P: %.2f W', maxP), ...
         'VerticalAlignment','bottom', 'HorizontalAlignment','left', 'Color', [0.6 0 0.8], 'FontWeight','bold');

    %% assemble legend manually (legend on main ax1)
    % combine handles and labels in the order you want
    legend(ax1, [hSpeed, hCurrent, hEff, hP], {'Speed (RPM)','Current (A)','Efficiency (%)','Power (W)'}, ...
           'Location','best');

    %% tidy
    hold(ax1, 'off');
    hold(axEff, 'off');
    hold(axP, 'off');

end


