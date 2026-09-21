#import "conf.typ": ieee

#show: ieee.with(
  title: [Model Neurons],
  abstract: [
    This report presents computational models of neuronal dynamics, progressing from simple integrate-and-fire neurons to detailed multi-compartment Hodgkin-Huxley simulations. Synaptic conductance mechanisms and spike-triggered dynamics are incorporated to capture interactions between neurons. The models are used to simulate isolated neurons and two-neuron networks, revealing the effects of excitatory and inhibitory synapses on membrane potentials and spike timing. Finally, a multi-compartment model numerically solves the cable equation and demonstrates signal propagation down a neuron.
  ],
  index-terms: ("Theoretical Neuroscience", "Cable Equation", "Hodgkin-Huxley", "Integrate-and-Fire", "Multi-Compartment Model"),
  authors: (
    (
      name: "Jaeho Cho",
      department: [MA391 - Theoretical Neuroscience],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "jaeho.cho@cooper.edu",
    ),
  ),
  bibliography: bibliography("refs.bib"),
)

= Introduction

Understanding how neurons generate and propagate electrical signals is a foundational goal in theoretical neuroscience. Different models of neurons allow for an understanding of how a neuron responds to inputs, how it communicates with other neurons, and how networks of neurons process information. Models range in levels of abstraction and assumptions, some capturing only the basic idea of a neuron firing a spike. Others much more detailed, modeling intricate biological processes inside the neuron, like the movement of ions and the channels of the cell.

= Methodology

== Integrate-and-Fire

The project initially implements a simple single-compartment integrate-and-fire neuron model, which can be described by the following equation:

$
  c_m (d V) / (d t) = - i_m + I_e / A
$

Which can be rewritten by multiplying the equation by the specific membrane resistance $r_m$, which is given by $r_m = 1 / (macron(g)_L)$, this gives the basic equation for the integrate-and-fire model:

$
  tau_m (d V) / (d t) = E_L - V + R_m I_e
$<eq:integrate-and-fire>

To generate action potentials in the model, equation @eq:integrate-and-fire is augmented by the rule that whenever V reaches the threshold value $V_"th"$, an action potential is fired and the potential is reset to $V_"reset"$

== Synaptic Conductances

Synaptic inputs are incorporated into the integrate-and-fire model by adding a synaptic conductance term to the membrane potential equation, extending equation @eq:integrate-and-fire to include the synaptic conductance term:

$
  tau_m (d V) / (d t) = E_L - V - r_m macron(g)_s P_s (V - E_s) + R_m I_e
$

Where $P_"s"$ is the synaptic probability, which can be approximated as an exponential decay function:

$
  tau_s (d P_"s") / (d t) = - P_"s"
$

making the replacement $P_"s" arrow P_"s" + P_"max"(1 − P_"s")$ immediately after each presynaptic action potential.

== Hodgkin-Huxley Model

The membrane current of the Hodgkin-Huxley model is described by the following equation:
$
  i_m = macron(g)_L (V - E_L)\ + macron(g)_"K" n^4 (V - E_"K")\ + macron(g)_("Na") m^3 h (V - E_("Na"))
$<eq:HH_current>

Where the maximal conductances and reversal potentials are taken from the textbook as
$g^(‾)_L = 0.003$ mS/mm²,
$g^(‾)_"K" = 0.36$ mS/mm²,
$g^(‾)_("Na") = 1.2$ mS/mm²,
$E_L = - 54.387$ mV,
$E_"K" = - 77$ mV and
$E_("Na") = 50$ mV.
And the gating variables are described by the following equations, fitted by Hodgkin and Huxley:

$
  alpha_n = (0.01 (V + 55)) / (1 - exp (- 0.1 (V + 55)))\
  beta_n = 0.125 exp (- 0.0125 (V + 65))
$

$
  alpha_m = (0.1 (V + 40)) / (1 - exp (- 0.1 (V + 40)))\
  beta_m = 4 exp (- 0.0556 (V + 65))
$

$
  alpha_h = 0.07 exp (- 0.05 (V + 65))\
  beta_h = 1 / (1 + exp (- 0.1 (V + 35)))
$

== Multi-Compartment Neuron Model

Each compartment of the multi-compartment neuron model is described by the following equation:

$
  c_m (d V_mu) / (d t) = - i_m^mu + I_e^mu / A_mu\
  + g_(mu, mu + 1) lr((V_(mu + 1) - V_mu)) + g_(mu, mu - 1) lr((V_(mu - 1) - V_mu))
$

The multi-compartment neuron model was implemented following Appendix B of Chapter 6 in the textbook, which utilizes the Tridiagonal matrix algorithm
to integrate the cable equation written in the following form:

$
  (d V_mu) / (d t) = A_mu V_(mu - 1) + B_mu V_mu + C_mu V_(mu + 1) + D_mu
$

where

$
  A_mu = c_m^(- 1) g_(mu, mu - 1)\
  B_mu = - c_m^(- 1) lr((sum_i g^(‾)_i^mu + g_(mu, mu + 1) + g_(mu, mu - 1)))\
  C_mu = c_m^(- 1) g_(mu, mu + 1)\
  D_mu = c_m^(- 1) lr((sum_i g^(‾)_i^mu E_i + I_e^mu / A_mu))
$

= Results & Discussion

== Single-Compartment Integrate-and-Fire

The membrane potentials and post-synaptic probabilities of two single-compartment integrate-and-fire neurons with a randomly generated injection current were simulated and are presented in @fig:Excitatory_A_to_B_only, @fig:Excitatory_both, @fig:Inhibitory_A_to_B_only, @fig:Inhibitory_both, and @fig:Exc_A_to_B_Inh_B_to_A. These figures present all the combinations of excitatory and inhibitory synapses, revealing the expected effects of synaptic connections on the membrane potential.

#{
  set image(width: 78%)
  [
    #figure(
      placement: none,
      caption: "Two single-compartment integrate-and-fire neurons with random current injection, with an excitatory synapse from neuron A to neuron B",
      image("figures/synapse_Excitatory_A_to_B_only.svg"),
    )<fig:Excitatory_A_to_B_only>

    #figure(
      placement: none,
      caption: "Two single-compartment integrate-and-fire neurons with random current injection, with an excitatory synapse from both neuron A to neuron B and neuron B to neuron A",
      image("figures/synapse_Excitatory_both.svg"),
    )<fig:Excitatory_both>

    #figure(
      placement: none,
      caption: "Two single-compartment integrate-and-fire neurons with random current injection, with an inhibitory synapse from neuron A to neuron B",
      image("figures/synapse_Inhibitory_A_to_B_only.svg"),
    )<fig:Inhibitory_A_to_B_only>

    #figure(
      placement: none,
      caption: "Two single-compartment integrate-and-fire neurons with random current injection, with an inhibitory synapse from both neuron A to neuron B and neuron B to neuron A",
      image("figures/synapse_Inhibitory_both.svg"),
    )<fig:Inhibitory_both>

    #figure(
      placement: none,
      caption: "Two single-compartment integrate-and-fire neurons with random current injection, with an excitatory synapse from neuron A to neuron B and an inhibitory synapse from neuron B to neuron A",
      image("figures/synapse_Exc_A_to_B_Inh_B_to_A.svg"),
    )<fig:Exc_A_to_B_Inh_B_to_A>
  ]
}

Taking inspiration from figure 5.20 in the textbook @dayanTheoreticalNeuroscienceComputational2001, two synaptically coupled integrate-and-fire neurons were simulated. The synaptic connections were modeled as either both excitatory or both inhibitory, and the resulting membrane potentials were plotted in @fig:constant_current. The textbook's model indicates that having both excitatory synapses produce an alternating, out-of-phase pattern of activity, while having both inhibitory synapses produce synchronous firing. This behavior is not replicated in the simulation of this project, where the intuitively expected behavior is observed. The textbook addresses the non-intuitive behavior of their model, but explain that with a sufficiently long synaptic time constant, the model produces the unexpected behavior.

#figure(
  placement: auto,
  caption: "Two single-compartment integrate-and-fire neurons with constant current injection, with either both excitatory or both inhibitory synapses. Inspired to replicate figure 5.20 in the textbook.",
  grid(
    image("figures/constant_current_Excitatory_both.svg"),
    image("figures/constant_current_Inhibitory_both.svg"),
  ),
)<fig:constant_current>

== Multi-compartment

The multi-compartment neuron model is presented in @fig:multicompartment, where the propagation of the membrane potential can be seen through the change in voltage over time at select compartments or the change in voltage at different compartments (distances) at select times. The figure also shows the gating variables of the first compartment are also presented and match the behavior illustrated in figure 5.11 in the textbook. An alternative visualization of the multi-compartment model is presented in @fig:multicompartment_heatmap, where the membrane potential is visualized as a heatmap where the x-axis represents times, and the y-axis represents the distance from the soma.

#figure(
  image("figures/multicompartment.svg"),
  caption: "Multi-compartment neuron model",
  placement: top,
)<fig:multicompartment>

#figure(
  image("figures/multicompartment_heatmap.svg"),
  caption: "Multi-compartment neuron model visualized with heatmap",
  placement: top,
)<fig:multicompartment_heatmap>

@fig:multicompartment_network shows the membrane potential of two neurons connected by an excitatory synapse. Once the action potential reaches the end of the first neuron, it triggers the synaptic conductance of the second neuron, which then propagates the action potential down the second neuron.

#figure(
  image("figures/multicompartment_network.svg"),
  caption: "Propagation of an action potential through multi-compartment models and across a synapse",
  placement: auto,
)<fig:multicompartment_network>
