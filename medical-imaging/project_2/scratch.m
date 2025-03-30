clc; close all; clear;
% Load the L2K matrix
load('L2K.mat', 'L2K');
% Define constants
fs = 97656.25;         % Sampling frequency in Hz
lambda0 = 1310e-9;     % Central wavelength in meters
n = 1;                 % Refractive index
dz = 3.6e-3;           % Axial resolution in mm/pixel
bg_columns = 320;      % Number of background columns
num_z_pixels = 1024;   % First half of FFT output
z = (0:num_z_pixels-1)' * dz; % Depth axis in mm
filename = 'MScan40.raw';
fid = fopen(filename, 'r', 'l');
raw_data = fread(fid, Inf, 'uint16');
fclose(fid);
% Reshape into 2048 x num_scans
num_scans = length(raw_data) / 2048;
raw_data = reshape(raw_data, 2048, num_scans);
data_columns = num_scans - bg_columns;
% Process
[M_Scan, ~] = process_BScan(raw_data, bg_columns, L2K, true);
% Take first half (positive depths)
M_Scan = M_Scan(1:num_z_pixels, :);
% Compute average A-Scan magnitude
avg_mag_linear = mean(abs(M_Scan), 2);
avg_mag_dB = 20 * log10(avg_mag_linear);
% Plot average A-Scan magnitude
figure('Name', 'MScan40 Average A-Scan', 'Position', [100, 100, 800, 300]);
plot(z, avg_mag_dB, 'b-', 'LineWidth', 1.5);
title('Average A-Scan Magnitude for MScan40.raw (40-Tone)');
xlabel('Depth (mm)');
ylabel('Magnitude (dB)');
grid on;
axis([0 max(z) min(avg_mag_dB)-5 max(avg_mag_dB)+5]);
%pixels selected
pixel1 = 61; % Example: Depth 0.216 mm
pixel2 = 94; % Example: Depth 0.3348 mm
% Time vector
t = (0:data_columns-1) / fs;
% Remove first 1 ms
transient_samples = round(0.001 * fs);
M_Scan = M_Scan(:, transient_samples+1:end);
t = t(transient_samples+1:end);
% SDPM for both pixels
disp1 = sdpm(M_Scan, pixel1, lambda0, n); %nm
disp2 = sdpm(M_Scan, pixel2, lambda0, n);
% Frequency analysis
N = length(t);
freq = (0:floor(N/2)) * (fs / N) / 1000; % f in kHz
% start at 0.1kHz
min_freq = 0.1;
freq_idx_start = find(freq >= min_freq, 1);
fft_disp1 = fft(disp1, N);
mag_fft1 = abs(fft_disp1(1:floor(N/2)+1));
mag_fft1_dB = 20 * log10(mag_fft1(freq_idx_start:end));
freq_plot1 = freq(freq_idx_start:end);
[pks1, locs1] = findpeaks(mag_fft1_dB, 'MinPeakHeight', 97);
tone_freqs1 = freq_plot1(locs1);
fft_disp2 = fft(disp2, N);
mag_fft2 = abs(fft_disp2(1:floor(N/2)+1));
mag_fft2_dB = 20 * log10(mag_fft2(freq_idx_start:end));
freq_plot2 = freq(freq_idx_start:end);
[pks2, locs2] = findpeaks(mag_fft2_dB, 'MinPeakHeight', 97);
tone_freqs2 = freq_plot2(locs2);
figure('Name', 'MScan40 SDPM Analysis - Pixel 1', 'Position', [100, 400, 800, 600]);
subplot(3, 1, 1);
plot(t, disp1, 'b-');
title(['Displacement at Pixel ', num2str(pixel1), ' (Depth ', num2str(z(pixel1)), ' mm)']);
xlabel('Time (s)');
ylabel('Displacement (nm)');
grid on;
subplot(3, 1, 2);
plot(t, disp1, 'b-');
title(['Zoomed Displacement at Pixel ', num2str(pixel1)]);
xlabel('Time (s)');
ylabel('Displacement (nm)');
xlim([t(1) t(1)+0.005]);
grid on;
subplot(3, 1, 3);
plot(freq_plot1, mag_fft1_dB, 'b-');
hold on;
plot(tone_freqs1, pks1, 'ro');
title(['Spectrum at Pixel ', num2str(pixel1)]);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
xlim([min_freq 49]);
grid on;
figure('Name', 'MScan40 SDPM Analysis - Pixel 2', 'Position', [150, 450, 800, 600]);
subplot(3, 1, 1);
plot(t, disp2, 'b-');
title(['Displacement at Pixel ', num2str(pixel2), ' (Depth ', num2str(z(pixel2)), ' mm)']);
xlabel('Time (s)');
ylabel('Displacement (nm)');
grid on;
subplot(3, 1, 2);
plot(t, disp2, 'b-');
title(['Zoomed Displacement at Pixel ', num2str(pixel2)]);
xlabel('Time (s)');
ylabel('Displacement (nm)');
xlim([t(1) t(1)+0.005]);
grid on;
subplot(3, 1, 3);
plot(freq_plot2, mag_fft2_dB, 'b-');
hold on;
plot(tone_freqs2, pks2, 'ro');
title(['Spectrum at Pixel ', num2str(pixel2)]);
xlabel('Frequency (kHz)');
ylabel('Magnitude (dB)');
xlim([min_freq 49]);
grid on;
disp('Pixel 1 Tones (kHz):');
disp(tone_freqs1');
disp('Pixel 2 Tones (kHz):');
disp(tone_freqs2');
% Function to process the B-Scan
function [B_Scan, times] = process_BScan(raw_data, bg_columns, L2K, do_deconv)
times = struct();
background_lambda = raw_data(:, 1:bg_columns);
background_k = L2K * double(background_lambda);
background = mean(background_k, 2);
k_indices = (1:2048)';
p = polyfit(k_indices, background, 3);
background_smooth = polyval(p, k_indices);
data_lambda = raw_data(:, bg_columns+1:end);
data_k = L2K * double(data_lambda);
data_bg_sub = data_k - background;
window = hamming(2048);
data_windowed = data_bg_sub .* window;
if do_deconv
    data_processed = data_windowed ./ (background_smooth);
else
    data_processed = data_windowed;
end
B_Scan = fft(data_processed, [], 1);
end
% SDPM function
function d = sdpm(mscan, pixel_idx, lambda0, n)
complex_ts = mscan(pixel_idx, :);
phase = unwrap(angle(complex_ts));
d = (lambda0 * phase) / (4 * pi * n) * 1e9; % Convert to nm
end