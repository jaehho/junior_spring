clc; clear; close all;

dz = 3.6e-6; % 3.6 um in meters
fs = 97656.25; % Sampling frequency [Hz]
D_BScan = 175; % Number of background A-scans in BScan_Layers.raw
BScan_width = 1e-3; % 1 mm width of B-scan
D_MScan = 320; % Number of background A-scans in MScan files
N_axial = 2048; % Number of pixels per A-scan

%% Load RAW Files
BScan_raw   = loadRawFile('project-files/BScan_Layers.raw');
MScan1_raw  = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');
load('project-files/L2K.mat', 'L2K');

%% Process the Data Entirely in the k Domain Using generateAScan_k
fprintf('\nProcessing BScan_Layers.raw...\n');
[BScan_B, timing_B] = generateBScan(BScan_raw, N_axial, D_BScan, L2K, true, true, true);

fprintf('\nProcessing MScan1.raw...\n');
[BScan_M1, timing_M1] = generateBScan(MScan1_raw, N_axial, D_MScan, L2K, true, true, true);

fprintf('\nProcessing MScan40.raw...\n');
[BScan_M40, timing_M40] = generateBScan(MScan40_raw, N_axial, D_MScan, L2K, true, true, true);

%% Select Example A-Scans for Display
AScan_B1 = BScan_B(:, D_BScan + 5);   % a few scans past the background region.
AScan_B2 = BScan_B(:, round((size(BScan_B, 2) + D_BScan) / 2) + 1);
AScan_M1 = BScan_M1(:, D_MScan + 5);
AScan_M40 = BScan_M40(:, D_MScan + 5);

%% Plot the Magnitude (in dB) of the Selected A-Scans
figure;
plot(20*log10(abs(AScan_B1)));
title('BScan\_Layers.raw - A-Scan 1 (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
exportgraphics(gcf, 'figures/AScan_B1.png', 'Resolution', 300);

figure;
plot(20*log10(abs(AScan_B2)));
title('BScan\_Layers.raw - A-Scan 2 (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
exportgraphics(gcf, 'figures/AScan_B2.png', 'Resolution', 300);

figure;
plot(20*log10(abs(AScan_M1)));
title('MScan1.raw - A-Scan (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
exportgraphics(gcf, 'figures/AScan_M1.png', 'Resolution', 300);

figure;
plot(20*log10(abs(AScan_M40)));
title('MScan40.raw - A-Scan (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
exportgraphics(gcf, 'figures/AScan_M40.png', 'Resolution', 300);