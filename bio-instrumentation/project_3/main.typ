#import "conf.typ": ieee

#show: ieee.with(
  title: [Passive High-Pass Filter],
  abstract: [
    This report details the design, implementation, and analysis of a passive third-order LC high-pass filter for biomedical signal applications. The filter was derived from normalized Butterworth low-pass filter values and transformed into a high-pass configuration with a target cutoff frequency of 1 kHz. Experimental measurements and LTSpice simulations were conducted to characterize the frequency response and roll-off behavior. The measured cutoff frequency closely matched the design, though discrepancies in roll-off rate were observed, likely due to limitations in available equipment. Results confirm the filter's suitability for removing low-frequency artifacts.
  ],
  index-terms: ("High-Pass","Bioinstrumentation","Filter Design"),
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

= Introduction
In physiological signal acquisition systems, such as ECG, EMG, or EEG, filtering is critical to isolate the desired biosignals from low-frequency noise and interference, including motion artifacts and baseline drift. A high-pass filter is particularly useful for eliminating these unwanted low-frequency components while preserving the integrity of higher-frequency biomedical signals. The third-order filter offers enhanced selectivity and steeper roll-off compared to lower-order designs, making it suitable for applications requiring precise frequency discrimination.

The ladder or Pi configuration of the filter illustrated in @fig:circuit-design is a common design choice for high-pass filters, as it provides a compact and efficient layout.

#figure(
  placement: auto,
  caption: "Passive High-Pass Filter",
  image("assets/circuit_design.drawio.png")
)<fig:circuit-design>

= Methodology

== Design Process

From "Table A-1 Element values for low-pass single-resistance-terminated lossless-ladder realizations" in _Introduction to the Theory and Design of Active Filters_ @huelsmanIntroductionTheoryDesign1980, the following values are given for a 3rd-order butterworth low-pass filter with a $1 "rad"slash upright(s)$ bandwidth terminated with a resistance of $R = 1 Omega$:

$
L_1 = 1.5000\
C_2 = 1.3334\
L_3 = 0.5000
$

To transform the low-pass filter into a high-pass filter, the inductors become capacitors with $C = 1 slash L$ and the capacitors become inductors with $L = 1 slash C$. The values for the high-pass filter are thus:

$
C'_1 = 1/L_1 = 0.6667\
L'_2 = 1/C_2 = 0.7500\
C'_3 = 1/L_3 = 2.0000
$

To denormalize the filter such that the cutoff frequency is $f_c = 1 "kHz"$ or $omega_c = 2 pi f_c = 3141.59 "rad"slash upright(s)$ and with a load resistance of $R_L = 1 thick "k" Omega$, the component values should be scaled accordingly:

$
C''_1 = C'_1 / (R omega_c) = 106.10 "nF"\
L''_2 = (R L'_2) / (omega_c) = 119.37 "mH"\
C''_3 = C'_3 / (R omega_c) = 318.31 "nF"
$

== Experimental Setup

To explore the difficulties of working with inductors, the single inductor in the design was built with two inductors in series, $L_11$ and $L_12$. They were placed orthogonally to each other to minimize the coupling between them as shown in @fig:experimental-circuit. To keep the circuit compact and simple, the components values were chosen to match the design values as closely as possible, however, given the available components and the coupling between the inductors, the measured values are not identical to the design values. The component values are shown in @fig:component-values.

#figure(
  placement: auto,
  caption: "Component Values",
  table(
    columns: 4,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },
    table.header(
      "Component",
      "Design",
      "Ideal",
      "Measured"
    ),
    $C_1$, $106.10 "nF"$, $100 "nF"$, $93.9543 "nF"$,
    $C_2$, $318.31 "nF"$, $330 "nF"$, $354.231 "nF"$,
    $L_11$, "NA", $68 "mH"$, $68.5271 "mH"$,
    $L_12$, "NA", $68 "mH"$, $68.4791 "mH"$,
    $L_1$, $119.37 "mH"$, "NA", $225.395 "mH"$,
    $R_"ind"$, $0 thick Omega$, "NA", $104.016 thick Omega$,
    $R_L$, $1 thick "k" Omega$, $1 "k" Omega$, $0.99853 thick "k" Omega$,
  )
) <fig:component-values>

The frequency response of the filter was measured by collecting the input and output voltages at octave intervals from $2 "Hz"$ to $20 "MHz"$ using the oscilloscope's function generator and probes connected to the input and output. The interval at which the expected cutoff frequency is located was measured with more detail, collecting data at $0.1 "kHz"$ intervals from $1 "kHz"$ to $2 "kHz"$. At lower frequencies, the output voltage was below what the oscilloscope could measure, however, the oscilloscope's function generator was limited to a max voltage peak-to-peak of $5 "V"$, which was not enough to measure the output voltage at low frequencies. As a result, a separate function generator was used which could output a higher voltage but with a smaller range of frequencies.

The roll-off rate was calculated as the maximum derivative of the gain with respect to frequency.

== Simulation
The circuit was simulated using LTSpice to compare the measured results with the expected behavior of the filter. The simulation was set up to match the experimental measured component values, including the inductor's winding resistance. 

= Results and Discussion

== Frequency Response

The collected measurements are given in @fig:frequency-response-table, and the frequency response is plotted in @fig:frequency-response with the simulated response for comparison. The measured frequency response crosses the $-3 "dB"$ line at $1.218 "kHz"$, which is only slightly lower than the simulated cutoff frequency of $1.419 "kHz"$. The original frequency response also shows a plateau below $100 "Hz"$ which is likely due to the limited accuracy of the oscilloscope at low voltages, which is close to $110 "mV"$ at the output in this range. The frequency response from the higher voltage function generator seems to support this hypothesis as it lacks the plateau. Unfortunately, given the limited frequency range of the function generator, the lower frequencies could not be measured and from the plot, and from @fig:frequency-response-table, the output voltage again hit the supposed minimum voltage of $110 "mV"$ at $20 "Hz"$.

From the original function generator there is also an increase in the gain at high frequencies past around $1 "MHz"$ where @fig:frequency-response-table shows that the output does not deviate significantly, instead the input voltage appears to fall off; the cause of this is not clear.

#figure(
  placement: auto,
  caption: "Frequency Response: the measured responses crosses the -3 dB line at 1.218 kHz, and the simulated response crosses at 1.419 kHz.",
  image("figures/freq_resp.png")
) <fig:frequency-response>

== Roll-off Rate

For a third-order filter, the expected roll-off rate is $20 times 3 = 60 "dB" slash "decade"$, which is consistent with the simulated roll-off rate shown in @fig:gain-derivative. However, the measured roll-off rate was found to be approximately $46.01 "dB" slash "decade"$, which is closer to the expected $40 "dB" slash "decade"$ for a second-order filter. This may again be due to the oscilloscope's limited accuracy at low voltages as the measured roll-off rate only begins to increase after $100 "Hz"$, where at which point the simulated roll-off rate is already over $50 "dB"$. However, using a higher voltage function generator did not fully address this issue as the roll-off does improve slightly but still significantly lower than the simulation. The derivative values are given in @fig:gain-derivative-table.

#figure(
  placement: auto,
  caption: "Derivative of Gain: the roll-off rate is interpreted as the maximum in the stopband; the measured roll-off rate is approximately 46.01 dB/decade, and the simulated roll-off rate is 60 dB/decade.",
  image("figures/derivative.png")
) <fig:gain-derivative>

= Appendix

#figure(
  placement: none,
  caption: [Experimental Circuit: input at yellow wire, output at green wire. $L_11$ is the top inductor with its pins direction facing southeast, $L_12$ is the bottom inductor with its pins direction facing southwest.],
  image("assets/circuit.jpg")
)<fig:experimental-circuit>

#figure(
  placement: none,
  caption: "LTSpice Schematic",
  image("assets/LTSpice_sch.drawio.svg")
)

#pagebreak()
#let freq_resp_csv = csv("assets/freq_resp.csv")
#show figure: set block(breakable: true)
#figure(
  placement: none,
  caption: "Measured Frequency Response Values",
  table(
    columns: freq_resp_csv.first().len(),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    // table.header(
    //   ..freq_resp_csv.first() // Use the first row as the header
    // ),
    table.header(
      [$f$ \ [Hz]], [Original \ $V_"in"$ \ [V]], [Original \ $V_"out"$ \ [V]], [Original \ Gain \ [dB]], [High \ $V_"in"$ \ [V]], [High \ $V_"out"$ \ [V]], [High \ Gain \ [dB]]
    ),
    ..freq_resp_csv.slice(1).flatten() // Create a subslice starting from 2nd row (i.e. excluding the header)
  )
) <fig:frequency-response-table>

#pagebreak()
#let gain_derivative_csv = csv("assets/derivative.csv")
#show figure: set block(breakable: true)
#figure(
  placement: none,
  caption: "Gain Derivative Values",
  table(
    columns: gain_derivative_csv.first().len(),
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    // table.header(
    //   ..gain_derivative_csv.first() // Use the first row as the header
    // ),
    table.header(
      // "Frequency\n[Hz]", "Measured\n[dB/decade]", "Simulated\n[dB/octave]"
      [$f$ \ [Hz]], [Original \ [dB/decade]], [High \ [dB/decade]], [Simulated \ [dB/decade]]
    ),
    ..gain_derivative_csv.slice(1).flatten() // Create a subslice starting from 2nd row (i.e. excluding the header)
  )
) <fig:gain-derivative-table>

