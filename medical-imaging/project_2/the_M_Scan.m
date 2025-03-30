clc; clear; close all;

%% Load RAW Files and Parameters
MScan1_raw  = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');
load('project-files/L2K.mat', 'L2K');
run('dataParams.m');

%% Generate B-Scans for Both Datasets
[MScan_M1, timing_M1]   = generateBScan(MScan1_raw, N_axial, D_MScan, L2K, true, true, false);
[MScan_M40, timing_M40] = generateBScan(MScan40_raw, N_axial, D_MScan, L2K, true, true, false);

%% Crop to Half Axial Range and Define Depth Axis
N_half = round(N_axial / 2);
z = (1:N_half) * dz;  % z in meters

MScan_M1_cropped   = MScan_M1(1:N_half, :);
MScan_M40_cropped  = MScan_M40(1:N_half, :);

%% Define Depth Range for Peak Detection (convert depth bounds from mm to meters)
depth_lower = 0.1;  % in mm
depth_upper = 0.5;  % in mm
% Since z is in meters and dz is in meters, convert mm->m by dividing by 1e3
depth_range_idx = round(depth_lower/1e3/dz):round(depth_upper/1e3/dz);

%% Loop Over Both M-Scans
scans    = {'MScan1', 'MScan40'};
MScans   = {MScan_M1_cropped, MScan_M40_cropped};
timings  = {timing_M1, timing_M40};  % if needed later

for scanNum = 1:length(scans)
    scanName   = scans{scanNum};
    MScan_crop = MScans{scanNum};
    
    % Compute Average A-Scan Magnitude (in dB)
    avg_A_scan = mean(20*log10(abs(MScan_crop)), 2);
    
    % Detect peaks within the specified depth range
    [pks, locs] = findpeaks(avg_A_scan(depth_range_idx), z(depth_range_idx), ...
                              'MinPeakHeight', -5, 'MinPeakDistance', 0.1 * 1e-3);
    % Convert peak locations (in depth) to pixel indices
    pixel_idx = round(locs / dz);
    
    fprintf('Average A-Scan Peaks (%s):\n', scanName);
    for i = 1:min(2, length(pks))
        fprintf('  Peak %d: %.2f dB at %.2f mm (Pixel %d)\n', i, pks(i), locs(i)*1e3, pixel_idx(i));
    end
    
    % Plot the average A-scan with the detected peaks
    figure("Name", sprintf("Average A-Scan Magnitude (%s)", scanName));
    plot(z * 1e3, avg_A_scan); hold on;
    plot(locs * 1e3, pks, 'bv', 'MarkerFaceColor', 'b');
    xlabel('Depth [mm]');
    ylabel('Magnitude [dB]');
    axis tight;
    exportgraphics(gcf, sprintf('figures/A_Scan_Magnitude_%s.png', scanName), 'Resolution', 300);
    
    %% Loop Over the First Two Detected Peaks and Analyze Each
    for peakIdx = 1:min(2, length(pks))
        pixel = pixel_idx(peakIdx);
        % Extract the time series at the selected pixel row
        time_series = MScan_crop(pixel, :);
        
        % Unwrap the phase of the complex time series
        phase_unwrapped = unwrap(angle(time_series));
        
        % Convert the unwrapped phase to displacement in nm
        displacement = (lambda_0/(4*pi * n_air)) * phase_unwrapped * 1e9;
        
        % Correct initial artifact by removing transient samples
        transient_samples = round(0.0015 * fs);
        displacement_corrected = displacement(transient_samples+1:end);

        t = (0:length(displacement_corrected)-1) * dt;
        
        % Plot Displacement vs. Time
        figure("Name", sprintf("Displacement vs. Time (%s, Peak %d)", scanName, peakIdx));
        plot(t, displacement_corrected);
        xlabel('Time [s]');
        ylabel('Displacement [nm]');
        axis tight;
        exportgraphics(gcf, sprintf('figures/Displacement_Time_%s_Peak%d.png', scanName, peakIdx), 'Resolution', 300);
        
        % SDPM
        N_samples = length(displacement_corrected);
        f = ((0:N_samples-1) / (N_samples * dt)) / 2;

        displacement_fft_dB = (20*log10(abs(fft(displacement_corrected))));

        displacement_fft_dB_half = displacement_fft_dB(1:floor(N_samples/2)+1);
        f_half = f(1:floor(N_samples/2)+1);
        f_threshold = 0.15 * 1e3; % kHz
        f_roi_idx = find(f_half >= f_threshold, 1);

        [pks, locs] = findpeaks(displacement_fft_dB_half(f_roi_idx:end), f_half(f_roi_idx:end), 'MinPeakHeight', 90, 'MinPeakProminence', 10);
        fprintf('Displacement Frequency Peaks (%s, Peak %d):\n', scanName, peakIdx);
        for i = 1:length(pks)
            fprintf('  Peak %d: %.2f dB at %.2f kHz\n', i, pks(i), locs(i) * 1e-3);
        end
        
        figure("Name", sprintf("Displacement Frequency Spectrum (%s, Peak %d)", scanName, peakIdx));
        plot(f_half * 1e-3, displacement_fft_dB_half); hold on;
        plot(locs * 1e-3, pks, 'bv', 'MarkerFaceColor', 'b');
        xlabel('Frequency [kHz]');
        ylabel('Amplitude [dB]');
        axis tight;
        exportgraphics(gcf, sprintf('figures/Displacement_Freq_%s_Peak%d.png', scanName, peakIdx), 'Resolution', 300);
    end
end
