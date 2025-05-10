#import "conf.typ": ieee

#show: ieee.with(
  title: [Laboratory Use of the Agilent E5071C Network Analyzer],
  abstract: [This report documents the use of the Agilent E5071C Vector Network Analyzer (VNA) to characterize the performance of a Mini-Circuits ZAPDQ-2-S power splitter over the 0.8–2.2 GHz frequency range. Utilizing the 85052D calibration kit, S-parameters were measured at five distinct frequencies (0.85, 1.15, 1.5, 1.85, and 2.15 GHz) to assess insertion loss, return loss, phase imbalance, amplitude imbalance, isolation, and VSWR. The results are compared with ideal and specified values to evaluate the device's compliance with nominal performance criteria. Key deviations were observed, particularly in phase imbalance, while amplitude and isolation generally aligned with expectations.],
  authors: (
    (
      name: "Noam Schuck",
      department: [ECE335],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "noam.schuck@cooper.edu",
    ),
    (
      name: "Jaeho Cho",
      department: [ECE335],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "jaeho.cho@cooper.edu",
    ),
    (
      name: "Azra Rangwala",
      department: [ECE335],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "azra.rangwala@cooper.edu",
    ),
  ),
  index-terms: ("VNA", "S-parameters", "Power Splitter"),
  bibliography: bibliography("refs.bib"),
  figure-supplement: [Fig.],
)

= Introduction

The Agilent E5071C Vector Network Analyzer (VNA) is a crucial tool for characterizing high-frequency components in RF systems. Its ability to measure S-parameters enables the analysis of both magnitude and phase response in linear, passive networks. This lab introduces practical operation of a VNA by evaluating a Mini-Circuits ZAPDQ-2-S two-way power splitter—a device expected to exhibit equal power division, 90° phase shift between outputs, and high port-to-port isolation within the 1.0–2.0 GHz range.

The primary objectives of this experiment were to develop proficiency in using the VNA and to compare ideal circuit behavior to empirical RF measurements.

= Methodology

This lab uses the Agilent E5071C Vector Network Analyzer (with S/N MY46111282) @E5071CENAVector with the 85052D calibration kit (S/N MY43252832) @keysight85052DEconomyMechanical, measuring the ZAPQD-2 (S/N SF191101152) @ZAPDQ2CoaxialPower from 0.8-2.2GHz. S parameters were measured at 0.85 GHz, 1.15 GHz, 1.5 GHz, 1.85 GHz, and 2.15 GHz.

= Results and Discussion
#{
  set image(width: 77%)

  figure(
    placement: auto,
    caption: [Smith Chart of Reflection Coefficient with Port 1 = Splitter Port S and Port 2 = Splitter Port 1 over the Frequency Range Specified],
    image("figures/smith.png"),
  )

  figure(
    placement: auto,
    caption: [Isolation between ports 1 and 2.],
    image("figures/isolation.png"),
  )

  figure(
    placement: auto,
    caption: [Phase between Input Port S and Output Port 1.],
    image("figures/phase.png"),
  )
}

#{
  set figure(placement: top)

  set table(
    columns: (.5in, 1fr, 1fr, 1fr),
    align: bottom,
    fill: (x, y) => if y == 0 { teal } else if x == 0 or y <= 1 { silver },
  )

  show table.cell: it => {
    if it.x == 0 or it.y <= 1 {
      strong(it)
    } else {
      it
    }
  }

  [#figure(
      caption: [Experimental Log Magnitude],
      grid(
        gutter: 1em,
        table(
          table.cell(colspan: 4, [0.850 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-13.584/-13.274], [-3.6663], [-5.3215],
          [Port 1], [-3.6413], [-24.532/-23.844], [-22.215],
          [Port 2], [-5.2934], [-22.171], [-6.4609/-6.2515],
        ),
        table(
          table.cell(colspan: 4, [1.15 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-17.091/18.416], [-4.0563], [-4.2405],
          [Port 1], [-3.9801], [-20.14/-21.036], [-32.915],
          [Port 2], [-4.1723], [-32.94], [-15.32/-15.751],
        ),
        table(
          table.cell(colspan: 4, [1.5 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-17.378/-16.353], [-4.1753], [-4.3716],
          [Port 1], [-4.1942], [-17.218/-21.291], [-39.204],
          [Port 2], [-4.3364], [-39.144], [-14.643/-13.331],
        ),
        table(
          table.cell(colspan: 4, [1.85 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-22.263/23.502], [-4.3136], [-4.5145],
          [Port 1], [-4.2347], [-19.661/18.607], [-22.564],
          [Port 2], [-4.426], [-22.441], [-16.367/-17.-019],
        ),
        table(
          table.cell(colspan: 4, [2.15 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-14.578/-13.071], [-4.6871], [-4.78],
          [Port 1], [-4.6731], [-20.275/-21.028], [-18.166],
          [Port 2], [-4.7006], [-18.087], [-23.671/-23.118],
        ),
      ),
    ) <tab:experimental-log-magnitude>]

  [#figure(
      caption: [Ideal Log Magnitude],
      grid(
        gutter: 1em,
        table(
          table.cell(colspan: 4, [0.850 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-12.24], [-3.306], [-4.863],
          [Port 1], [-3.305], [-18.79], [-23.79],
          [Port 2], [-4.865], [-23.78], [-5.959],
        ),
        table(
          table.cell(colspan: 4, [1.15 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-17.11], [-3.467], [-3.647],
          [Port 1], [-3.463], [-19.89], [-39.07],
          [Port 2], [-3.649], [-39.05], [-14.07],
        ),
        table(
          table.cell(colspan: 4, [1.50 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-15.78], [-3.569], [-3.815],
          [Port 1], [-3.562], [-18.75], [-39.52],
          [Port 2], [-3.819], [-39.52], [-11.97],
        ),
        table(
          table.cell(colspan: 4, [1.85 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-23.76], [-3.631], [-3.838],
          [Port 1], [-3.63], [-16.47], [-21.19],
          [Port 2], [-3.841], [-21.19], [-14.76],
        ),
        table(
          table.cell(colspan: 4, [2.15 GHz]),
          [Out\\In], [Port S], [Port 1], [Port 2],
          [Port S], [-14.02], [-3.856], [-3.945],
          [Port 1], [-3.8497], [-22.89], [-15.45],
          [Port 2], [-3.941], [-15.45], [-32.73]
        ),
      ),
    ) <tab:ideal-log-magnitude>]
}

The average deviation of the amplitude of the s-parameters is shown in @tab:deviation-log-magnitude. The deviation is calculated by taking the difference between the experimental and ideal values of the log magnitude of the s-parameters. The deviation is within 1.5 dB for all frequencies except for 1.15 GHz, where the deviation is 2.415 dB.

@tab:supp_measurements shows the amplitude imbalance, phase imbalance, and isolation of the splitter. The ideal values were obtained from the nominal frequencies 1, 1.12, 1.52, 1.84, and 2 GHz respectively. The experimental amplitude imbalance appears relatively close enough with the ideal values; the phase imbalance on the other hand is not. The isolation also appears to match the specs as the signal is still attenuated significantly in the experimental results.

@tab:phase-results presents the phases from port 1 to 2 and from port 2 to 1. The phase imbalance is calculated by adding 90° to the phase of port 1 to port 2 and the phase of port 2 to port 1. 

@tab:vswr presents the experimental and ideal voltage standing wave ratio (VSWR) values for the splitter, where the ideal values were similarly obtained from the nominal frequencies 1, 1.12, 1.52, 1.84, and 2 GHz respectively. The experimental values appear similar to the ideal values except outside the nominal range.

// placed here for better formatting
#figure(
  caption: [Deviation From Ideal Log Magnitude],
  placement: none,
  table(
    columns: 2,
    fill: (x, y) => if x == 0 or y == 0 { silver },
    [*Frequency [GHz]*], [*Deviation [dB]*],
    [0.850], [0.795],
    [1.15], [2.415],
    [1.50], [0.501],
    [1.85], [0.862],
    [2.15], [1.434],
  ),
) <tab:deviation-log-magnitude>

#{
  set figure(placement: top)

  set table(
    columns: (.7in, 1fr, 1fr, 1fr),
    align: bottom,
    fill: (x, y) => if y == 0 { teal } else if x == 0 or y <= 1 { silver },
  )

  show table.cell: it => {
    if it.x == 0 or it.y <= 1 {
      strong(it)
    } else {
      it
    }
  }

  [#figure(
      caption: [Supplementary Measurements],
      grid(
        gutter: 1em,
        table(
          table.cell(colspan: 4, [Experimental]),
          [Frequency [GHz]], [Amplitude\ Imbalance [dB]], [Phase\ Imbalance [dB]], [Isolation [dB]],
          [0.850], [1.6521], [12.7545], [22.1930],
          [1.15], [0.1922], [76.2295], [32.9275],
          [1.50], [0.1422], [42.835], [39.1740],
          [1.85], [0.1913], [29.8205], [22.5025],
          [2.15], [0.0275], [15.2225], [18.1265],
        ),
        table(
          table.cell(colspan: 4, [Ideal]),
          [Frequency [GHz]], [Amplitude\ Imbalance [dB]], [Phase\ Imbalance [dB]], [Isolation [dB]],
          [0.850], [0.34], [3.35], [32.84],
          [1.15], [0.1], [1.03], [37.41],
          [1.50], [0.06], [1.9], [35.64],
          [1.85], [0.14], [0.61], [23.99],
          [2.15], [0.14], [1.07], [19.65],
        ),
      ),
    ) <tab:supp_measurements>]

  [#figure(
      caption: [Experimental Phase Results],
      grid(
        gutter: 1em,
        table(
          columns: (.7in, 1fr, 1fr, 1fr, 1fr),
          [], table.cell(colspan: 2, [Phase]), table.cell(colspan: 2, [Phase Imbalance]),
          [Frequency [GHz]], [Port 1->2], [Port 2->1], [Port 1->2 +90#sym.degree], [Port 2->1 +90#sym.degree],
          [0.850], [-77.866], [-76.625], [12.134], [13.375],
          [1.15], [-13.795], [-13.746], [76.205], [76.254],
          [1.50], [-132.81], [-132.86], [42.81], [42.86],
          [1.85], [60.153], [60.206], [29.847], [29.794],
          [2.15], [74.559], [74.996], [15.441], [15.004],
        ),
      ),
    ) <tab:phase-results>]

  colbreak()

  [#figure(
      caption: [VSWR Values],
      grid(
        gutter: 1em,
        table(
          table.cell(colspan: 4, [Experimental]),
          [Frequency [GHz]], [Port S], [Port 1], [Port 2],
          [0.850], [1.5416], [1.1315], [2.85565],
          [1.15], [1.2998], [1.207], [1.40175],
          [1.50], [1.33545], [1.25375], [1.502],
          [1.85], [1.15485], [1.249], [1.3433],
          [2.15], [1.515], [1.20515], [1.14535],
        ),
        table(
          table.cell(colspan: 4, [Ideal]),
          [Frequency [GHz]], [Port S], [Port 1], [Port 2],
          [0.850], [1.48], [1.48], [1.78],
          [1.15], [1.3], [1.19], [1.41],
          [1.50], [1.34], [1.28], [1.56],
          [1.85], [1.11], [1.29], [1.39],
          [2.15], [1.42], [1.10], [1.42],
        ),
      ),
    )<tab:vswr>]
}

#colbreak()