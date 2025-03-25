clc; clear; close all;

%% System Parameters
center_wavelength = 1310e-9;   % 1310 nm in meters
dz = 3.6e-6; % 3.6 um in meters
fs = 97656.25; % Sampling frequency [Hz]

% Background counts and B-Scan geometry
D_BScan = 175; % Number of background A-scans in BScan_Layers.raw
BScan_width = 1e-3; % 1 mm width of B-scan

D_MScan = 320; % Number of background A-scans in MScan files

%% Load RAW Files
% RAW files are binary little-endian unsigned 16-bit integers.
BScan_raw   = loadRawFile('project-files/BScan_Layers.raw');
MScan1_raw  = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');

%% Reshape RAW Data (each A-scan is 2048 pixels)
N_axial = 2048;
BScan   = reshape(BScan_raw, N_axial, []);
MScan1  = reshape(MScan1_raw, N_axial, []);
MScan40 = reshape(MScan40_raw, N_axial, []);

%% Load the L2K Matrix (2048x2048)
load('project-files/L2K.mat', 'L2K');

%% Process the Data Entirely in the k Domain Using generateAScan_k
fprintf('\nProcessing BScan_Layers.raw...\n');
[AScan_B, timing_B] = generateAScan(BScan, D_BScan, L2K);

fprintf('\nProcessing MScan1.raw...\n');
[AScan_M1, timing_M1] = generateAScan(MScan1, D_MScan, L2K);

fprintf('\nProcessing MScan40.raw...\n');
[AScan_M40, timing_M40] = generateAScan(MScan40, D_MScan, L2K);

%% Select Example A-Scans for Display
% For BScan_Layers.raw, choose two A-scans:
A_B1 = AScan_B(:, D_BScan + 5);   % e.g., a few scans past the background region.
midIndex = round((size(AScan_B, 2) + D_BScan) / 2);
A_B2 = AScan_B(:, midIndex);

% For the MScan files, select one A-scan from each (e.g., a few columns past the background region).
A_M1 = AScan_M1(:, D_MScan + 5);
A_M40 = AScan_M40(:, D_MScan + 5);

%% Plot the Magnitude (in dB) of the Selected A-Scans
figure;
plot(20*log10(abs(A_B1)));
title('BScan\_Layers.raw - A-Scan 1 (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
saveas(gcf, 'figures/AScan_B1.png');

figure;
plot(20*log10(abs(A_B2)));
title('BScan\_Layers.raw - A-Scan 2 (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
saveas(gcf, 'figures/AScan_B2.png');

figure;
plot(20*log10(abs(A_M1)));
title('MScan1.raw - A-Scan (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
saveas(gcf, 'figures/AScan_M1.png');

figure;
plot(20*log10(abs(A_M40)));
title('MScan40.raw - A-Scan (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
saveas(gcf, 'figures/AScan_M40.png');