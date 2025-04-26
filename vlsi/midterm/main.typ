#set page(fill: rgb("444352"))
#set text(fill: rgb("fdfdfd"))
#set line(stroke: (paint: rgb("fdfdfd")))
#set table(fill: rgb("444352"), stroke: rgb("fdfdfd"))

= ECE345 Midterm Project Report

#figure(
  caption: "Schematic",
  image("schematic.png"),
)

#figure(
  caption: "Schematic with DC Operating Points",
  image("schematic_op.png"),
)

#figure(
  caption: "Testbench Schematic",
  image("tb_schematic.png"),
)

#figure(
  caption: "Testbench Schematic with DC Operating Points",
  image("tb_schematic_op.png"),
)

#figure(
  caption: "Gain Frequency Response",
  image("sim_gain.png"),
)

#figure(
  caption: "Gain & Phase Frequency Response",
  image("sim_phase.png"),
)

#figure(
  caption: "Full Layout",
  image("layout.png"),
)

#figure(
  caption: "Focused Layout",
  image("layout_focus.png"),
)

#figure(
  caption: "PVS DRC Results",
  image("DRC.png"),
)

#figure(
  caption: "Assura LVS Results",
  image("LVS.png"),
)

#figure(
  caption: "Specifications",
  table(
    columns: 3,
    [Specification], [Target], [Achieved],
    [Gain \@ Low Frequencies], [>40 dB], [41.28 dB],
    [Unity Gain Frequency], [>5 GHz], [5.13 GHz],
    [Phase Margin], [>60°], [94.85°],
    [Peak-to-Peak Amplitude], [400 mV], [906 mV],
  )
)