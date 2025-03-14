% Load the data structure from the .mat file
load('dataStruct.mat');

% Define the specific configurations to plot
configurations = {
    {12.5, 7, 125000},
    {25, 7, 125000},
    {37.5, 7, 125000},
    {50, 7, 62500},
    {62.5, 8, 125000},
    {75, 8, 62500},
    {87.5, 8, 125000},
    {100, 9, 62500},
    {112.5, 7, 62500},
    {125, 8, 125000}
};

% Initialize vectors to store the data for plotting
plotXValues = [];
plotAvgRSSI = [];
plotStdRSSI = [];
plotSF = [];
plotSBW = [];

% Loop over each configuration
for i = 1:length(configurations)
    distance = configurations{i}{1};
    SF = configurations{i}{2};
    bandwidth = configurations{i}{3};

    % Construct the folder name for the specific distance and bandwidth
    folderName = sprintf('f%gm_sbw%d', distance, bandwidth);
    folderName = strrep(folderName, '.', '_'); % Ensure '.' is replaced with '_'

    % Check if the folder exists in the data structure
    if isfield(dataStruct, folderName)
        sfFieldName = sprintf('SF%d', SF);
        if isfield(dataStruct.(folderName), sfFieldName)
            % Calculate the average and standard deviation of RSSI for the current SF
            avgRSSI = mean(dataStruct.(folderName).(sfFieldName).kalman_RSSI, 'omitnan');
            stdRSSI = std(dataStruct.(folderName).(sfFieldName).kalman_RSSI, 'omitnan');

            % Store the data for plotting
            plotXValues(end+1) = distance;
            plotAvgRSSI(end+1) = avgRSSI;
            plotStdRSSI(end+1) = stdRSSI;
            plotSF(end+1) = SF;
            plotSBW(end+1) = bandwidth;

            % Print the average RSSI and standard deviation for the current configuration
            fprintf('Distance: %g m, SF%d, Bandwidth: %d Hz - Avg RSSI: %.2f dBm, Std Dev: %.2f dBm\n', distance, SF, bandwidth, avgRSSI, stdRSSI);
        end
    end
end

% Plot the average RSSI for the specified configurations
figure;
hold on;
set(gca, 'FontSize', 12, 'FontName', 'Times');

% Define marker styles and colors for each SF
markerStyles = {'o', 's', 'd', '^', 'v', '>'}; % Different markers for each SF
markerColors = lines(6); % Different colors for each SF

% Plot the data points with different colors for each SF
for SF = 7:9
    idx = (plotSF == SF);
    errorbar(plotXValues(idx), plotAvgRSSI(idx), plotStdRSSI(idx), ...
             'Marker', markerStyles{SF-6}, ...
             'MarkerSize', 10, ...
             'MarkerFaceColor', markerColors(SF-6, :), ...
             'MarkerEdgeColor', 'k', ...
             'LineStyle', 'none', ...
             'Color', 'k', ...
             'CapSize', 18, ...
             'LineWidth', 1.0, ...
             'DisplayName', sprintf('SF%d', SF));
end

% Plot a red dotted line connecting the points
redline = plot(plotXValues, plotAvgRSSI, 'r--', 'LineWidth', 1.5);
set(get(get(redline, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

% Fit a linear regression line through the points
fitLine = polyfit(plotXValues, plotAvgRSSI, 1);
fitY = polyval(fitLine, plotXValues);
plot(plotXValues, fitY, 'g-', 'LineWidth', 1.0, 'DisplayName', 'Est. RSSI');

% Set custom x-axis ticks
set(gca, 'XTick', 12.5:12.5:125);
set(gca, 'XTickLabel', {'12.5', '25', '37.5', '50', '62.5', '75', '87.5', '100', '112.5', '125'});

%title('Average RSSI for Specific Configurations with Linear Fit and Error Bars');
xlabel('Distance (m)', 'Interpreter', 'latex');
ylabel('Average RSSI (dBm)', 'Interpreter', 'latex');
ylim([-90, -50]);
legend('show');
grid on;
hold off;

% Save the plot
print('plot_avgRSSI_specific_configurations_fit_green_errorbars_thick.eps', '-depsc');
print('plot_avgRSSI_specific_configurations_fit_green_errorbars_thick.jpg', '-djpeg');
