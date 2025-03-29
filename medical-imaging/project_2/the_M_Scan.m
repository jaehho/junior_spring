clc; clear; close all;

%% Load RAW Files
MScan1_raw  = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');
load('project-files/L2K.mat', 'L2K');
run('dataParams.m');

%% Practically generate a B-Scan to obtain all A-Scans
[MScan_M1, timing_M1] = generateBScan(MScan1_raw, N_axial, D_MScan, L2K, true, true, false);
[MScan_M40, timing_M40] = generateBScan(MScan40_raw, N_axial, D_MScan, L2K, true, true, false);

MScan_M1_dB = 20 * log10(abs(MScan_M1));
MScan_M40_dB = 20 * log10(abs(MScan_M40));

%% Depth Axis
N_half = round(N_axial / 2);
z = (1:N_half) * dz;

MScan_M1_cropped = MScan_M1(1:N_half, :);
MScan_M40_cropped = MScan_M40(1:N_half, :);

%% Average A-Scan Magnitude

avg_A_scan_M1 = mean(20*log10(abs(MScan_M1_cropped)), 2);

depth_lower = 0.1;
depth_upper = 0.5;
depth_range_idx = round(depth_lower / 1e3 / dz):round(depth_upper / 1e3 / dz);

[pks, locs] = findpeaks(avg_A_scan_M1(depth_range_idx), z(depth_range_idx), 'MinPeakHeight', -5, 'MinPeakDistance', 0.1 * 1e-3);
pixel_idx = round(locs / dz);

fprintf('Average A-Scan Peaks (MScan1):\n');
for i = 1:length(pks)
    fprintf('Peak %d: %.2f dB at %.2f mm\n', i, pks(i), locs(i) * 1e3);
    fprintf('Pixel %d: %d\n', i, pixel_idx(i));
end

figure("Name", "Average A-Scan Magnitude (MScan1)");
plot(z * 1e3, avg_A_scan_M1); hold on;
plot(locs * 1e3, pks, 'bv', 'MarkerFaceColor', 'b');
xlabel('Depth Index [mm]');
ylabel('Magnitude [dB]');
axis tight;
saveas(gcf, 'figures/Average_AScan_MScan1.svg');

%% 2. SDPM Analysis Function
% pixel_1 = pixel_idx(1);

% Extract the time series at the selected pixel
time_series_M1 = MScan_M1_cropped(pixel, :);

% Unwrap the phase of the complex time series
phase_unwrapped_M1 = unwrap(angle(time_series_M1(1:end)));

% Convert the unwrapped phase to displacement in nm
displacement_M1 = (lambda_0/(4*pi * n_air)) * phase_unwrapped_M1 * 1e9;

% Correct initial artifact
transient_samples = round(0.0015 * fs);
displacement_M1_corrected = displacement_M1(transient_samples+1:end);

t_M1 = (0:length(displacement_M1_corrected)-1) * dt;

figure("Name", "Depth vs. Time (MScan1)");
plot(t_M1, displacement_M1_corrected);
xlabel('Time (s)');
ylabel('Depth (nm)');
axis tight;
exportgraphics(gcf, 'figures/Displacement_Time_MScan1.png', 'Resolution', 300);

% Frequency domain analysis
N1 = length(displacement_M1_corrected);
f_M1 = (0:N1-1)/(N1*dt);
displacement_fft_M1 = abs(fft(displacement_M1_corrected));

figure("Name", "Displacement Frequency Spectrum (MScan1)");
plot(f_M1, displacement_fft_M1);
xlabel('Frequency (Hz)');
ylabel('Amplitude (nm)');
exportgraphics(gcf, 'figures/Displacement_Freq_MScan1.png', 'Resolution', 300);

% %% SDPM on the 40-tone MScan
% A_scans_M40 = MScan_M40(:, D_MScan+1:end);
% time_series_M40 = A_scans_M40(pixel_1, :);
% phase_unwrapped_M40 = unwrap(angle(time_series_M40));
% displacement_M40 = (lambda_0/(4*pi * n_air)) * phase_unwrapped_M40 * 1e9;
% t_M40 = (0:length(displacement_M40)-1) * dt;

% figure("Name", "Displacement vs. Time (MScan40)");
% plot(t_M40, displacement_M40);
% xlabel('Time (s)');
% ylabel('Displacement (nm)');
% exportgraphics(gcf, 'figures/Displacement_Time_MScan40.png', 'Resolution', 300);

% % Frequency domain analysis
% N40 = length(displacement_M40);
% f_M40 = (0:N40-1)/(N40*dt);
% displacement_fft_M40 = abs(fft(displacement_M40));

% figure("Name", "Displacement Frequency Spectrum (MScan40)");
% plot(f_M40, displacement_fft_M40);
% xlabel('Frequency (Hz)');
% ylabel('Amplitude');
% exportgraphics(gcf, 'figures/Displacement_Freq_MScan40.png', 'Resolution', 300);
