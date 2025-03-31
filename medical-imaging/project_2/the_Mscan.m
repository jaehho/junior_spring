clc; clear; close all;
fclose(fopen('figures/the_Mscan.txt', 'w'));
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
z_half = (1:N_half) * dz;  % z in meters

Mscan_M1_half   = Mscan_M1(1:N_half, :);
Mscan_M40_half  = Mscan_M40(1:N_half, :);

%% Define Depth Range for Peak Detection (convert depth bounds from mm to meters)
depth_lower = 0.1;  % in mm
depth_upper = 0.5;  % in mm
depth_range_idx = round(depth_lower/1e3/dz):round(depth_upper/1e3/dz);

%% Define scans and corresponding data
scans    = {'Mscan1', 'Mscan40'};
Mscans_half   = {Mscan_M1_half, Mscan_M40_half};
timings  = {timing_M1, timing_M40};  % if needed later

%% ----- Average Ascan Magnitude Plots for Both Scans in One Figure -----
fig_avg = figure("Name", "Average Ascan Magnitude (Both Scans)");
tlo_avg = tiledlayout(length(scans), 1, "TileSpacing", "none", "Padding", "tight");

numPeaks = 2; % Number of peaks to analyze
ax_avg = gobjects(length(scans));
ax_fig_disp = gobjects(length(scans), numPeaks);
ax_fig_zoom = gobjects(length(scans), numPeaks);
ax_fig_fft = gobjects(length(scans), numPeaks);
for scanNum = 1:length(scans)
    scanName   = scans{scanNum};
    Mscan_half = Mscans_half{scanNum};
    
    % Compute Average Ascan Magnitude (in dB)
    avg_Ascan_half = mean(20*log10(abs(Mscan_half)), 2);
    
    % Detect peaks
    [pks, locs] = findpeaks(avg_Ascan_half(depth_range_idx), z_half(depth_range_idx), ...
                              'MinPeakHeight', -5, 'MinPeakDistance', 0.1 * 1e-3, 'NPeaks', numPeaks);
    pixel_idx = round(locs / dz);
    
    fprintf('Average Ascan Peaks (%s):\n', scanName);
    for i = 1:numPeaks
        fprintf('  Peak %d: %.2f dB at %.2f mm (Pixel %d)\n', i, pks(i), locs(i)*1e3, pixel_idx(i));
    end

    % Plot in tiled layout
    ax_avg(scanNum) = nexttile(tlo_avg);
    plot(z_half * 1e3, avg_Ascan_half); hold on;
    plot(locs * 1e3, pks, 'bv', 'MarkerFaceColor', 'b');
    % title(sprintf('Average Ascan (%s)', scanName));
    text(0.01, 1, sprintf('%s', char('A' + (scanNum - 1))), 'Units', 'normalized', ...
        'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
    axis tight;

    %% ----- Displacement vs. Time -----
    % Prepare for displacement vs. time figure
    fig_disp = figure("Name", sprintf("Displacement vs. Time (%s)", scanName));
    tlo_disp = tiledlayout(numPeaks, 1, "TileSpacing", "none", "Padding", "tight");
    
    % Prepare for zoomed displacement vs. time figure
    fig_zoom = figure("Name", sprintf("Zoomed Displacement vs Time (%s)", scanName));
    tlo_zoom = tiledlayout(numPeaks, 1, "TileSpacing", "none", "Padding", "tight");
    
    % Prepare for FFT figure
    fig_fft = figure("Name", sprintf("Displacement Frequency Spectrum (%s)", scanName));
    tlo_freq = tiledlayout(numPeaks, 1, "TileSpacing", "none", "Padding", "tight");
    for peakIdx = 1:numPeaks
        pixel = pixel_idx(peakIdx);
        time_series = Mscan_half(pixel, :);
        phase_unwrapped = unwrap(angle(time_series));
        displacement_nm = (lambda_0/(4*pi * n_air)) * phase_unwrapped * 1e9;
        transient_samples = round(0.0015 * fs);
        displacement_nm_corrected = displacement_nm(transient_samples+1:end);
        displacement_nm_scaled = displacement_nm_corrected - min(displacement_nm_corrected);
        t = (0:length(displacement_nm_scaled)-1) * dt;

        % Plot Displacement vs Time
        ax_fig_disp(scanNum, peakIdx) = nexttile(tlo_disp);
        plot(t, displacement_nm_scaled);
        % title(sprintf('Peak %d (Pixel %d)', peakIdx, pixel));
        text(0.01, 1, sprintf('%s', char('A' + (peakIdx - 1))), 'Units', 'normalized', ...
            'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
        axis tight;
        
        % Plot zoomed-in view
        ax_fig_zoom(scanNum, peakIdx) = nexttile(tlo_zoom);
        plot(t * 1e3, displacement_nm_scaled); % time in ms
        xlim([0 5]); 
        % title(sprintf('Peak %d (Pixel %d)', peakIdx, pixel));
        text(0.01, 1, sprintf('%s', char('A' + (peakIdx - 1))), 'Units', 'normalized', ...
            'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

        % FFT Spectrum
        N_samples = length(displacement_nm_scaled);
        f = ((0:N_samples-1) / (N_samples * dt)) / 2;
        fft_vals = fft(displacement_nm_scaled);
        fft_dB = 20*log10(abs(fft_vals));
        half_idx = floor(N_samples/2)+1;
        fft_dB_half = fft_dB(1:half_idx);
        f_half = f(1:half_idx);
        f_threshold = 0.15 * 1e3;
        f_roi_idx = find(f_half >= f_threshold, 1);
        [pks_fft, locs_fft] = findpeaks(fft_dB_half(f_roi_idx:end), f_half(f_roi_idx:end), ...
                                        'MinPeakHeight', 90, 'MinPeakProminence', 10);
        fprintf('Displacement Frequency Peaks (%s, Peak %d):\n', scanName, peakIdx);
        for i = 1:length(pks_fft)
            fprintf('  Peak %d: %.2f dB at %.2f kHz\n', i, pks_fft(i), locs_fft(i) * 1e-3);
        end

        % Plot FFT
        ax_fig_fft(scanNum, peakIdx) = nexttile(tlo_freq);
        plot(f_half * 1e-3, fft_dB_half); hold on;
        plot(locs_fft * 1e-3, pks_fft, 'bv', 'MarkerFaceColor', 'b');
        % title(sprintf('Peak %d (Pixel %d)', peakIdx, pixel));
        text(0.01, 1, sprintf('%s', char('A' + (peakIdx - 1))), 'Units', 'normalized', ...
            'Color', 'k', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
        axis tight;
    end
    % Link axes for displacement and FFT figures
    linkaxes([ax_fig_disp(scanNum, :)], 'xy');
    linkaxes([ax_fig_zoom(scanNum, :)], 'xy');
    linkaxes([ax_fig_fft(scanNum, :)], 'xy');
    % Remove tick labels from interior axes to create a shared tick effect:
    ax_fig_disp(scanNum, 1).XTickLabel = [];
    ax_fig_zoom(scanNum, 1).XTickLabel = [];
    ax_fig_fft(scanNum, 1).XTickLabel = [];
    % Add common x and y labels for the entire tiled layout:
    xlabel(tlo_disp, 'Time [s]');
    ylabel(tlo_disp, 'Displacement [nm]');
    xlabel(tlo_zoom, 'Time [ms]');
    ylabel(tlo_zoom, 'Displacement [nm]');
    xlabel(tlo_freq, 'Frequency [kHz]');
    ylabel(tlo_freq, 'Amplitude [dB]');
    % Save each scan's figures
    exportgraphics(fig_disp, sprintf('figures/Displacement_Time_%s.png', scanName), 'Resolution', 300);
    exportgraphics(fig_zoom, sprintf('figures/Displacement_Time_Zoom_%s.png', scanName), 'Resolution', 300);
    exportgraphics(fig_fft, sprintf('figures/Displacement_Freq_%s.png', scanName), 'Resolution', 300);
end

% Link axes for average Ascan figure
linkaxes(ax_avg, 'xy');
% Remove tick labels from interior axes to create a shared tick effect:
ax_avg(1).XTickLabel = [];
% Add common x and y labels for the entire tiled layout:
xlabel(tlo_avg, 'Depth [mm]');
ylabel(tlo_avg, 'Magnitude [dB]');

% Save the average Ascan figure
exportgraphics(fig_avg, 'figures/Average_Ascan_AllScans.png', 'Resolution', 300);

diary off;
