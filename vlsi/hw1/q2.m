clc; clear; close all;

syms V_in V_out V_x V_s1 R_1 R_2 R_D1 R_D2 g_m1 g_m2 r_o I_D2 R_1p2 gain_1 gain_2 open_loop_gain

% stage 1
eqn1 = -V_x / R_D1 == V_s1 / (R_1p2);
eqn2 = V_s1 / (R_1p2) == g_m1 * (V_in - V_s1) + (V_x - V_s1) / r_o;
eqn_gain1 = gain_1 == V_x / V_in;

sol_gain_1 = solve([eqn1, eqn2, eqn_gain1], [gain_1, V_x, V_in])

% stage 2
eqn3 = -V_out / R_D2 == V_out / (R_1 + R_2) + I_D2;
eqn4 = I_D2 == g_m2 * V_x + V_out / r_o;
eqn_gain2 = gain_2 == V_out / V_x;

sol_gain_2 = solve([eqn3, eqn4, eqn_gain2], [gain_2, V_out, V_x])

% open loop gain
eqn_open_loop_gain = open_loop_gain == gain_1 * gain_2;

sol_open_loop_gain = solve([eqn1, eqn2, eqn3, eqn4, eqn_gain1, eqn_gain2, eqn_open_loop_gain], [open_loop_gain, gain_1, gain_2, V_out, V_in])

fprintf('Gain 1: \n')
pretty(sol_gain_1.gain_1)
fprintf('Gain 2: \n')
pretty(sol_gain_2.gain_2)
fprintf('Open Loop Gain: \n')
pretty(sol_open_loop_gain.open_loop_gain)
