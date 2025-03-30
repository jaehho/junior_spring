clc; clear; close all;
fclose(fopen('figures/guiding_computations.txt', 'w'));
diary('figures/guiding_computations.txt'); % Start logging to a file
diary on;

% Load raw files
Bscan_raw = loadRawFile('project-files/Bscan_Layers.raw');
Mscan1_raw = loadRawFile('project-files/Mscan1.raw');
Mscan40_raw = loadRawFile('project-files/Mscan40.raw');
run('dataParams.m');

% Reshape
Bscan = reshape(Bscan_raw, N_axial, []);
Mscan1 = reshape(Mscan1_raw, N_axial, []);
Mscan40 = reshape(Mscan40_raw, N_axial, []);

% Get sizes
[nPixels_B, nScans_B] = size(Bscan);    
[nPixels_M1, nScans_M1] = size(Mscan1);
[nPixels_M40, nScans_M40] = size(Mscan40);

% Describe structure
fprintf('Bscan_Layers.raw: %d total columns, %d background, %d Ascans\n', ...
        nScans_B, D_Bscan, nScans_B - D_Bscan);

fprintf('Mscan1.raw: %d total columns, %d background, %d Ascans\n', ...
        nScans_M1, D_Mscan, nScans_M1 - D_Mscan);

fprintf('Mscan40.raw: %d total columns, %d background, %d Ascans\n', ...
        nScans_M40, D_Mscan, nScans_M40 - D_Mscan);

%% Resolutions
% Lateral Resolution 
lateral_res = 0.37 * lambda_0 / NA; 

% Axial Resolution
axial_res = (2 * log(2)) / (n_air * pi) * (lambda_0^2 / delta_lambda);

%% 3. Bscan Aspect Ratios
dx = Bscan_width / (nScans_B - D_Bscan); % Lateral sampling step [m]
depth_full = N_axial * dz; % Full depth span [m]
depth_half = depth_full / 2; % Half depth span [m]

aspect_ratio_full = Bscan_width / depth_full;
aspect_ratio_corrected = Bscan_width / depth_half;

%% Output Results (converted to micrometers for display)
fprintf('--- OCT System Resolution and Geometry ---\n');
fprintf('           Lateral Resolution : %.2f µm\n', lateral_res * 1e6);
fprintf('             Axial Resolution : %.2f µm\n', axial_res * 1e6);
fprintf('           Lateral Pixel Size : %.2f µm\n', dx * 1e6);
fprintf('  Axial Range w/ Mirror Image : %.2f mm\n', depth_full * 1e3);
fprintf(' Axial Range w/o Mirror Image : %.2f mm\n', depth_half * 1e3);
fprintf(' Aspect Ratio w/ Mirror Image : %d/%d = %.3f\n', ...
        round(Bscan_width * 1e3), round(depth_full * 1e3), aspect_ratio_full);
fprintf('Aspect Ratio w/o Mirror Image : %d/%d = %.3f\n', ...
        round(Bscan_width * 1e3), round(depth_half * 1e3), aspect_ratio_corrected);
% fprintf('Aspect Ratio w Mirror Image  : %.3f\n', aspect_ratio_full);
% fprintf('Aspect Ratio w/ Mirror Image : %.3f\n', aspect_ratio_corrected);

diary off;
