clc; clear; close all;

center_wavelength = 1310e-9; % center wavelength in meters
fs = 97656.25; % sampling rate [Hz]
dt = 1/fs; % time interval between A-Scans
D_MScan = 320; % number of background A-Scans in MScan files
N_axial = 2048; % number of pixels per A-scan

%% Load RAW Files
MScan1_raw  = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');
load('project-files/L2K.mat', 'L2K');

%% Reshape RAW Data
MScan1  = reshape(MScan1_raw, N_axial, []);
MScan40 = reshape(MScan40_raw, N_axial, []);

%% Practically Generate a B-Scan to obtain all A-Scans
[BScan_M1, timing_M1] = generateBScan(MScan1, D_MScan, L2K);
[BScan_M40, timing_M40] = generateBScan(MScan40, D_MScan, L2K);

%% 1. Average A-Scan Magnitude from the 1-tone MScan
A_scans_M1 = BScan_M1(:, D_MScan+1:end);
avg_A_scan_M1 = mean(abs(A_scans_M1), 2);
[pks, locs] = findpeaks(20*log10(avg_A_scan_M1), 'MinPeakHeight', -5, 'MinPeakDistance', 10);
fprintf('Average A-Scan Peaks (MScan1):\n');
% print peaks that are after index N_axial/2
for i = 1:length(pks)
    % if locs(i) < N_axial/2
    %     continue;
    % end
    fprintf('Peak %d: %.2f dB at index %d\n', i, pks(i), locs(i));
end

figure;
plot(20*log10(avg_A_scan_M1));
title('Average A-Scan Magnitude (MScan1)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
saveas(gcf, 'figures/Average_AScan_MScan1.svg');

%% 2. SDPM Analysis Function
pixel_1 = 1962;

%% (a) SDPM on the 1-tone MScan
% Extract the time series at the selected pixel
time_series_M1 = A_scans_M1(pixel_1, :);

% Unwrap the phase of the complex time series
phase_unwrapped_M1 = unwrap(angle(time_series_M1));

% Convert the unwrapped phase to displacement in nm
displacement_M1 = (center_wavelength/(4*pi)) * phase_unwrapped_M1 * 1e9;

% Time axis for plotting
t_M1 = (0:length(displacement_M1)-1) * dt;

figure;
plot(t_M1, displacement_M1);
title('Displacement vs. Time (MScan1)');
xlabel('Time (s)');
ylabel('Displacement (nm)');
exportgraphics(gcf, 'figures/Displacement_Time_MScan1.png', 'Resolution', 300);

% Frequency domain analysis
N1 = length(displacement_M1);
f_M1 = (0:N1-1)/(N1*dt);
displacement_fft_M1 = abs(fft(displacement_M1));

figure;
plot(f_M1, displacement_fft_M1);
title('Displacement Frequency Spectrum (MScan1)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
exportgraphics(gcf, 'figures/Displacement_Freq_MScan1.png', 'Resolution', 300);

%% SDPM on the 40-tone MScan
A_scans_M40 = BScan_M40(:, D_MScan+1:end);   % extract A-scans (complex data) from MScan40
time_series_M40 = A_scans_M40(pixel_1, :);
phase_unwrapped_M40 = unwrap(angle(time_series_M40));
displacement_M40 = (center_wavelength/(4*pi)) * phase_unwrapped_M40 * 1e9;
t_M40 = (0:length(displacement_M40)-1) * dt;

figure;
plot(t_M40, displacement_M40);
title('Displacement vs. Time (MScan40)');
xlabel('Time (s)');
ylabel('Displacement (nm)');
exportgraphics(gcf, 'figures/Displacement_Time_MScan40.png', 'Resolution', 300);

% Frequency domain analysis
N40 = length(displacement_M40);
f_M40 = (0:N40-1)/(N40*dt);
displacement_fft_M40 = abs(fft(displacement_M40));

figure;
plot(f_M40, displacement_fft_M40);
title('Displacement Frequency Spectrum (MScan40)');
xlabel('Frequency (Hz)');
ylabel('Amplitude');
exportgraphics(gcf, 'figures/Displacement_Freq_MScan40.png', 'Resolution', 300);
