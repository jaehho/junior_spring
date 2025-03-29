% clc; clear; close all;

syms A I_x V_x V_D4 g_m7 g_m8 V_GS8 V_S8 V_z V_y r_o7 r_o8 r_out

eqn1 = I_x == g_m8 * V_GS8 + (V_x - V_S8) / r_o8;
eqn2 = I_x == -g_m7 * V_z + V_S8 / r_o7;
eqn3 = V_GS8 == - A * V_y - V_S8;
eqn4 = V_y == V_S8 - V_z;
eqn5 = V_z == 0;
eqn_r_out = r_out == V_x / I_x;

sol_r_out = solve([eqn1, eqn2, eqn3, eqn4, eqn5, eqn_r_out], [r_out, I_x, V_x, V_D4, V_GS8, V_S8, V_z, V_y], "ReturnConditions", true);
pretty(sol_r_out.r_out(end))

% display conditions
fprintf('Conditions: \n')
for i = 1:length(sol_r_out.r_out)
    fprintf('Condition %d: \n', i)
    pretty(sol_r_out.conditions(i))
end
