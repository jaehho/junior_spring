clc; clear; close all;

unCox = 500e-6;
lambda = 0.1;
I_D = 1e-3;

r_o = 1 / (lambda * I_D);
C_1 = 1e-12;
C_2 = 2 * C_1;
w = 1 / (sqrt(3) * r_o * C_1);

g_m = (((1+(w * r_o * C_1)^2) * (1 + (w * r_o * (C_1 + C_2))^2)^(1/2))/(r_o^3))^(1/3)
V_DS = I_D * r_o;

syms W_L

eqn1 = g_m == sqrt((2 * unCox * (W_L) * I_D)/(1 + (lambda * V_DS)));

W_L = double(solve(eqn1, W_L))