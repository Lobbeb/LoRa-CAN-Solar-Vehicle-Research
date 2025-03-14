% Define the base directory
baseDir = 'Test_data'; % Ensure this is the correct path

% Define the possible values for X and Y
X_values = 12.5:12.5:125;
Y_values = [20800, 62500, 125000, 250000];

% Initialize a structure to store the data
dataStruct = struct();

% Loop over each combination of X and Y
for i = 1:length(X_values)
    for j = 1:length(Y_values)
        % Construct the folder name
        folderName = sprintf('%gm_sbw%d', X_values(i), Y_values(j));
        folderName = strrep(folderName, '.', '_'); % Ensure '.' is replaced with '_'
        folderPath = fullfile(baseDir, folderName);

        % Debug: Print the folder path being checked
        fprintf('Checking folder: %s\n', folderPath);

        % Check if the folder exists
        if isfolder(folderPath)
            % Loop over the possible values of Z (spreading factor)
            for Z = 7:12
                % Construct the file name
                fileName = sprintf('lora_receiver_sf%d.csv', Z);
                filePath = fullfile(folderPath, fileName);

                % Debug: Print the file path being checked
                fprintf('Checking file: %s\n', filePath);

                % Check if the file exists
                if isfile(filePath)
                    % Read the data into a matrix with comma delimiter
                    data = readmatrix(filePath, 'Delimiter', ',');

                    % Extract the relevant columns
                    time_ms = data(:, 2);
                    RSSI = data(:, 4);
                    kalman_RSSI = data(:, 5);
                    sma_RSSI = data(:, 6);

                    % Prefix the folder name with 'f' to ensure valid field names
                    fieldName = ['f' folderName];

                    % Store the data in the structure
                    if ~isfield(dataStruct, fieldName)
                        dataStruct.(fieldName) = struct();
                    end
                    dataStruct.(fieldName).(sprintf('SF%d', Z)) = struct(...
                        'time_ms', time_ms, ...
                        'RSSI', RSSI, ...
                        'kalman_RSSI', kalman_RSSI, ...
                        'sma_RSSI', sma_RSSI ...
                    );

                    % Display a message indicating successful import
                    fprintf('Imported data from %s\n', filePath);
                else
                    fprintf('File %s does not exist.\n', filePath);
                end
            end
        else
            fprintf('Folder %s does not exist.\n', folderPath);
        end
    end
end


% Initialize a structure to store average RSSI for each SF
avgRSSI = struct();

% Loop over each field in the data structure
fields = fieldnames(dataStruct);
for i = 1:length(fields)
    folderName = fields{i};
    % Loop over each SF in the current folder
    SFs = fieldnames(dataStruct.(folderName));
    for j = 1:length(SFs)
        SF = SFs{j};
        % Calculate the average RSSI for the current SF
        if isfield(dataStruct.(folderName).(SF), 'RSSI')
            if ~isfield(avgRSSI, SF)
                avgRSSI.(SF) = [];
            end
            avgRSSI.(SF) = [avgRSSI.(SF); mean(dataStruct.(folderName).(SF).RSSI, 'omitnan')];
        end
    end
end

% Save the data structure to a .mat file
save('dataStruct.mat', 'dataStruct');

