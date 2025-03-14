% Define the path to the CSV file
csvFilePath = 'Energy_test_data/energy_consumption_data.csv'; % Replace with the actual path to your CSV file

% Read the CSV file into a table
dataTable = readtable(csvFilePath, 'Delimiter', ',', 'ReadVariableNames', true);

% Initialize a structure to store the data
newDataStruct = struct();

% Loop over each spreading factor (SF)
for SF = 7:12
    % Construct the field name for the current SF
    sfFieldName = sprintf('SF%d', SF);

    % Initialize a structure for the current SF if it doesn't exist
    newDataStruct.(sfFieldName) = struct();

    % Loop over each row in the table
    for i = 1:height(dataTable)
        % Extract the bandwidth for the current row
        bandwidth = dataTable.SBW(i);

        % Check if the SF field exists in the table
        if ismember(sfFieldName, dataTable.Properties.VariableNames)
            % Extract the time intervals for the current SF
            timeIntervals = dataTable.(sfFieldName)(i);

            % Construct the folder name for the specific bandwidth
            folderName = sprintf('sbw%d', bandwidth);

            % Store the data in the structure
            if isfield(newDataStruct.(sfFieldName), folderName)
                newDataStruct.(sfFieldName).(folderName) = [newDataStruct.(sfFieldName).(folderName); timeIntervals];
            else
                newDataStruct.(sfFieldName).(folderName) = timeIntervals;
            end
        end
    end
end

% Save the new data structure to a .mat file
save('newDataStruct.mat', 'newDataStruct');

% Display a message indicating successful import
fprintf('Data imported successfully from %s\n', csvFilePath);
