#import "conf.typ": ieee

#show: ieee.with(
  title: [Active Low-Pass Filter],
  abstract: [
    This project explores the design and implementation of a second-order active low-pass filter using the Sallen-Key topology. The filter is designed to have a Butterworth response, which provides a maximally flat frequency response in the passband. The results are compared with theoretical predictions, and the implications of component tolerances and op-amp characteristics on the filter's performance are discussed.
  ],
  index-terms: ("Sallen-Key", "Butterworth"),
  authors: (
    (
      name: "Jaeho Cho",
      department: [ECE444 - Bioinstrumentation and Sensing],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "jaeho.cho@cooper.edu"
    ),
  ),
  bibliography: bibliography("refs.bib")
)

= Introduction <introduction>

The Sallen-Key topology is a popular active low-pass filter design that utilizes operational amplifiers (op-amps) to achieve a desired frequency response. The design explored in this project is a second-order low-pass filter with a Butterworth response, which provides a maximally flat frequency response in the passband.

== Circuit Analysis
<circuit-analysis>

=== Nodal Analysis
<nodal-analysis>
Examining the circuit illustrated in @circuit-diagram, KCL can be applied at node A to get

$
frac(V_"in" - V_A, R_1) = frac(V_A - V_B, R_2) + s C_1 lr((V_A - V_"out"))
$ <node-A>

#figure(
  placement: bottom,
  caption: "Sallen-Key topology for the active low-pass filter.",
  image(
    "assets/sallen-key circuit.drawio.png",
  )
)<circuit-diagram>

and at node B

$
frac(V_A - V_B, R_2) = s C_2 V_B
$ <node-B>

which can be solved for $V_A$:

$
V_A = V_B (1 + s R_2 C_2).
$

This allows for the substitution of $V_A$ into equation @node-A, giving

$
frac(V_"in" - V_B (1 + s R_2 C_2), R_1)\
= frac(V_B (1 + s R_2 C_2) - V_B, R_2) + s C_1 [V_B (1 + s R_2 C_2) - V_"out"]
$

The first term in the right side of the equation simplifies to $s C_2 V_B$ thus giving

$
frac(V_"in" - V_B (1 + s R_2 C_2), R_1)\
= s C_2 V_B + s C_1 [V_B (1 + s R_2 C_2) - V_"out"]
$ <node-A-simplified>

=== Op–Amp Feedback and Gain
<opamp-feedback-and-gain>
A voltage divider ($R_3, R_4$) connected from the output of the op-amp to the inverting input provides a gain of

$
K = 1 + frac(R_3, R_4)
$

where the output voltage is given by

$
V_"out" = K V_B.
$<gain-relation>

Substituting @gain-relation into @node-A-simplified gives

$
frac(V_"in" - V_B (1 + s R_2 C_2), R_1)\
= s C_2 V_B + s C_1 [V_B (1 + s R_2 C_2 - K)].
$ <node-A-simplified-2>

Equation @node-A-simplified-2 can finally be rearranged into the transfer function

$
V_"out" / V_"in" = frac(K, 1 + s A + s^2 B).
$ <transfer-function>

where

$
A = R_2 C_2 + R_1 C_2 + R_1 C_1 (1 - K),\
B = R_1 R_2 C_1 C_2.
$ <coefficients>

=== Normalizing to the Standard Second-Order Form
<normalizing-to-the-standard-second-order-form>
A standard second–order low–pass filter has the form

$
H (s) = frac(K omega_0^2, s^2 + omega_0 / Q s + omega_0^2).
$

Compared with equation @transfer-function, the quadratic coefficient from @coefficients is $B = R_1 R_2 C_1 C_2$. Thus the natural frequency $omega_0$ must satisfy

$
omega_0^2 = 1 / B = frac(1, R_1 R_2 C_1 C_2).
$ <natural-frequency-relation>

It is now convenient to rewrite the denominator of @transfer-function by factoring out
$B$:

$
1 + s A + s^2 B\
= B [s^2 + A / B s + 1 / B]\
= B [s^2 + A / B s + omega_0^2].
$

Thus, the transfer function becomes

$
V_"out" / V_"in" = K / B frac(1, s^2 + A / B s + omega_0^2).
$

Multiplying numerator and denominator by $omega_0^2$ (noting that
$omega_0^2 B = 1$ by @natural-frequency-relation) gives

$
V_"out" / V_"in" = frac(K omega_0^2, s^2 + A / B s + omega_0^2).
$

By comparing with the standard form it is clear that

$
omega_0 / Q = A / B.
$

Substitute back $A$ and $B$:

$
omega_0 / Q = (R_2 C_2 + R_1 C_2 + R_1 C_1 (1 - K)) / (R_1 R_2 C_1 C_2).
$

Since $omega_0 = 1 slash sqrt(R_1 R_2 C_1 C_2)$,

$
1 / Q = (R_2 C_2 + R_1 C_2 + R_1 C_1 (1 - K)) / (R_1 R_2 C_1 C_2) sqrt(R_1 R_2 C_1 C_2).
$

Rearranging gives

$
1 / Q = sqrt((R_2 C_2) / (R_1 C_1)) + sqrt((R_1 C_2) / (R_2 C_1)) + (1 - K) sqrt((R_1 C_1) / (R_2 C_2)).
$ <quality-factor>

= Methodology

== Design

Given the common constraints of equal-valued capacitors and a gain of 2, the values of the components were chosen to provide a quality factor $Q$ of $1 slash sqrt(2)$ for a critically damped response. The cutoff frequency was left as a free parameter to be determined by the component values, which were chosen for simplicity and availability.

Given these goals, equation @quality-factor constrains the values of the resistors

$
sqrt(2) = sqrt(R_2 / R_1) + sqrt(R_1 / R_2) - 1 sqrt(R_1 / R_2),\
R_2 = 2 R_1.
$

Deciding $R_1 = 10 thick "k" Omega$ constrains all the other component values given in @component-values.

#figure(
  placement: auto,
  caption: "Theoretical Component Values",
  table(
    columns: 3,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
    table.header(
      "Component",
      "Ideal",
      "Measured"
    ),
    $R_1$, $10 thick "k" Omega$, $10.0280 thick "k" Omega$,
    $R_2$, $20 thick "k" Omega$, $20.083 thick "k" Omega$,
    $R_3$, $24 thick "k" Omega$, $23.949 thick "k" Omega$,
    $R_4$, $24 thick "k" Omega$, $23.689 thick "k" Omega$,
    $C_1$, $100 "nF"$, $98.4265 "nF"$,
    $C_2$, $100 "nF"$, $98.0168 "nF"$,
  )
) <component-values>

From the relation given in equation @natural-frequency-relation, the cutoff frequency is expected to be $1 slash (2 pi sqrt(R_1 R_2 C_1 C_2)) = 112.54 "Hz"$.

The circuit was built on a breadboard shown 


== Experimental Analysis

The frequency response was measured using a function generator and an oscilloscope. The function generator was set to output a sine wave with a peak-to-peak voltage of $1 "V"$, and the frequency was varied from $2 "Hz"$ to $10 "kHz"$ in qualitatively decided intervals. The output peak-to-peak voltage was measured at each frequency and recorded.

The roll-off rate was determined by plotting $Delta "Gain" slash Delta "Frequency"$ and qualitatively estimating the roll-off rate in the stopband.

= Results

The power supply was set to $9 "V"$, and the circuit pulled a current of $0.02 "A"$ i.e. power consumption was $0.18 "W"$.

#figure(
  placement: auto,
  caption: "Oscilloscope Measurement at 50 Hz",
  image("assets/scope_50Hz.png")
) <oscilloscope-measurement>

The measured frequency response is illustrated alongside the theoretical butterworth frequency response in @frequency-response-plot and the measured values are given in @frequency-response-values. The $-3 "dB"$ point is located at approximately $125 "Hz"$, which is higher than the expected cutoff frequency of $112.54 "Hz"$.

#figure(
  placement: auto,
  caption: "Measured and Theoretical Frequency Response",
  image("assets/frequency_response.png")
) <frequency-response-plot>

Looking at @roll-off-rate-plot, the roll-off rate appears to be approximately $-30 "dB" slash "decade"$ in the stopband, which falls short of the expected behavior of a second-order low-pass filter which should be $-40 "dB" slash "decade"$.

#figure(
  placement: auto,
  caption: "Measured and Simulated Roll-off Rate",
  image("assets/Combined Roll-off Rate.png")
) <roll-off-rate-plot>

= Discussion

The cutoff frequency was higher than expected, which can be attributed to the tolerances of the components used, e.g. the capacitors were $98.4265 "nF"$ and $98.0168 "nF"$ instead of the expected $100 "nF"$ which increases the cutoff frequency. 

The roll-off rate was also lower than expected, which can be attributed to the fact that the LF411 op-amp @LF411JFETINPUTOPERATIONAL1997 used in the circuit is not ideal and has a finite gain-bandwidth product. This means that the gain of the op-amp decreases at higher frequencies, which affects the roll-off rate of the filter. The roll-off rate of the LTSpice simulation is illustrated in @roll-off-rate-plot and it can be observed that at the experimental roll-off closely follows the LTSpice simulation up to around $200 "Hz"$ where the experimental roll-off rate begins to slow down, which given the finite gain-bandwidth product of the op-amp supports the expectation that the roll-off rate will not be as steep as the ideal $-40 "dB" slash "decade"$.

= Appendix

== Breadboard

#figure(
  placement: none,
  caption: "Breadboard Circuit",
  image("assets/breadboard.jpg",
    width:(50%),
    height:(50%),
  )
) <breadboard-circuit>

== Simulation

#figure(
  placement: none,
  caption: "LTSpice Circuit",
  image("assets/LTSpice Circuit.png")
) <ltspice-circuit>

#figure(
  placement: none,
  caption: "LTSpice Frequency Response",
  image("assets/LTSpice Frequency Response.png")
) <ltspice-frequency-response>

== Raw Data

#let freq_resp_csv = csv("Processed Freq Resp.csv")
#show figure: set block(breakable: true)
// #colbreak(weak: true)
#figure(
  placement: none,
  caption: "Measured Frequency Response Values",
  table(
    columns: freq_resp_csv.first().len(),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    table.header(
      ..freq_resp_csv.first() // Use the first row as the header
    ),
    ..freq_resp_csv.slice(2).flatten() // Create a subslice starting from 2nd row (excluding the header)
  )
) <frequency-response-values>
