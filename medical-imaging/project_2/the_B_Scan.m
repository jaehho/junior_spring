clc; clear; close all;

N_axial = 2048;                   % Number of pixels per A-scan (axial samples)
D_BScan = 175;                    % Number of background A-scans
BScan_width = 1e-3;               % 1 mm lateral span
dz = 3.6e-6; % Axial resolution [m]

%% Load the RAW File and L2K matrix
BScan_raw = loadRawFile('project-files/BScan_Layers.raw');
load('project-files/L2K.mat', 'L2K');  % Loads variable 'L2K'

%% Reshape RAW Data into [N_axial x (D + M)]
BScan = reshape(BScan_raw, N_axial, []);  % Each column is one A-scan
M = size(BScan, 2) - D_BScan;             % Number of imaging A-scans

%% Process the B-Scan
[BScan_fft, timing] = generateBScan(BScan, D_BScan, L2K);

%% Convert to Magnitude (dB)
BScan_mag = 20 * log10(abs(BScan_fft));
BScan_mag = BScan_mag - max(BScan_mag(:));  % Normalize to max = 0 dB

%% Crop B-Scan Vertically and Convert to Millimeters
N_half = round(N_axial / 2);          % Keep top half of depth
depth_mm = (0:N_half-1) * dz * 1e3;   % Convert to millimeters

BScan_mag_crop = BScan_mag(1:N_half, :);  % Crop vertically

%% Display the Cropped B-Scan
x_mm = linspace(0, BScan_width * 1e3, M); % Lateral axis in mm

figure;
imagesc(x_mm, depth_mm, BScan_mag_crop);
colormap(gray);
clim([-90 0]);  % dB range
colorbar;
xlabel('Lateral Position (mm)');
ylabel('Depth (mm)');
title('Cropped B-Scan (Top Half, Magnitude in dB)');
set(gca, 'YDir', 'normal');  % Deeper as y increases
axis image;
saveas(gcf, 'figures/BScan_Processed_Cropped_mm.svg');

%% Display Timing Information
disp('Timing breakdown (in seconds):');
disp(timing);
