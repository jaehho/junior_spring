clc; clear; close all;

%% Load RAW Files
Bscan_raw = loadRawFile('project-files/Bscan_Layers.raw');
load('project-files/L2K.mat', 'L2K');
run('dataParams.m');

%% Process the Bscan
[Bscan, timing] = generate_Bscan(Bscan_raw, N_axial, D_Bscan, L2K, true, true, false);

[Bscan_B_no_deconv, timing_B_no_deconv] = generate_Bscan(Bscan_raw, N_axial, D_Bscan, L2K, true, false, false);

Bscan_dB = 20 * log10(abs(Bscan));
Bscan_no_deconv_dB = 20 * log10(abs(Bscan_B_no_deconv));

%% Depth Axis
N_half = round(N_axial / 2);
z = (1:N_half) * dz;

Ascan_BMid = Bscan_dB(1:N_half, round((size(Bscan_dB, 2) + D_Bscan) / 2) + 1);

Bscan_cropped = Bscan_dB(1:N_half, :);
Bscan_no_deconv_cropped = Bscan_no_deconv_dB(1:N_half, :);

%% Ascan Analysis
depth_lower = 0.45;
depth_upper = 1.35;
depth_range_idx = round(depth_lower / 1e3 / dz):round(depth_upper / 1e3 / dz);
mag_upper = 10;
mag_lower = -20;
[pks, locs] = findpeaks(Ascan_BMid(depth_range_idx), z(depth_range_idx), 'MinPeakHeight', 0);

%% Distances between peaks
peak_distances = diff(locs) * 1e3;
fprintf('Distances between peaks (mm):\n');
for i = 1:length(peak_distances)
    fprintf('Peak %.2f to Peak %.2f: %.2f mm\n', locs(i) * 1e3, locs(i+1) * 1e3, peak_distances(i));
end

figure("Name", "Ascan Analysis for Bscan");
plot(z * 1e3, Ascan_BMid); hold on;
plot(locs * 1e3, pks, 'bv', 'MarkerFaceColor', 'b');
xline(depth_lower, 'r--');
xline(depth_upper, 'r--');
yline(mag_upper, 'r--');
yline(mag_lower, 'r--');
axis tight;
xlabel('Depth [mm]');
ylabel('Magnitude [dB]');
exportgraphics(gcf, 'figures/Ascan_Analysis_Bscan.png', 'Resolution', 300);

%% Display Bscans
x = linspace(0, Bscan_width, size(Bscan, 2)); % Lateral axis

figure("Name", "Bscans");
t = tiledlayout(1,3,'TileSpacing','none','Padding','Compact');

% Unprocessed Bscan
ax1 = nexttile;
imagesc(x * 1e3, z * 1e3, Bscan_cropped);
colormap(gray);
axis image;
text(0.1, 1, 'A', 'Units', 'normalized', 'Color', 'w', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% Unprocessed Bscan (no deconvolution)
ax2 = nexttile;
imagesc(x * 1e3, z * 1e3, Bscan_no_deconv_cropped);
colormap(gray);
axis image;
text(0.1, 1, 'B', 'Units', 'normalized', 'Color', 'w', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% Processed Bscan
ax3 = nexttile;
imagesc(x * 1e3, z * 1e3, Bscan_cropped);
colormap(gray);
clim([mag_lower mag_upper]);
axis image;
text(0.1, 1, 'C', 'Units', 'normalized', 'Color', 'w', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% Link the axes so they share the same limits and tick locations:
linkaxes([ax1, ax2, ax3],'y');
ax2.YTickLabel = [];
ax3.YTickLabel = [];

% Add common x and y labels for the entire tiled layout:
xlabel(t, 'Lateral Position [mm]');
ylabel(t, 'Depth [mm]');

exportgraphics(gcf, 'figures/Bscans.png', 'Resolution', 300);

Bscan_focused = Bscan_cropped(depth_range_idx, :);
z_focused = z(depth_range_idx);
figure("Name", "Bscan Focused");
imagesc((x * 1e3), z_focused * 1e3, Bscan_focused);
colormap(gray);
clim([mag_lower mag_upper]);
xlabel('Lateral Position [mm]');
ylabel('Depth [mm]');
axis image;
exportgraphics(gcf, 'figures/Bscan_Focused.png', 'Resolution', 300);
