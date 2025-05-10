#set page(fill: rgb("444352"))
#set text(fill: rgb("fdfdfd"))
#set line(stroke: (paint: rgb("fdfdfd")))
#set table(fill: rgb("444352"), stroke: rgb("fdfdfd"))

= ECE345 Midterm Project Report

#figure(
  caption: "Original Schematic",
  image("schematic.png"),
)

#figure(
  caption: "Noise Optimized Schematic",
  image("sch_noise.png"),
)

#figure(
  caption: "Original Schematic with DC Operating Points",
  image("schematic_op.png"),
)

#figure(
  caption: "Noise Optimized Schematic with DC Operating Points",
  image("sch_op_noise.png"),
)

#figure(
  caption: "Frequency Response Comparison",
  image("noise_optimization.png"),
)

Increasing the width of M1 and M2 from 2#sym.mu to 3#sym.mu resulted in a 12.4% RMS reduction in total input-referred noise.

#figure(
  caption: "Specifications",
  table(
    columns: 4,
    table.header[Specification][Target][Original][Noise Optimized],
    [Gain \@ Low Frequencies], [>40 dB], [41.28 dB], [41.55 dB],
    [Unity Gain Frequency], [>5 GHz], [5.13 GHz], [6.06 GHz],
    [Phase Margin], [>60#sym.degree], [94.85#sym.degree], [91.31#sym.degree],
    [Peak-to-Peak Amplitude], [400 mV], [906 mV], [831 mV],
    [Power Consumption], [\<4.5 mW], [4.19 mW], [4.53 mW],
    [Total Input Referred Noise], [NA], [5.16e-10 V#super("2")/Hz], [3.96e-10 V#super("2")/Hz]
  )
)
