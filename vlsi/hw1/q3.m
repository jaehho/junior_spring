clc; clear; close all;

syms G_m I_out V_in g_m1 V_G1 V_S1 V_D1 r_o R_f A 

% eqn1 = I_out == g_m1 * (V_G1 - V_S1) - V_S1 / r_o;
eqn1 = I_out == g_m1 * (V_G1 - I_out * R_f) - (I_out * R_f) / r_o;
eqn2 = V_G1 == A * V_in;
eqn_A_0 = G_m == I_out / V_in;

sol_A_0 = solve([eqn1, eqn2, eqn_A_0], [G_m, I_out, V_in]);

% eqn3 = g_m1 * ( -V_S1) + (1 - V_S1) / R_f == V_S1 / r_o;
% % eqn3 = g_m1 * ( -(1 - R_f * I_out)) + (1 - (1 - R_f * I_out)) / R_f == (1 - R_f * I_out) / r_o;
% eqn4 = V_S1 == 1 - R_f * I_out;
% eqn_r_out = r_out == 1 / I_out;

syms I_x V_x r_out

eqn3 = V_S1 / R_f == (V_x - V_S1) / r_o - g_m1 * V_S1;
eqn4 = I_x == V_S1 / R_f;
eqn_r_out = r_out == V_x / I_out;

sol_r_out = solve([eqn3, eqn4, eqn_r_out], [r_out, I_out, V_x, V_S1]);

fprintf('open loop gain: \n')
pretty(sol_A_0.G_m)
fprintf('r_out: \n')
pretty(sol_r_out.r_out)