clc; clear; close all;
fclose(fopen('figures/the_Ascan.txt', 'w'));
diary('figures/the_Ascan.txt'); % Start logging to a file
diary on;

%% Load RAW Files
Bscan_raw   = loadRawFile('project-files/Bscan_Layers.raw');
Mscan1_raw  = loadRawFile('project-files/Mscan1.raw');
Mscan40_raw = loadRawFile('project-files/Mscan40.raw');
load('project-files/L2K.mat', 'L2K');
run('dataParams.m');

%% Process the Data Entirely in the k Domain Using generateAscan_k
fprintf('\nProcessing Bscan_Layers.raw...\n');
[Bscan_B, timing_B] = generate_Bscan(Bscan_raw, N_axial, D_Bscan, L2K, true, true, true);

fprintf('\nProcessing Bscan_Layers.raw with no deconvolution and no background subtraction...\n');
[Bscan_B_no_deconv_no_bgs, timing_B_no_deconv_no_bgs] = generate_Bscan(Bscan_raw, N_axial, D_Bscan, L2K, false, false, false);

fprintf('\nProcessing Bscan_Layers.raw with no deconvolution...\n');
[Bscan_B_no_deconv, timing_B_no_deconv] = generate_Bscan(Bscan_raw, N_axial, D_Bscan, L2K, true, false, false);

fprintf('\nProcessing Mscan1.raw...\n');
[Bscan_M1, timing_M1] = generate_Bscan(Mscan1_raw, N_axial, D_Mscan, L2K, true, true, false);

fprintf('\nProcessing Mscan40.raw...\n');
[Bscan_M40, timing_M40] = generate_Bscan(Mscan40_raw, N_axial, D_Mscan, L2K, true, true, false);

%% Select Example Ascans for Display
Ascan_B1 = Bscan_B(:, D_Bscan + 1);
Ascan_BMid = Bscan_B(:, round((size(Bscan_B, 2) + D_Bscan) / 2) + 1);
Ascan_BMid_no_deconv_no_bgs = Bscan_B_no_deconv_no_bgs(:, round((size(Bscan_B_no_deconv_no_bgs, 2) + D_Bscan) / 2) + 1);
Ascan_BMid_no_deconv = Bscan_B_no_deconv(:, round((size(Bscan_B_no_deconv, 2) + D_Bscan) / 2) + 1);
Ascan_M1 = Bscan_M1(:, round((size(Bscan_M1, 2) + D_Mscan) / 2) + 1);
Ascan_M40 = Bscan_M40(:, round((size(Bscan_M40, 2) + D_Mscan) / 2) + 1);

%% Plot
z = (-N_axial/2:N_axial/2-1);
figure("Name", "Ascans");
tlo = tiledlayout(2,2, 'TileSpacing', "none", 'Padding','tight');

ax1 = nexttile;
plot(z, 20*log10(abs(fftshift(Ascan_B1))));
axis tight;
text(0.05, 0.95, 'A', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

ax2 = nexttile;
plot(z, 20*log10(abs(fftshift(Ascan_M1))));
axis tight;
text(0.05, 0.95, 'C', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

ax3 = nexttile;
plot(z, 20*log10(abs(fftshift(Ascan_BMid))));
axis tight;
xticks([-500 0 500]);
text(0.05, 0.95, 'B', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

ax4 = nexttile;
plot(z, 20*log10(abs(fftshift(Ascan_M40))));
axis tight;
xticks([-500 0 500]);
text(0.05, 0.95, 'D', 'Units', 'normalized', ...
    'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');

% Link the axes so they share the same limits and tick locations:
linkaxes([ax1, ax2, ax3, ax4],'xy');

% Remove tick labels from interior axes to create a shared tick effect:
ax1.XTickLabel = [];
ax2.XTickLabel = [];
ax2.YTickLabel = [];
ax4.YTickLabel = [];

% Add common x and y labels for the entire tiled layout:
xlabel(tlo, 'Pixel Depth');
ylabel(tlo, 'Magnitude [dB]');

exportgraphics(gcf, 'figures/Ascans.png', 'Resolution', 300);

figure("Name", "Ascan Processing Comparison");
plot(z, 20*log10(abs(fftshift(Ascan_BMid_no_deconv_no_bgs))), z, 20*log10(abs(fftshift(Ascan_BMid_no_deconv))), z, 20*log10(abs(fftshift(Ascan_BMid))));
axis tight;
xlabel('Pixel Depth');
ylabel('Magnitude [dB]');
legend({'No Deconv + No BG Subtract', 'No Deconv + BG Subtract', 'Deconv + BG Subtract'}, 'Fontsize', 6);
legend('boxoff');
exportgraphics(gcf, 'figures/Ascan_Processing_Comparison.png', 'Resolution', 300);

diary off;
