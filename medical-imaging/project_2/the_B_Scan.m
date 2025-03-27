clc; clear; close all;

N_axial = 2048; % Number of pixels per A-scan (axial samples)
D_BScan = 175; % Number of background A-scans
BScan_width = 1e-3; % 1 mm lateral span
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

%% Depth Axis
N_half = round(N_axial / 2);
z = (0:N_half-1) * dz;

BScan_mag_crop = BScan_mag(N_half:end, :);  % Crop vertically

%% Display the Cropped B-Scan
x = linspace(0, BScan_width, M); % Lateral axis

figure;
imagesc(x * 1e3, z * 1e3, BScan_mag_crop); % Convert to mm
colormap(gray);
clim([-30 10]);
xlabel('Lateral Position (mm)');
ylabel('Depth (mm)');
title('Cropped B-Scan');
axis image;
exportgraphics(gcf, 'figures/BScan_Processed_Cropped_mm.png', 'Resolution', 300);