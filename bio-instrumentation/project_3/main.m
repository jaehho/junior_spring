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
semilogx(freq_resp.Frequency, freq_resp.dB_Gain, '.-', 'Color', 'b', 'LineWidth', 1.5); hold on; % blue-ish
semilogx(data{1}, data{2}, '--', 'Color', 'r', 'LineWidth', 1.5); % orange

% Horizontal line at -3 dB (Orange Dashed)
yline(-3, '--', 'Color', '#EDB120', 'LineWidth', 1.5);

% Find intersection for Measured Response (Magenta vertical dashed lines)
meas_freqs = freq_resp.Frequency;
meas_gains = freq_resp.dB_Gain;
idx_meas = find(diff(sign(meas_gains + 3))); % -3 dB crossing
for i = 1:length(idx_meas)
    f_interp = interp1(meas_gains(idx_meas(i):idx_meas(i)+1), ...
                       meas_freqs(idx_meas(i):idx_meas(i)+1), -3);
    xline(f_interp, '-.', 'Color', 'b', 'LineWidth', 1.2); % Magenta
end

% Find intersection for Simulated Response (Cyan vertical dashed lines)
sim_freqs = data{1};
sim_gains = data{2};
idx_sim = find(diff(sign(sim_gains + 3))); % -3 dB crossing
for i = 1:length(idx_sim)
    f_interp = interp1(sim_gains(idx_sim(i):idx_sim(i)+1), ...
                       sim_freqs(idx_sim(i):idx_sim(i)+1), -3);
    xline(f_interp, '-.', 'Color', 'r', 'LineWidth', 1.2); % Cyan
end

xlabel('Frequency (Hz)');
ylabel('Gain (dB)');
title('Frequency Response Comparison');
legend('Measured Response', 'LTspice Simulation', '-3 dB Line', ...
       'Location', 'Best');
grid on;
axis tight;
ylim([-40 10]);

exportgraphics(gcf, 'figures/freq_resp.png', 'Resolution', 300);

diary off;
