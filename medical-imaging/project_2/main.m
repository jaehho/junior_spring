clc; clear; close all;

% Load raw files
BScan_raw = loadRawFile('project-files/BScan_Layers.raw');
MScan1_raw = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');

%% Data Analysis

% Axial scan parameters
N_axial = 2048; % Number of pixels per A-scan

% Reshape assuming 2048 points per A-scan
BScan = reshape(BScan_raw, N_axial, []);
MScan1 = reshape(MScan1_raw, N_axial, []);
MScan40 = reshape(MScan40_raw, N_axial, []);

% Get sizes (nPixels should be 2048)
[nPixels_B, nScans_B] = size(BScan);    
[nPixels_M1, nScans_M1] = size(MScan1);
[nPixels_M40, nScans_M40] = size(MScan40);

% Background samples
D_BScan = 175;
D_MScan = 320;

% Describe structure
fprintf('BScan_Layers.raw: %d total columns, %d background, %d A-scans\n', ...
        nScans_B, D_BScan, nScans_B - D_BScan);

fprintf('MScan1.raw: %d total columns, %d background, %d A-scans\n', ...
        nScans_M1, D_MScan, nScans_M1 - D_MScan);

fprintf('MScan40.raw: %d total columns, %d background, %d A-scans\n', ...
        nScans_M40, D_MScan, nScans_M40 - D_MScan);


%% OCT System Parameters
lambda0 = 1310e-9; % Center wavelength [m]
delta_lambda = 100e-9; % Spectral bandwidth [m]
NA = 0.055; % Numerical Aperture
dz = 3.6e-6; % Axial pixel size [m]
n_air = 1.0; % Refractive index of air

fs = 97656.25; % Sampling frequency for MScan [Hz]

% B-Scan setup
BScan_width = 1.0e-3; % Width of B-scan [m]
M = nScans_B - D_BScan; % Number of A-scans in B-scan (adjust if known)

%% 1. Lateral Resolution (Diffraction-limited)
lateral_res = 0.37 * lambda0 / NA; % frost paper

%% 2. Axial Resolution (Coherence length-based)
axial_res = (2 * log(2)) / (n_air * pi) * lambda0^2 / delta_lambda; % frost paper
% Limited by occlusion

%% 3. B-Scan Aspect Ratios
dx = BScan_width / M; % Lateral sampling step [m]
depth_full = N_axial * dz; % Full depth span [m]
depth_half = (N_axial / 2) * dz; % Depth after mirror artifact correction

aspect_ratio_full = BScan_width / depth_full;
aspect_ratio_corrected = BScan_width / depth_half;

%% Output Results (converted to micrometers for display)
fprintf('--- OCT System Resolution and Geometry ---\n');
fprintf('Lateral Resolution      : %.2f µm\n', lateral_res * 1e6);
fprintf('Axial Resolution        : %.2f µm\n', axial_res * 1e6);
fprintf('Lateral Sampling Step   : %.2f µm\n', dx * 1e6);
fprintf('Axial Range (Full)      : %.2f µm\n', depth_full * 1e6);
fprintf('Axial Range (Corrected) : %.2f µm\n', depth_half * 1e6);
fprintf('Aspect Ratio (Full)     : %.3f\n', aspect_ratio_full);
fprintf('Aspect Ratio (Corrected): %.3f\n', aspect_ratio_corrected);
