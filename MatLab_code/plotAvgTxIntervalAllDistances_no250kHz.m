% Load the data structure from the .mat file
load('dataStruct.mat');

% Define the possible values for Y (bandwidths) and SFs
Y_values = [20800, 62500, 125000]; % Include 20.8 kHz, 62.5 kHz, and 125 kHz
X_values = 12.5:12.5:125; % All distances

% Initialize matrices to store average and standard deviation of transmission frequency for each SF and SBW
avgTransmissionFrequency = nan(length(Y_values), 6); % Assuming SF7 to SF12
stdTransmissionFrequency = nan(length(Y_values), 6); % Assuming SF7 to SF12

% Loop over each bandwidth
for j = 1:length(Y_values)
    bandwidth = Y_values(j);
    % Loop over each SF
    for SF = 7:12
        sfFieldName = sprintf('SF%d', SF);
        tempAvgTxInterval = [];

        % Loop over each distance
        for i = 1:length(X_values)
            distance = X_values(i);
            % Construct the folder name for the specific distance and bandwidth
            folderName = sprintf('f%gm_sbw%d', distance, bandwidth);
            folderName = strrep(folderName, '.', '_'); % Ensure '.' is replaced with '_'

            % Check if the folder exists in the data structure
            if isfield(dataStruct, folderName) && isfield(dataStruct.(folderName), sfFieldName)
                % Get the time_ms data
                time_ms = dataStruct.(folderName).(sfFieldName).time_ms;

                % Calculate the differences in time_ms
                timeDiffs = diff(time_ms);

                % Collect the average transmission frequency
                if ~isempty(timeDiffs)
                    tempAvgTxInterval(end+1) = mean(timeDiffs, 'omitnan'); %#ok<AGROW>
                end
            end
        end

        % Calculate the overall average and standard deviation of Tx interval for the current SF and bandwidth
        if ~isempty(tempAvgTxInterval)
            avgTransmissionFrequency(j, SF-6) = mean(tempAvgTxInterval, 'omitnan');
            stdTransmissionFrequency(j, SF-6) = std(tempAvgTxInterval, 'omitnan');
        end
    end
end

% Print the average Tx intervals and standard deviation
fprintf('Average Tx Intervals (ms) and Standard Deviation for each SF and Bandwidth:\n');
for j = 1:length(Y_values)
    fprintf('Bandwidth: %d Hz\n', Y_values(j));
    for SF = 7:12
        fprintf('  SF%d: %.2f ms (Std Dev: %.2f ms)\n', SF, avgTransmissionFrequency(j, SF-6), stdTransmissionFrequency(j, SF-6));
    end
end

% Plot the average Tx interval for all SFs across the selected bandwidths
figure;
bar(1:length(Y_values), avgTransmissionFrequency, 'grouped');
set(gca, 'FontSize', 12, 'FontName', 'Times');
%title('Average Tx Interval for All SFs Across Selected Bandwidths');
xlabel('Signal Bandwidth (Hz)', 'Interpreter','latex');
ylabel('Avg. Tx Interval (ms)', 'Interpreter','latex');
legend('SF7', 'SF8', 'SF9', 'SF10', 'SF11', 'SF12', 'Location','northwest');
grid on;

% Set the x-axis ticks to be equally spaced
set(gca, 'XTick', 1:length(Y_values));
set(gca, 'XTickLabel', {'20.8k', '62.5k', '125k'});

% Add lines for Tx Interval and label them in the legend
hold on;
line(xlim, [2000 2000], 'Color', 'r', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'max Tx');
line(xlim, [1000 1000], 'Color', 'g', 'LineStyle', '--', 'LineWidth', 1.5, 'DisplayName', 'min Tx');
hold off;

% Save the plot
print('plot_tx_interval_all_distances_selected_sbw_equal_spacing.eps','-depsc');
print('plot_tx_interval_all_distances_selected_sbw_equal_spacing.jpg','-djpeg');
