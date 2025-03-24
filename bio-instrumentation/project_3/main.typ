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

= Methodology

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