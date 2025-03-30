#import "conf.typ": ieee

#show: ieee.with(
  title: [Extracting Images and Displacements from Raw Spectral Domain Optical Coherence Tomography Data],
  abstract: [
    #lorem(30),
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

L2K transforms the data into the linearly sampled data in the k domain via interpolation as $k = 2 pi / lambda$

// the b-scan: to account for the mirror image artifact, the "negative" frequency components of the A-scans were used and the positive frequency components were discarded. The results should be the same regardless of using positive or negative frequency components, however to align with the A-Scan equation, the negative frequency components were used to represent the cross correlation terms. 
// Unnecessary and might be wrong ^^^