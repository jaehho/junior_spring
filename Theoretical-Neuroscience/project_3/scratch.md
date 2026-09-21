The basic equation of the passive integrate-and-fire modelsa is

$$
\tau_m \frac{dV}{dt} = E_L - V + R_m I_e. \tag{5.8}
$$

To generate action potentials in the model, equation 5.8 is augmented by the rule that whenever $V$ reaches the threshold value $V_{th}$, an action potential is fired and the potential is reset to $V_{reset}$. Equation 5.8 indicates that when $I_e = 0$, the membrane potential relaxes exponentially with time constant $\tau_m$ to $V = E_L$. Thus, $E_L$ is the resting potential of the model cell.
