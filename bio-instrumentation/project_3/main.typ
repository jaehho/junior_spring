#import "conf.typ": ieee

#show: ieee.with(
  title: [Passive High-Pass Filter],
  abstract: [
    
  ],
  index-terms: ("",),
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

Passive filters are foundational in signal processing, enabling frequency domain control without active elements. High-pass filters (HPFs) allow signals with frequencies higher than a specified cutoff frequency to pass through while attenuating lower frequencies. This study investigates a variant of a passive high-pass filter using two capacitors and one inductor in a novel configuration, assessing its behavior with a standard 1 kΩ load impedance.

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

To denormalize the filter such that the cutoff frequency is $f_c = 500 "Hz"$ or $w_c = 2 pi f_c = 3141.59 "rad"slash upright(s)$, the component values should be scaled by $R slash w_c$. Letting $R = 10"K" Omega$ gives the following values:

$
C''_1 = C'_1 / (R * w_c) = 0.2122\
L''_2 = L'_2 / (R * w_c) = 0.2387\
C''_3 = C'_3 / (R * w_c) = 0.6366
$

== Experimental Setup

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
    $C_1$, $100 "nF"$, $93.9543 "nF"$,
    $C_2$, $100 "nF"$, $354.231 "nF"$,
    $L_1$, $0.2122 "mH"$, $225.395 "mH"$,
    $R_"ind"$, $0 thick Omega$, $104.016 thick Omega$,
    $R_L$, $1 thick "k" Omega$, $0.99853 thick "k" Omega$,
  )
) <component-values>

68.6271
75.4791

225.395 m

= Results and Discussion

== 4.1 Frequency Response

#let freq_resp_csv = csv("freq_resp.csv")
#show figure: set block(breakable: true)

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

This paper demonstrates the feasibility and effectiveness of a passive high-pass filter using two capacitors and a single inductor. The filter achieved predictable behavior with a sharp cutoff near the designed frequency and negligible attenuation in the passband. The configuration is suitable for applications requiring compact, passive high-frequency filtration with minimal component count.

= Discussion

- The table showed certain values
- To get the proper corner frequency, how did you apply a frequency denormalization?
- To get your inductor value, what impedance denormalization did you apply?
- What component values did that give you?
- What components were you able to find? Did that make you go back and redo the impedance denormalization?