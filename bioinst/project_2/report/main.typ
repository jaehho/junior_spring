#import "conf.typ": ieee

#show: ieee.with(
  title: [Active Low-Pass Filter],
  abstract: [],
  index-terms: ("Butterworth",),
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

explain sallen-key topology and butterworth filter

$ omega_n eq 1 / sqrt(R_1 R_2 C_1 C_2) $

$ 1 / Q eq sqrt(frac(R_2 C_2, R_1 C_1)) plus sqrt(frac(R_1 C_2, R_2 C_1)) plus (1 minus K) sqrt(frac(R_1 C_1, R_2 C_2)) $

$ H_0 eq K $


#figure(
  placement: auto,
  caption: "Sallen-Key topology for the active low-pass filter.",
  image(
    "assets/sallen-key circuit.drawio.png",
  )
)

= Methodology

= Results

Power: 0.02 A x 9 V

plot with measured freq resp and predicted freq resp
#figure(
  placement: auto,
  caption: "Measured and Theoretical Frequency Response",
  image("assets/frequency_response.png")
)

= Discussion

= Appendix

#figure(
  placement: auto,
  caption: "Frequency response of the active low-pass filter.",
  table(
    columns: 2,
  )
)

#figure(
  placement: auto,
  caption: "Experimental Component Values",
  table(
    columns: 2,
    rows: (
      ("R1", "10 kΩ"),
      ("R2", "10 kΩ"),
      ("C1", "0.1 μF"),
      ("C2", "0.1 μF"),
    )
  )