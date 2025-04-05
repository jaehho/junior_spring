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

%% Combined Frequency Response Plot
figure;
semilogx(freq_resp.Frequency, freq_resp.dB_Gain, 'b.-', 'LineWidth', 1.5); hold on;
semilogx(data{1}, data{2}, 'r--', 'LineWidth', 1.5);
yline(-3, '--', 'Color', '#EDB120', 'LineWidth', 1.5);

%% -3 dB Crossing
% Mark the -3 dB crossing for Measured Response
idx_meas = find(diff(sign(freq_resp.dB_Gain + 3)));
for i = 1:length(idx_meas)
    f_interp = interp1(freq_resp.dB_Gain(idx_meas(i):idx_meas(i)+1), ...
                       freq_resp.Frequency(idx_meas(i):idx_meas(i)+1), -3);
    xline(f_interp, 'b-.', 'LineWidth', 1.2);
end
fprintf('Measured -3 dB point #%d: %.2f Hz\n', i, f_interp);

% Mark the -3 dB crossing for Simulated Response
sim_freqs = data{1};
sim_gains = data{2};
idx_sim = find(diff(sign(sim_gains + 3)));
for i = 1:length(idx_sim)
    f_interp = interp1(sim_gains(idx_sim(i):idx_sim(i)+1), ...
                       sim_freqs(idx_sim(i):idx_sim(i)+1), -3);
    xline(f_interp, 'r-.', 'LineWidth', 1.2);
end
fprintf('Simulated -3 dB point #%d: %.2f Hz\n', i, f_interp);

xlabel('Frequency (Hz)');
ylabel('Gain (dB)');
title('Frequency Response Comparison');
legend('Measured Response', 'LTspice Simulation', '-3 dB Line', 'Location', 'Best');
grid on;
axis tight;
ylim([-40 10]);
exportgraphics(gcf, 'figures/freq_resp.png', 'Resolution', 300);

%% Compute Rate of Change (Derivative) in dB per Decade

% For the measured response (dB/Hz)
dGain_meas = gradient(freq_resp.dB_Gain) ./ gradient(freq_resp.Frequency);
% Convert to dB/decade: dGain/d(log10(f)) = dGain/df * f * ln(10)
dB_decade_meas = dGain_meas .* freq_resp.Frequency * log(10);

% For the simulated response (dB/Hz)
dGain_sim = gradient(data{2}) ./ gradient(data{1});
% Convert to dB/decade
dB_decade_sim = dGain_sim .* data{1} * log(10);

% Plot the derivative in dB/decade on a new figure
figure;
semilogx(freq_resp.Frequency, dB_decade_meas, 'b.-', 'LineWidth', 1.5); hold on;
semilogx(data{1}, dB_decade_sim, 'r--', 'LineWidth', 1.5);
xlabel('Frequency [Hz]');
ylabel('Derivative [dB/decade]');
title('Derivative of Frequency Response');
legend('Measured', 'Simulated', 'Location', 'Best');
grid on;
axis tight;
exportgraphics(gcf, 'figures/derivative.png', 'Resolution', 300);

%% Export the Derivative Data (dB/decade) to CSV

commonFreq = freq_resp.Frequency;  % Use measured frequencies only

% Interpolate simulated derivative data to match measured frequencies
measInterp = dB_decade_meas;  % Already matches measured frequencies
simInterp = interp1(data{1}, dB_decade_sim, commonFreq, 'linear', 'extrap');

% Create a table with the frequency and corresponding derivatives in dB/decade
T = table(commonFreq(:), round(dB_decade_meas(:), 2), round(simInterp(:), 2), ...
    'VariableNames', {'Frequency','Measured_dB_per_decade','Simulated_dB_per_decade'});

% Write the table to a CSV file
writetable(T, 'assets/derivative.csv');

% Print maximum roll-off rates
[max_deriv_meas, idx_max_meas] = max(dB_decade_meas);
[max_deriv_sim, idx_max_sim] = max(dB_decade_sim);

fprintf('roll-off rate (Measured): %.2f dB/decade at %.2f Hz\n', ...
        max_deriv_meas, freq_resp.Frequency(idx_max_meas));
fprintf('roll-off rate (Simulated): %.2f dB/decade at %.2f Hz\n', ...
        max_deriv_sim, data{1}(idx_max_sim));

diary off;
