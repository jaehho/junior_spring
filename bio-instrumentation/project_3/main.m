clc; clear; close all;

L_1 = 3/2;
C_2 = 4/3;
L_3 = 1/2;

Cp_1 = 1/L_1;
Lp_2 = 1/C_2;
Cp_3 = 1/L_3;

R = 1e3;
f_c = 1e3;
w_c = 2 * pi * f_c;

Cpp_1 = (Cp_1) / (R * w_c);
Lpp_2 = (R * Lp_2) / (w_c);
Cpp_3 = (Cp_3) / (R * w_c);

fprintf('Cpp_1 = %.4f nF\n', Cpp_1 * 1e9);
fprintf('Lpp_2 = %.4f mH\n', Lpp_2 * 1e3);
fprintf('Cpp_3 = %.4f nF\n', Cpp_3 * 1e9);