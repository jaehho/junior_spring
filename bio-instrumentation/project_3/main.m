clc; clear; close all;
fclose(fopen('assets/diary.txt', 'w'));
diary('assets/diary.txt');
diary on;

L_1 = 3/2;
C_2 = 4/3;
L_3 = 1/2;

Cp_1 = 1/L_1;
Lp_2 = 1/C_2;
Cp_3 = 1/L_3;

fprintf('Cp_1 = %.4f\n', Cp_1);
fprintf('Lp_2 = %.4f\n', Lp_2);
fprintf('Cp_3 = %.4f\n', Cp_3);

R = 1e3;
f_c = 1e3;
w_c = 2 * pi * f_c;

Cpp_1 = (Cp_1) / (R * w_c);
Lpp_2 = (R * Lp_2) / (w_c);
Cpp_3 = (Cp_3) / (R * w_c);

fprintf('Cpp_1 = %.4f nF\n', Cpp_1 * 1e9);
fprintf('Lpp_2 = %.4f mH\n', Lpp_2 * 1e3);
fprintf('Cpp_3 = %.4f nF\n', Cpp_3 * 1e9);

% Load Measured Data
freq_resp = processGainData('assets/meas_resp.csv', 'assets/freq_resp.csv');

% Load LTspice Data
filename = 'assets/Draft1.txt';
fid = fopen(filename);
data = textscan(fid, '%f ( %fdB , %f )', 'HeaderLines', 1); % Skip header
fclose(fid);

% Combined Plot
figure;
semilogx(freq_resp.Frequency, freq_resp.dB_Gain, '.-', 'LineWidth', 1.5); hold on;
semilogx(data{1}, data{2}, '--', 'LineWidth', 1.5);
xlabel('Frequency (Hz)');
ylabel('Gain (dB)');
title('Frequency Response Comparison');
legend('Measured Response', 'LTspice Simulation', 'Location', 'Best');
grid on;
axis tight;
ylim([-40 10]);
exportgraphics(gcf, 'figures/freq_resp.png', 'Resolution', 300);

diary off;
