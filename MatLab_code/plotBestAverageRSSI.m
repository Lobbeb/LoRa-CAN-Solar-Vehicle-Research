% Load the data structure from the .mat file
load('dataStruct.mat');

% Define the possible values for X (distances) and the specific bandwidth
X_values = 12.5:12.5:125;
bandwidth = 125000;

% Initialize matrices to store average RSSI and standard deviation for each SF
avgRSSI_AllSF = nan(length(X_values), 6); % Assuming SF7 to SF12
stdRSSI_AllSF = nan(length(X_values), 6); % Assuming SF7 to SF12

% Loop over each distance
for i = 1:length(X_values)
    % Construct the folder name for the specific bandwidth
    folderName = sprintf('f%gm_sbw%d', X_values(i), bandwidth);
    folderName = strrep(folderName, '.', '_'); % Ensure '.' is replaced with '_'

    % Check if the folder exists in the data structure
    if isfield(dataStruct, folderName)
        % Loop over each SF
        for SF = 7:12
            sfFieldName = sprintf('SF%d', SF);
            if isfield(dataStruct.(folderName), sfFieldName)
                % Calculate the average and standard deviation of RSSI for the current SF
                avgRSSI_AllSF(i, SF-6) = mean(dataStruct.(folderName).(sfFieldName).kalman_RSSI, 'omitnan');
                stdRSSI_AllSF(i, SF-6) = std(dataStruct.(folderName).(sfFieldName).kalman_RSSI, 'omitnan');
            end
        end
    end
end

% Find the best average RSSI and corresponding SF at each distance
[bestRSSI, bestSFIdx] = max(avgRSSI_AllSF, [], 2);
bestSF = bestSFIdx + 6; % Convert index to SF (7 to 12)

% Print the best average RSSI and standard deviation for each SF at each distance
fprintf('Best Average RSSI (dBm) and Standard Deviation for each SF at each distance:\n');
for i = 1:length(X_values)
    fprintf('Distance: %g m\n', X_values(i));
    for SF = 7:12
        fprintf('  SF%d: %.2f dBm (Std Dev: %.2f dBm)\n', SF, avgRSSI_AllSF(i, SF-6), stdRSSI_AllSF(i, SF-6));
    end
end

% Plot the average RSSI for all SF at each distance for bandwidth 20,800 Hz
figure;
hold on;
set(gca, 'FontSize', 13, 'FontName', 'Times');
markerStyles = {'o', 's', 'd', '^', 'v', '>'}; % Different markers for each SF
markerColors = lines(6); % Different colors for each SF

for SF = 7:12
    plot(X_values, avgRSSI_AllSF(:, SF-6), ...
         'DisplayName', sprintf('SF%d', SF), ...
         'Marker', markerStyles{SF-6}, ...
         'MarkerSize', 8, ...
         'MarkerFaceColor', markerColors(SF-6, :), ...
         'MarkerEdgeColor', 'k', ...
         'LineStyle', 'none');
end

% Plot the best average RSSI at each distance
plot(X_values, bestRSSI,...
     'LineStyle', '--', 'Color', 'r', 'LineWidth', 1.5, 'DisplayName', 'Best RSSI');

% Annotate the plot with the best SF at each distance
for i = 1:length(X_values)
    text(X_values(i), bestRSSI(i) + 1, sprintf('SF%d', bestSF(i)), ...
         'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center', ...
         'FontSize', 14, 'Color', 'k', 'FontWeight', 'bold', 'FontName','Times');
end

% Set custom x-axis ticks
set(gca, 'XTick', 12.5:12.5:125);
set(gca, 'XTickLabel', {'12.5', '25', '37.5', '50', '62.5', '75', '87.5', '100', '112.5', '125'});

%title(sprintf('Average RSSI and Best RSSI at Each Distance (Bandwidth %d Hz)', bandwidth));
xlabel('Distance (m)', 'Interpreter','latex');
ylabel('Average RSSI (dBm)', 'Interpreter','latex');
ylim([-90, -50]);
legend('show');
grid on;
hold off;

% Save the plot
print(sprintf('plot_avgBestRSSI_%dkHz.eps', bandwidth),'-depsc');
print(sprintf('plot_avgBestRSSI_%dkHz.jpg', bandwidth),'-djpeg');
