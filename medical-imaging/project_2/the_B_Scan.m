clc; clear; close all;

%% Load RAW Files
BScan_raw = loadRawFile('project-files/BScan_Layers.raw');
load('project-files/L2K.mat', 'L2K');
run('dataParams.m');

%% Process the B-Scan
[BScan, timing] = generateBScan(BScan_raw, N_axial, D_BScan, L2K, true, true, false);

[Bscan_B_no_deconv, timing_B_no_deconv] = generateBScan(BScan_raw, N_axial, D_BScan, L2K, true, false, false);

BScan_dB = 20 * log10(abs(BScan));
BScan_no_deconv_dB = 20 * log10(abs(Bscan_B_no_deconv));

%% Depth Axis
N_half = round(N_axial / 2);
z = (1:N_half) * dz;

AScan_BMid = BScan_dB(1:N_half, round((size(BScan_dB, 2) + D_BScan) / 2) + 1);

BScan_cropped = BScan_dB(1:N_half, :);
BScan_no_deconv_cropped = BScan_no_deconv_dB(1:N_half, :);

%% A-Scan Analysis
depth_lower = 0.45;
depth_upper = 1.35;
depth_range_idx = round(depth_lower / 1e3 / dz):round(depth_upper / 1e3 / dz);
mag_upper = 10;
mag_lower = -20;
[pks, locs] = findpeaks(AScan_BMid(depth_range_idx), z(depth_range_idx), 'MinPeakHeight', 0);

%% Distances between peaks
peak_distances = diff(locs) * 1e3;
fprintf('Distances between peaks (mm):\n');
for i = 1:length(peak_distances)
    fprintf('Peak %.2f to Peak %.2f: %.2f mm\n', locs(i) * 1e3, locs(i+1) * 1e3, peak_distances(i));
end

figure("Name", "A-Scan Analysis for B-Scan");
plot(z * 1e3, AScan_BMid); hold on;
plot(locs * 1e3, pks, 'bv', 'MarkerFaceColor', 'b');
xline(depth_lower, 'r--');
xline(depth_upper, 'r--');
yline(mag_upper, 'r--');
yline(mag_lower, 'r--');
axis tight;
xlabel('Depth [mm]');
ylabel('Magnitude [dB]');
exportgraphics(gcf, 'figures/A_Scan_Analysis_BScan.png', 'Resolution', 300);

%% Display B-Scans
x = linspace(0, BScan_width, size(BScan, 2)); % Lateral axis

figure("Name", "B-Scans");
tiledlayout('horizontal');

% Unprocessed B-Scan
nexttile;
imagesc(x * 1e3, z * 1e3, BScan_cropped);
title('A')
colormap(gray);
xlabel('Lateral Position [mm]');
ylabel('Depth [mm]');
axis image;

% Unprocessed B-Scan (no deconvolution)
nexttile;
imagesc(x * 1e3, z * 1e3, BScan_no_deconv_cropped);
title('B')
colormap(gray);
xlabel('Lateral Position [mm]');
axis image;

% Processed B-Scan
nexttile;
imagesc(x * 1e3, z * 1e3, BScan_cropped);
title('C');
colormap(gray);
clim([mag_lower mag_upper]);
xlabel('Lateral Position [mm]');
axis image;

exportgraphics(gcf, 'figures/BScans.png', 'Resolution', 300);

BScan_focused = BScan_cropped(depth_range_idx, :);
z_focused = z(depth_range_idx);
figure("Name", "B-Scan Focused");
imagesc((x * 1e3), z_focused * 1e3, BScan_focused);
colormap(gray);
clim([mag_lower mag_upper]);
xlabel('Lateral Position [mm]');
ylabel('Depth [mm]');
axis image;
exportgraphics(gcf, 'figures/BScan_Focused.png', 'Resolution', 300);

% BScan_focused_edges = edge(BScan_focused, 'Canny', [], 'vertical');
% figure("Name", "B-Scan Focused Edges");
% imagesc((x * 1e3), z_focused * 1e3, BScan_focused_edges);
% colormap(gray);
% clim([0 1]);
% xlabel('Lateral Position [mm]');
% ylabel('Depth [mm]');
% axis image;
% exportgraphics(gcf, 'figures/BScan_Focused_Edges.png', 'Resolution', 300);

