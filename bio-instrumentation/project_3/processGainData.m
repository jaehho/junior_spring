function data = processGainData(inputFilename, outputFilename)
    % Read the input CSV file
    data = readtable(inputFilename);

    % Calculate linear gain and dB gain
    linearGain = data.V_out ./ data.V_in;
    dBGain = 20 * log10(linearGain);

    % Append the results to the table
    data.Linear_Gain = round(linearGain, 2);
    data.dB_Gain = round(dBGain, 2);

    % Write the updated table to a new CSV file
    writetable(data, outputFilename);

    % Display a confirmation message
    fprintf('Processed %s to %s\n', inputFilename, outputFilename);
end
