clc; clear; close all;
fclose(fopen('assets/diary.txt', 'w'));
diary('assets/diary.txt');
diary on;

% Define component values
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

% Load Measured Data (Original and High Voltage)
freq_resp_orig = processGainData('assets/meas_resp.csv', 'assets/freq_resp_original.csv');
freq_resp_high = processGainData('assets/meas_resp_high_voltage.csv', 'assets/freq_resp_high_voltage.csv');

all_freqs = unique([freq_resp_orig.Frequency; freq_resp_high.Frequency]);

% Interpolate all fields (V_out, V_in, dB_Gain) for both datasets
Vout_orig_interp = interp1(freq_resp_orig.Frequency, freq_resp_orig.V_out, all_freqs, 'linear', NaN);
Vin_orig_interp  = interp1(freq_resp_orig.Frequency, freq_resp_orig.V_in,  all_freqs, 'linear', NaN);
Gain_orig_interp = round(interp1(freq_resp_orig.Frequency, freq_resp_orig.dB_Gain, all_freqs, 'linear', NaN), 2);

Vout_high_interp = round(interp1(freq_resp_high.Frequency, freq_resp_high.V_out, all_freqs, 'linear', NaN), 2);
Vin_high_interp  = round(interp1(freq_resp_high.Frequency, freq_resp_high.V_in,  all_freqs, 'linear', NaN), 2);
Gain_high_interp = round(interp1(freq_resp_high.Frequency, freq_resp_high.dB_Gain, all_freqs, 'linear', NaN), 2);

% Create combined table
T_freq_resp = table(all_freqs, ...
    Vin_orig_interp, Vout_orig_interp, Gain_orig_interp, ...
    Vin_high_interp, Vout_high_interp, Gain_high_interp, ...
    'VariableNames', {...
        'Frequency', ...
        'Vin_Original', 'Vout_Original', 'Gain_Original_dB', ...
        'Vin_HighVoltage', 'Vout_HighVoltage', 'Gain_HighVoltage_dB' ...
    });

% Write to CSV
writetable(T_freq_resp, 'assets/freq_resp.csv');

% Load LTspice Data
filename = 'assets/Draft1.txt';
fid = fopen(filename);
data = textscan(fid, '%f ( %fdB , %f )', 'HeaderLines', 1);
fclose(fid);

% Frequency Response Plot
figure;
semilogx(freq_resp_orig.Frequency, freq_resp_orig.dB_Gain, 'b.-', 'LineWidth', 1.5); hold on;
semilogx(freq_resp_high.Frequency, freq_resp_high.dB_Gain, '.-', 'Color', '#77AC30', 'LineWidth', 1.5);
semilogx(data{1}, data{2}, 'r--', 'LineWidth', 1.5);
yline(-3, '--', 'Color', '#EDB120', 'LineWidth', 1.5);

% -3 dB Crossings
idx_meas_orig = find(diff(sign(freq_resp_orig.dB_Gain + 3)));
for i = 1:length(idx_meas_orig)
    f_interp = interp1(freq_resp_orig.dB_Gain(idx_meas_orig(i):idx_meas_orig(i)+1), ...
                       freq_resp_orig.Frequency(idx_meas_orig(i):idx_meas_orig(i)+1), -3);
    xline(f_interp, 'b-.', 'LineWidth', 1.2);
    fprintf('Original Measured -3 dB point #%d: %.2f Hz\n', i, f_interp);
end

idx_meas_high = find(diff(sign(freq_resp_high.dB_Gain + 3)));
for i = 1:length(idx_meas_high)
    f_interp = interp1(freq_resp_high.dB_Gain(idx_meas_high(i):idx_meas_high(i)+1), ...
                       freq_resp_high.Frequency(idx_meas_high(i):idx_meas_high(i)+1), -3);
    xline(f_interp, 'g-.', 'LineWidth', 1.2);
    fprintf('High Voltage Measured -3 dB point #%d: %.2f Hz\n', i, f_interp);
end

idx_sim = find(diff(sign(data{2} + 3)));
for i = 1:length(idx_sim)
    f_interp = interp1(data{2}(idx_sim(i):idx_sim(i)+1), ...
                       data{1}(idx_sim(i):idx_sim(i)+1), -3);
    xline(f_interp, 'r-.', 'LineWidth', 1.2);
    fprintf('Simulated -3 dB point #%d: %.2f Hz\n', i, f_interp);
end

xlabel('Frequency [Hz]');
ylabel('Gain [dB]');
legend('Measured (Original)', 'Measured (High Voltage)', 'LTspice Simulation', '-3 dB Line', 'Location', 'Best');
grid on;
axis tight;
ylim([-50 10]);
exportgraphics(gcf, 'figures/freq_resp.png', 'Resolution', 300);

% Compute Derivatives (dB/decade)
dGain_meas_orig = gradient(freq_resp_orig.dB_Gain) ./ gradient(freq_resp_orig.Frequency);
dB_decade_meas_orig = dGain_meas_orig .* freq_resp_orig.Frequency * log(10);

dGain_meas_high = gradient(freq_resp_high.dB_Gain) ./ gradient(freq_resp_high.Frequency);
dB_decade_meas_high = dGain_meas_high .* freq_resp_high.Frequency * log(10);

dGain_sim = gradient(data{2}) ./ gradient(data{1});
dB_decade_sim = dGain_sim .* data{1} * log(10);

% Plot Derivatives
figure;
semilogx(freq_resp_orig.Frequency, dB_decade_meas_orig, 'b.-', 'LineWidth', 1.5); hold on;
semilogx(freq_resp_high.Frequency, dB_decade_meas_high, '.-', 'Color', '#77AC30', 'LineWidth', 1.5);
semilogx(data{1}, dB_decade_sim, 'r--', 'LineWidth', 1.5);
xlabel('Frequency [Hz]');
ylabel('Derivative [dB/decade]');
legend('Measured (Original)', 'Measured (High Voltage)', 'Simulated', 'Location', 'Best');
grid on;
axis tight;
exportgraphics(gcf, 'figures/derivative.png', 'Resolution', 300);

% Export Derivatives to CSV
commonFreq = freq_resp_orig.Frequency;
simInterp = interp1(data{1}, dB_decade_sim, commonFreq, 'linear', 'extrap');
highInterp = interp1(freq_resp_high.Frequency, dB_decade_meas_high, commonFreq, 'linear', 'extrap');

T = table(commonFreq(:), ...
          round(dB_decade_meas_orig(:),2), ...
          round(highInterp(:),2), ...
          round(simInterp(:),2), ...
    'VariableNames', {'Frequency','Measured_Original','Measured_HighVoltage','Simulated'});

writetable(T, 'assets/derivative.csv');

% Print Maximum Roll-off Rates
[max_deriv_orig, idx_max_orig] = max(dB_decade_meas_orig);
[max_deriv_high, idx_max_high] = max(dB_decade_meas_high);
[max_deriv_sim, idx_max_sim] = max(dB_decade_sim);

fprintf('Max roll-off rate (Measured - Original): %.2f dB/decade at %.2f Hz\n', ...
        max_deriv_orig, freq_resp_orig.Frequency(idx_max_orig));
fprintf('Max roll-off rate (Measured - High Voltage): %.2f dB/decade at %.2f Hz\n', ...
        max_deriv_high, freq_resp_high.Frequency(idx_max_high));
fprintf('Max roll-off rate (Simulated): %.2f dB/decade at %.2f Hz\n', ...
        max_deriv_sim, data{1}(idx_max_sim));

diary off;
