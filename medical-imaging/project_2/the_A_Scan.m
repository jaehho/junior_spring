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

fprintf('\nProcessing BScan_Layers.raw with no deconvolution and no background subtraction...\n');
[Bscan_B_no_deconv_no_bgs, timing_B_no_deconv_no_bgs] = generateBScan(BScan_raw, N_axial, D_BScan, L2K, false, false, false);

fprintf('\nProcessing BScan_Layers.raw with no deconvolution...\n');
[Bscan_B_no_deconv, timing_B_no_deconv] = generateBScan(BScan_raw, N_axial, D_BScan, L2K, true, false, false);

fprintf('\nProcessing MScan1.raw...\n');
[BScan_M1, timing_M1] = generateBScan(MScan1_raw, N_axial, D_MScan, L2K, true, true, false);

fprintf('\nProcessing MScan40.raw...\n');
[BScan_M40, timing_M40] = generateBScan(MScan40_raw, N_axial, D_MScan, L2K, true, true, false);

%% Select Example A-Scans for Display
AScan_B1 = BScan_B(:, D_BScan + 5);
AScan_BMid = BScan_B(:, round((size(BScan_B, 2) + D_BScan) / 2) + 1);
AScan_BMid_no_deconv_no_bgs = Bscan_B_no_deconv_no_bgs(:, round((size(Bscan_B_no_deconv_no_bgs, 2) + D_BScan) / 2) + 1);
AScan_BMid_no_deconv = Bscan_B_no_deconv(:, round((size(Bscan_B_no_deconv, 2) + D_BScan) / 2) + 1);
AScan_M1 = BScan_M1(:, D_MScan + 5);
AScan_M40 = BScan_M40(:, D_MScan + 5);

%% Plot
z = (-N_axial/2:N_axial/2-1);
figure("Name", "A-Scans");
tiledlayout(2, 2);
nexttile;

plot(z, 20*log10(abs(AScan_B1)));
axis tight;
title('BScan Layers - A-Scan 1 [dB]');
xlabel('Depth Index');
ylabel('Magnitude [dB]');

nexttile;
plot(z, 20*log10(abs(AScan_BMid)));
axis tight;
title('BScan Layers - A-Scan Mid-Index [dB]');
xlabel('Depth Index');
ylabel('Magnitude [dB]');

nexttile;
plot(z, 20*log10(abs(AScan_M1)));
axis tight;
title('MScan1 - A-Scan [dB]');
xlabel('Depth Index');
ylabel('Magnitude [dB]');

nexttile;
plot(z, 20*log10(abs(AScan_M40)));
axis tight;
title('MScan40 - A-Scan [dB]');
xlabel('Depth Index');
ylabel('Magnitude [dB]');

exportgraphics(gcf, 'figures/AScans.png', 'Resolution', 300);

figure("Name", "A-Scan Processing Comparison");
plot(z, 20*log10(abs(AScan_BMid)), z, 20*log10(abs(AScan_BMid_no_deconv_no_bgs)), z, 20*log10(abs(AScan_BMid_no_deconv)));
axis tight;
xlabel('Depth Index');
ylabel('Magnitude [dB]');
legend({'Deconv + BG Subtract', 'No Deconv + No BG Subtract', 'No Deconv + BG Subtract'}, 'Fontsize', 6);
legend('boxoff');
exportgraphics(gcf, 'figures/AScan_Processing_Comparison.png', 'Resolution', 300);