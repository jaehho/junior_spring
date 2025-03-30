clc; clear; close all;

% Load raw files
BScan_raw = loadRawFile('project-files/BScan_Layers.raw');
MScan1_raw = loadRawFile('project-files/MScan1.raw');
MScan40_raw = loadRawFile('project-files/MScan40.raw');
run('dataParams.m');

% Reshape
BScan = reshape(BScan_raw, N_axial, []);
MScan1 = reshape(MScan1_raw, N_axial, []);
MScan40 = reshape(MScan40_raw, N_axial, []);

% Get sizes
[nPixels_B, nScans_B] = size(BScan);    
[nPixels_M1, nScans_M1] = size(MScan1);
[nPixels_M40, nScans_M40] = size(MScan40);

% Describe structure
fprintf('BScan_Layers.raw: %d total columns, %d background, %d A-scans\n', ...
        nScans_B, D_BScan, nScans_B - D_BScan);

fprintf('MScan1.raw: %d total columns, %d background, %d A-scans\n', ...
        nScans_M1, D_MScan, nScans_M1 - D_MScan);

fprintf('MScan40.raw: %d total columns, %d background, %d A-scans\n', ...
        nScans_M40, D_MScan, nScans_M40 - D_MScan);

%% Resolutions

% Lateral Resolution 
lateral_res = 0.37 * lambda_0 / NA; 

% Axial Resolution
axial_res = (2 * log(2)) / (n_air * pi) * (lambda_0^2 / delta_lambda);

%% 3. B-Scan Aspect Ratios
dx = BScan_width / (nScans_B - D_BScan); % Lateral sampling step [m]
depth_full = N_axial * dz; % Full depth span [m]
depth_half = depth_full / 2; % Half depth span [m]

aspect_ratio_full = BScan_width / depth_full;
aspect_ratio_corrected = BScan_width / depth_half;

%% Output Results (converted to micrometers for display)
fprintf('--- OCT System Resolution and Geometry ---\n');
fprintf('           Lateral Resolution : %.2f µm\n', lateral_res * 1e6);
fprintf('             Axial Resolution : %.2f µm\n', axial_res * 1e6);
fprintf('           Lateral Pixel Size : %.2f µm\n', dx * 1e6);
fprintf('  Axial Range w/ Mirror Image : %.2f mm\n', depth_full * 1e3);
fprintf(' Axial Range w/o Mirror Image : %.2f mm\n', depth_half * 1e3);
fprintf(' Aspect Ratio w/ Mirror Image : %d/%d = %.3f\n', ...
        round(BScan_width * 1e6), round(depth_full * 1e6), aspect_ratio_full);
fprintf('Aspect Ratio w/o Mirror Image : %d/%d = %.3f\n', ...
        round(BScan_width * 1e6), round(depth_half * 1e6), aspect_ratio_corrected);
% fprintf('Aspect Ratio w Mirror Image  : %.3f\n', aspect_ratio_full);
% fprintf('Aspect Ratio w/ Mirror Image : %.3f\n', aspect_ratio_corrected);
