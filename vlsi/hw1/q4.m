clc; clear; close all;

syms A_i i_out i_in V_1 V_S4 V_D4 g_m1 g_m4 invgm1_p_ro1_p_ro2 r_o3 r_o4 R_D

eqn1 = V_1 / i_in == invgm1_p_ro1_p_ro2;
eqn2 = i_out == -V_D4 / R_D;
eqn3 = i_out == g_m4 * (V_1 - V_S4) + (V_D4 - V_S4) / (r_o4);
eqn4 = i_out == V_S4 / r_o3;
eqn_A_i = A_i == i_out / i_in;

sol_A_i = solve([eqn1, eqn2, eqn3, eqn4, eqn_A_i], [A_i, i_out, i_in, V_1, V_S4, V_D4], "ReturnConditions", true);

syms I_x V_x r_out V_S4 r_o3 r_o4 R_D

% eqn5 = I_x == (V_x - V_D4) / R_D;
% eqn6 = I_x == -g_m4 * V_S4 + (V_D4 - V_S4) / (r_o4);
% eqn7 = I_x == V_S4 / r_o3;
eqn_r_out = r_out == V_x / I_x;

eqn5 = I_x == -g_m4 * V_S4 + (V_x - V_S4) / (r_o4);
eqn6 = I_x == V_S4 / r_o3;

sol_r_out = solve([eqn5, eqn6, eqn_r_out], [r_out, I_x, V_x, V_S4, V_D4], "ReturnConditions", true);

fprintf('open loop gain: \n')
pretty(sol_A_i.A_i(end))
fprintf('r_out: \n')
pretty(sol_r_out.r_out(end))