clc; clear; close all;
fclose(fopen('figures/logfile.txt', 'w'));
diary('figures/the_Mscan.txt'); % Start logging to a file
diary on;

%% Load RAW Files and Parameters
Mscan1_raw  = loadRawFile('project-files/Mscan1.raw');
Mscan40_raw = loadRawFile('project-files/Mscan40.raw');
load('project-files/L2K.mat', 'L2K');
run('dataParams.m');

%% Generate Bscans for Both Datasets
[Mscan_M1, timing_M1]   = generate_Bscan(Mscan1_raw, N_axial, D_Mscan, L2K, true, true, false);
[Mscan_M40, timing_M40] = generate_Bscan(Mscan40_raw, N_axial, D_Mscan, L2K, true, true, false);

%% Crop to Half Axial Range and Define Depth Axis
N_half = round(N_axial / 2);
z = (1:N_half) * dz;  % z in meters

Mscan_M1_cropped   = Mscan_M1(1:N_half, :);
Mscan_M40_cropped  = Mscan_M40(1:N_half, :);

%% Define Depth Range for Peak Detection (convert depth bounds from mm to meters)
depth_lower = 0.1;  % in mm
depth_upper = 0.5;  % in mm
% Since z is in meters and dz is in meters, convert mm->m by dividing by 1e3
depth_range_idx = round(depth_lower/1e3/dz):round(depth_upper/1e3/dz);

%% Define scans and corresponding data
scans    = {'Mscan1', 'Mscan40'};
Mscans   = {Mscan_M1_cropped, Mscan_M40_cropped};
timings  = {timing_M1, timing_M40};  % if needed later

%% ----- Average Ascan Magnitude Plots for Both Scans in One Figure -----
figure("Name", "Average Ascan Magnitude (Both Scans)");
tlo_avg = tiledlayout(length(scans), 1);  % one row, one column per scan

for scanNum = 1:length(scans)
    scanName   = scans{scanNum};
    Mscan_crop = Mscans{scanNum};
    
    % Compute Average Ascan Magnitude (in dB)
    avg_Ascan = mean(20*log10(abs(Mscan_crop)), 2);
    
    % Detect peaks within the specified depth range
    [pks, locs] = findpeaks(avg_Ascan(depth_range_idx), z(depth_range_idx), ...
                              'MinPeakHeight', -5, 'MinPeakDistance', 0.1 * 1e-3);
    % Convert peak locations (in depth) to pixel indices
    pixel_idx = round(locs / dz);
    
    fprintf('Average Ascan Peaks (%s):\n', scanName);
    for i = 1:min(2, length(pks))
        fprintf('  Peak %d: %.2f dB at %.2f mm (Pixel %d)\n', i, pks(i), locs(i)*1e3, pixel_idx(i));
    end
    
    % Plot the average Ascan in the next tile
    nexttile(tlo_avg);
    plot(z * 1e3, avg_Ascan); hold on;
    plot(locs * 1e3, pks, 'bv', 'MarkerFaceColor', 'b');
    xlabel('Depth [mm]');
    ylabel('Magnitude [dB]');
    title(sprintf('Average Ascan (%s)', scanName));
    axis tight;
    
    %% ----- Displacement vs. Time Plots for Selected Pixels (Grouped) -----
    numPeaks = min(2, length(pks));  % Use only the first two detected peaks
    figure("Name", sprintf("Displacement vs. Time (%s)", scanName));
    tlo_disp = tiledlayout(numPeaks, 1);  % Update to one column, multiple rows for peaks
    
    for peakIdx = 1:numPeaks
        pixel = pixel_idx(peakIdx);
        % Extract the time series at the selected pixel row
        time_series = Mscan_crop(pixel, :);
        
        % Unwrap the phase of the complex time series
        phase_unwrapped = unwrap(angle(time_series));
        
        % Convert the unwrapped phase to displacement in nm
        displacement = (lambda_0/(4*pi * n_air)) * phase_unwrapped * 1e9;
        
        % Correct initial artifact by removing transient samples
        transient_samples = round(0.0015 * fs);
        displacement_corrected = displacement(transient_samples+1:end);
    
        t = (0:length(displacement_corrected)-1) * dt;
        
        nexttile(tlo_disp);
        plot(t, displacement_corrected);
        xlabel('Time [s]');
        ylabel('Displacement [nm]');
        title(sprintf('Peak %d (Pixel %d)', peakIdx, pixel));
        axis tight;
        
        %% ----- Displacement Frequency Spectrum Plots for Each Peak (Grouped) -----
        % We compute the FFT for the current displacement_corrected.
        N_samples = length(displacement_corrected);
        f = ((0:N_samples-1) / (N_samples * dt)) / 2;
    
        displacement_fft = fft(displacement_corrected);
        displacement_fft_dB = 20*log10(abs(displacement_fft));
    
        % Use only the first half of the FFT result
        half_idx = floor(N_samples/2)+1;
        displacement_fft_dB_half = displacement_fft_dB(1:half_idx);
        f_half = f(1:half_idx);
        
        % Define ROI for peak detection in frequency domain
        f_threshold = 0.15 * 1e3; % threshold in Hz
        f_roi_idx = find(f_half >= f_threshold, 1);
    
        [pks_fft, locs_fft] = findpeaks(displacement_fft_dB_half(f_roi_idx:end), f_half(f_roi_idx:end), ...
                                        'MinPeakHeight', 90, 'MinPeakProminence', 10);
        fprintf('Displacement Frequency Peaks (%s, Peak %d):\n', scanName, peakIdx);
        for i = 1:length(pks_fft)
            fprintf('  Peak %d: %.2f dB at %.2f kHz\n', i, pks_fft(i), locs_fft(i) * 1e-3);
        end
        
        % Create (or update) a grouped figure for frequency spectra for this scan.
        % If first peak, open a new figure.
        if peakIdx == 1
            figure("Name", sprintf("Displacement Frequency Spectrum (%s)", scanName));
            tlo_freq = tiledlayout(numPeaks, 1);  % Update to one column, multiple rows for frequency peaks
        end
        
        nexttile(tlo_freq);
        plot(f_half * 1e-3, displacement_fft_dB_half); hold on;
        plot(locs_fft * 1e-3, pks_fft, 'bv', 'MarkerFaceColor', 'b');
        xlabel('Frequency [kHz]');
        ylabel('Amplitude [dB]');
        title(sprintf('Peak %d (Pixel %d)', peakIdx, pixel));
        axis tight;
    end
end

diary off;
