% Load the new data structure from the .mat file
load('newDataStruct.mat');

% Define the parameters
R = 10; % Ohm (not used in the energy calculation)
V = 12; % Volt
I = 37.5e-3; % Ampere (converted from mA to A)

% Initialize a structure to store the energy consumption
energyStruct = struct();

% Loop over each spreading factor (SF) in the new data structure
SFs = fieldnames(newDataStruct);
for i = 1:length(SFs)
    SF = SFs{i};
    energyStruct.(SF) = struct();

    % Loop over each bandwidth (SBW) in the current SF
    bandwidths = fieldnames(newDataStruct.(SF));
    for j = 1:length(bandwidths)
        bandwidthField = bandwidths{j};
        % Get the time intervals for the current SF and bandwidth
        timeIntervals = newDataStruct.(SF).(bandwidthField);

        % Convert time intervals from milliseconds to seconds
        timeIntervalsSec = timeIntervals / 1000;

        % Calculate the energy consumption
        energyConsumption = V * I * timeIntervalsSec;

        % Store the energy consumption in the structure
        energyStruct.(SF).(bandwidthField) = energyConsumption;

        % Print the energy consumption values
        fprintf('SF: %s, SBW: %s, Energy Consumption: %.3f J\n', SF, bandwidthField, mean(energyConsumption));
    end
end

% Plot the energy consumption for each SF at each SBW
figure;
hold on;
set(gca, 'FontSize', 12, 'FontName', 'Times');

% Define marker styles and colors for each SF
markerStyles = {'o', 's', 'd', '^', 'v', '>'}; % Different markers for each SF
markerColors = lines(6); % Different colors for each SF

% Define the bandwidth values in kHz for plotting, excluding 250 kHz
bandwidthValues = [20.8, 62.5, 125];

% Loop over each SF to plot the energy consumption
for i = 1:length(SFs)
    SF = SFs{i};
    energyValues = zeros(1, length(bandwidthValues));

    for j = 1:length(bandwidthValues)
        bandwidthField = sprintf('sbw%d', bandwidthValues(j) * 1000);
        if isfield(energyStruct.(SF), bandwidthField)
            energyValues(j) = mean(energyStruct.(SF).(bandwidthField)); % Use mean energy consumption for plotting
        else
            energyValues(j) = NaN; % If data is missing, set to NaN
        end
    end

    % Plot the energy consumption
    plot(1:length(bandwidthValues), energyValues, ...
         'Marker', markerStyles{i}, ...
         'MarkerSize', 8, ...
         'MarkerFaceColor', markerColors(i, :), ...
         'MarkerEdgeColor', 'k', ...
         'LineStyle', '-', ...
         'DisplayName', sprintf('%s', SF));
end

% Set custom x-axis ticks and labels with equal spacing and padding
set(gca, 'XTick', 1:length(bandwidthValues));
set(gca, 'XTickLabel', arrayfun(@num2str, bandwidthValues, 'UniformOutput', false));
xlim([0.5, length(bandwidthValues) + 0.5]); % Add padding on the sides

% Set the y-axis to logarithmic scale
set(gca, 'YScale', 'log');
ylim([0 15]); % Adjust y-axis limits as needed

%title('Energy Consumption for Each SF at Each SBW');
xlabel('Signal Bandwidth (kHz)', 'Interpreter', 'latex');
ylabel('Energy Consumption (J)', 'Interpreter', 'latex');
grid on;
legend('show');
hold off;

% Save the plot
print('plot_energy_consumption_by_sf_sbw_20_62_125_log_scale.eps', '-depsc');
print('plot_energy_consumption_by_sf_sbw_20_62_125_log_scale.jpg', '-djpeg');
