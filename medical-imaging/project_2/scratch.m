clc; close all; clear;
% Load the L2K matrix
load('project-files/L2K.mat', 'L2K');
% Load BScan_Layers.raw
fid = fopen('project-files/BScan_Layers.raw', 'r', 'l'); % 'l' for little-endian
raw_data_bscan = fread(fid, Inf, 'uint16');
fclose(fid);
% Reshape the raw data into 2048 rows x number of scans
num_scans_bscan = length(raw_data_bscan) / 2048;
raw_data_bscan = reshape(raw_data_bscan, 2048, num_scans_bscan);
bg_columns_bscan = 175; % Number of background columns
data_columns_bscan = num_scans_bscan - bg_columns_bscan; % Number of data columns
% Process the B-Scan with deconvolution
[B_Scan_with_deconv, ~] = process_BScan(raw_data_bscan, bg_columns_bscan, L2K, true);
% Process the B-Scan without deconvolution (for comparison in Plot 2)
[B_Scan_without_deconv, ~] = process_BScan(raw_data_bscan, bg_columns_bscan, L2K, false);
% Compute magnitudes (first half of FFT output)
num_z_pixels = size(B_Scan_with_deconv, 1) / 2;
B_Scan_with_deconv_mag = 20 * log10(abs(B_Scan_with_deconv(1:num_z_pixels, :)));
B_Scan_without_deconv_mag = 20 * log10(abs(B_Scan_without_deconv(1:num_z_pixels, :)));
% Calculate physical dimensions for correct aspect ratio
dz = 3.6e-3; % Axial resolution: 3.6 µm/pixel = 0.0036 mm/pixel
z = (0:num_z_pixels-1)' * dz; % Depth axis in mm, as column vector
dy = 1 / data_columns_bscan; % Lateral resolution: 1 mm total width / number of A-Scans
y = (0:data_columns_bscan-1) * dy; % Lateral axis in mm
% Apply amplitude-based adjustment to B-Scan with deconvolution
B_Scan_with_deconv_adjusted = B_Scan_with_deconv_mag;
mask_high_with = B_Scan_with_deconv_mag > 3;
mask_low_with = B_Scan_with_deconv_mag < 3;
B_Scan_with_deconv_adjusted(mask_high_with) = B_Scan_with_deconv_mag(mask_high_with) + 40;
B_Scan_with_deconv_adjusted(mask_low_with) = B_Scan_with_deconv_mag(mask_low_with) - 40;
% Apply Gaussian filter to the adjusted B-Scan with deconvolution
sigma = 1; % Gaussian filter standard deviation, adjustable if needed
B_Scan_with_deconv_filtered = imgaussfilt(B_Scan_with_deconv_adjusted, sigma);
% Figure 1: Original vs. Processed with Deconvolution
figure('Name', 'Figure 1: Deconvolution Comparison', 'Position', [100, 100, 800, 400]);
% Subplot 1: Original B-Scan with Deconvolution
subplot(1, 2, 1);
imagesc(y, z, B_Scan_with_deconv_mag);
colormap gray;
title('Original B-Scan with Deconvolution');
xlabel('Lateral Position (mm)');
ylabel('Depth (mm)');
axis image;
% Subplot 2: Processed B-Scan with Deconvolution
subplot(1, 2, 2);
imagesc(y, z, B_Scan_with_deconv_filtered);
colormap gray;
title('Processed B-Scan with Deconvolution');
xlabel('Lateral Position (mm)');
ylabel('Depth (mm)');
axis image;
% Set consistent color limits for the left subplot in Figure 1
clim_left = [-40, 35];
subplot(1, 2, 1);
clim(clim_left);
% Set color limits for the right subplot in Figure 1
clim_right_fig1 = [min(B_Scan_with_deconv_filtered(:)), max(B_Scan_with_deconv_filtered(:))-10];
subplot(1, 2, 2);
clim(clim_right_fig1);
% Figure 2: Original with Deconvolution vs. Original without Deconvolution
figure('Name', 'Figure 2: Deconvolution Effect', 'Position', [100, 600, 800, 400]);
% Subplot 1: Original B-Scan with Deconvolution
subplot(1, 2, 1);
imagesc(y, z, B_Scan_with_deconv_mag);
colormap gray;
title('Original B-Scan with Deconvolution');
xlabel('Lateral Position (mm)');
ylabel('Depth (mm)');
axis image;
% Subplot 2: Original B-Scan without Deconvolution
subplot(1, 2, 2);
imagesc(y, z, B_Scan_without_deconv_mag);
colormap gray;
title('Original B-Scan without Deconvolution');
xlabel('Lateral Position (mm)');
ylabel('Depth (mm)');
axis image;
% Set consistent color limits for the left subplot in Figure 2
subplot(1, 2, 1);
clim(clim_left); % Use the same color limits as in Figure 1 for the left subplot
% Set color limits for the right subplot in Figure 2
caxis_right_fig2 = [20, 80];
subplot(1, 2, 2);
clim(caxis_right_fig2);
% Function to process the B-Scan with or without deconvolution
function [B_Scan, times] = process_BScan(raw_data, bg_columns, L2K, do_deconv)
    times = struct();
    % Convert background to k-domain and compute the average
    background_lambda = raw_data(:, 1:bg_columns);
    background_k = L2K * background_lambda;
    background = mean(background_k, 2);
    % Smooth the background in k-domain using a polynomial fit
    k_indices = (1:2048)';
    p = polyfit(k_indices, background, 3); % 3rd-order polynomial
    background_smooth = polyval(p, k_indices);
    % Convert all A-Scans to k-domain
    data_lambda = raw_data(:, bg_columns+1:end);
    data_k = L2K * data_lambda;
    % Subtract the background
    data_bg_sub = data_k - background_smooth;
    % Apply Hamming window
    window = hamming(2048);
    data_windowed = data_bg_sub .* window;
    % Deconvolution
    if do_deconv
        data_processed = data_windowed ./ (background_smooth);
    else
        data_processed = data_windowed;
    end
    % Fourier transform to spatial domain
    B_Scan = fft(data_processed, [], 1);
end