clc; clear; close all;

%% System Parameters
center_wavelength = 1310e-9;   % 1310 nm in meters
dz = 3.6e-6;                 % 3.6 µm in meters
fs = 97656.25;               % Sampling frequency [Hz]

% Background counts and B-Scan geometry
D_BScan = 175;               % Number of background A-scans in BScan_Layers.raw
BScan_width = 1e-3;          % 1 mm width of B-scan

D_MScan = 320;               % Number of background A-scans in MScan files

% Polynomial order for background smoothing (experiment with this value)
polyOrder = 3;

%% Load RAW Files
% Files are assumed to be in the 'project-files' folder.
BScan_raw   = loadRawFile('project-files/BScan_Layers.raw');
MScan1_raw  = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');

%% Reshape the RAW Data
% Each A-scan is 2048 pixels.
N_axial = 2048;
BScan   = reshape(BScan_raw, N_axial, []);
MScan1  = reshape(MScan1_raw, N_axial, []);
MScan40 = reshape(MScan40_raw, N_axial, []);

%% Load the L2K Matrix
% L2K is assumed to be a 2048x2048 matrix saved in a MAT file.
load('project-files/L2K.mat', 'L2K');
assert(isequal(size(L2K), [2048, 2048]), 'L2K must be 2048x2048.');

%% Process the Data Using generateAScan
fprintf('\nProcessing BScan_Layers.raw...\n');
[A_BScan, timing_B] = generateAScan(BScan, D_BScan, polyOrder, L2K);

fprintf('\nProcessing MScan1.raw...\n');
[A_MScan1, timing_M1] = generateAScan(MScan1, D_MScan, polyOrder, L2K);

fprintf('\nProcessing MScan40.raw...\n');
[A_MScan40, timing_M40] = generateAScan(MScan40, D_MScan, polyOrder, L2K);

%% Select Example A-Scans for Display
% For BScan_Layers.raw, choose two A-scans:
A_B1 = A_BScan(:, D_BScan + 5);   % Example: a few scans past the background region
midIndex = round((size(A_BScan,2) + D_BScan) / 2);
A_B2 = A_BScan(:, midIndex);

% For MScan files, select one A-scan from each (e.g., a few columns past background)
A_M1 = A_MScan1(:, D_MScan + 5);
A_M40 = A_MScan40(:, D_MScan + 5);

%% Plot the Magnitude (in dB) of the Selected A-Scans
figure;
subplot(2,1,1);
plot(20*log10(abs(A_B1)));
title('BScan\_Layers.raw - A-Scan 1 (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');

subplot(2,1,2);
plot(20*log10(abs(A_B2)));
title('BScan\_Layers.raw - A-Scan 2 (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');

figure;
plot(20*log10(abs(A_M1)));
title('MScan1.raw - A-Scan (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');

figure;
plot(20*log10(abs(A_M40)));
title('MScan40.raw - A-Scan (Magnitude in dB)');
xlabel('Depth Index');
ylabel('Magnitude (dB)');
