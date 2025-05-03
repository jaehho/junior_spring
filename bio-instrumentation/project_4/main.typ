#import "conf.typ": ieee

#show: ieee.with(
  title: [Bridge Circuit for Transducer Interface],
  abstract: [
    A Wheatstone bridge circuit was developed to interface a strain gauge transducer for mechanical deformation sensing. The bridge circuit was paired with an instrumentation amplifier to provide high-gain differential signal amplification. This project highlights practical considerations in bridge design, including resistor matching, mechanical mounting, and signal conditioning for bioinstrumentation applications.
  ],
  index-terms: ("Strain Gauge", "Wheatstone Bridge", "Instrumentation Amplifier", "Transducer Interface"),
  authors: (
    (
      name: "Jaeho Cho",
      department: [ECE444 - Bioinstrumentation and Sensing],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "jaeho.cho@cooper.edu",
    ),
  ),
  bibliography: bibliography("refs.bib"),
)

= Introduction

Transducers that convert mechanical deformation into electrical signals, such as strain gauges, require careful signal conditioning to ensure accurate measurement. A common method to accomplish this is by integrating the transducer into a Wheatstone bridge circuit as depicted in @fig:wheatstone-bridge. The Wheatstone bridge allows for precise detection of small resistance changes by balancing the circuit around a known voltage reference. When combined with an instrumentation amplifier, this setup provides high common-mode rejection and gain to produce a usable output signal.

#figure(
  placement: auto,
  caption: "Wheatstone bridge circuit.",
  image("figures/circuit.png"),
) <fig:wheatstone-bridge>

= Methodology

The common resistors of the Wheatstone bridge were chosen to as closely match the strain gauge resistance, which was acheived by using a $100 Omega$ resistor in series with a $20 Omega$ resistor; the experimental values of these resistors are given in @fig:component-values. The strain gauge effectively acts as a variable resistor completing the Wheatstone bridge. The bridge is powered by a regulated $5 "V"$ supply generated with a 7805 voltage regulator.

#figure(
  placement: auto,
  caption: "Wheatstone Resistors in Series",
  table(
    columns: 3,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0 { rgb("#efefef") },
    table.header(
      "Resistor",
      "Ideal",
      "Measured",
    ),

    "Top Left", $100 Omega$, $98.10 Omega$,
    "Top Left", $20 thick Omega$, $22.07 thick Omega$,
    "Top Right", $100 Omega$, $97.68 Omega$,
    "Top Right", $20 thick Omega$, $21.91 thick Omega$,
    "Bottom Right", $100 Omega$, $97.49 Omega$,
    "Bottom Right", $20 thick Omega$, $21.83 thick Omega$,
    "Strain Gauge (No Load)", $120 thick Omega$, $120.07 thick Omega$,
  ),
) <fig:component-values>

The original implementation of the circuit is shown in left of @fig:bread where the blue wires are connected to the inputs of an instrumentation amplifier developed in a previous project @choInstrumentationAmplifier25. However to trim the DC offset, the $100 Omega$ resistor of the bottom right resistors in series of the Wheatstone bridge was replaced with a $100 Omega$ potentiometer as shown in the right of @fig:bread.

#figure(
  placement: auto,
  caption: "Wheatstone Bridge Implementation. Left: Original Implementation; Right: Potentiometer Implementation",
  grid(
    columns: 2,
    gutter: 1em,
    image("figures/bread.png"),
    image("figures/bread_pot.png"),
  ),
) <fig:bread>

The strain gauge was originally mounted on a plastic ruler acting as a cantilever beam. However, to test the full range of the strain gauge, it was later moved to the end of the plastic ruler as depicted in @fig:strain-gauge. As a demonstration of the strain gauge in this configuration, the strain gauge was approximately bent to reach $plus.minus 90 degree$ also depicted in @fig:strain-gauge.

#figure(
  placement: auto,
  caption: "Strain Gauge Setup. Left: No load Setup; Top Right: Negative Bending; Bottom Right: Positive Bending. Positive bending is defined as bending the strain gauge away from the soldered leads, while negative bending is defined as bending the strain gauge into the soldered leads.",
  grid(
    columns: 2,
    rows: 2,
    gutter: 1em,
    grid.cell(
      rowspan: 2,
      image("figures/pic_zero.png"),
    ),
    image("figures/pic_up.png"),
    image("figures/pic_down.png"),
  ),
)<fig:strain-gauge>

= Results

The output of the instrumentation amplifier was measured with an oscilloscope and the results are shown in @fig:scope. As seen in the average measurements, the output with no load was around $273 "mV"$, positive bending was around $6.333 "V"$, and negative bending was around $-7.123 "V"$. With a small difference between positive and negative bending, it seems that the strain gauge is equally sensitive to both bending directions.

#figure(
  placement: auto,
  caption: "Oscilloscope Screenshots. Top: No Load; Middle: Positive Bending; Bottom: Negative Bending",
  grid(
    rows: 3,
    gutter: 1em,
    image("figures/scope_zero.png"),
    image("figures/scope_up.png"),
    image("figures/scope_down.png"),
  )
)<fig:scope>

= Discussion

The method of trimming the DC offset with a potentiometer in the Wheatstone bridge was opted over a potentiometer in the instrumentation amplifier circuit. This was done to avoid the need of altering the already implemented circuit.

The strain gauge was difficult to work with due to its small size and fragility, and in the end after breaking a couple leads, I was unable to implement further features for this project, like adding another strain gauge to the other side of the beam.

