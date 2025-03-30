#import "conf.typ": ieee

#show: ieee.with(
  title: [Extracting Images and Displacements from Raw Spectral Domain Optical Coherence Tomography Data],
  abstract: [
    Optical coherence tomography (OCT) is a non-invasive imaging modality widely employed in medical diagnostics due to its high resolution. This paper presents a processing pipeline developed for spectral domain OCT (SD-OCT) data, specifically designed to reconstruct high-quality images and measure minute displacements. Raw SD-OCT data acquired from a ThorLabs Telesto 3 system were processed using background subtraction, windowing, and deconvolution techniques to extract spatial-domain complex A-Scans. B-Scan images were subsequently reconstructed, and sub-pixel displacements were measured using spectral domain phase microscopy (SDPM). We report on image quality improvements, quantification of axial and lateral resolutions, pixel aspect ratio considerations, and precise displacement detection performance. These methodologies highlight improvements over unprocessed images and confirm the effectiveness of this pipeline in clinical and research contexts.
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

== Abstract
Optical coherence tomography (OCT) is a non-invasive imaging modality widely employed in medical diagnostics due to its high resolution. This paper presents a processing pipeline developed for spectral domain OCT (SD-OCT) data, specifically designed to reconstruct high-quality images and measure minute displacements. Raw SD-OCT data acquired from a ThorLabs Telesto 3 system were processed using background subtraction, windowing, and deconvolution techniques to extract spatial-domain complex A-Scans. B-Scan images were subsequently reconstructed, and sub-pixel displacements were measured using spectral domain phase microscopy (SDPM). We report on image quality improvements, quantification of axial and lateral resolutions, pixel aspect ratio considerations, and precise displacement detection performance. These methodologies highlight improvements over unprocessed images and confirm the effectiveness of this pipeline in clinical and research contexts.

---

== Introduction
Spectral domain optical coherence tomography (SD-OCT) is widely recognized for its superior resolution and non-destructive imaging capability in biomedical applications. Raw data obtained from SD-OCT systems require extensive signal processing to extract meaningful spatial information. Typical processing pipelines include background subtraction, spectral deconvolution, and correction for artifacts such as mirror images. This project implements a comprehensive pipeline to handle raw data collected from a ThorLabs Telesto 3 SD-OCT device with a central wavelength of approximately 1300 nm and a bandwidth of 100 nm. We explore the impact of processing techniques on image resolution, artifact reduction, and displacement measurements at sub-pixel levels using spectral domain phase microscopy (SDPM). Specific goals include quantifying the lateral and axial resolutions, determining pixel aspect ratios, and analyzing speaker membrane displacement signals.

---

== Methodology
=== Data Acquisition
Data were acquired using a ThorLabs Telesto 3 SD-OCT system with a center wavelength (λ₀) of 1300 nm, bandwidth (Δλ) of 100 nm, and numerical aperture (NA) of 0.055. Raw OCT data comprised 2048-pixel A-Scans recorded from multiple locations (M-scans and B-scans). Background reference data was recorded separately to facilitate subtraction and correction of systemic biases.

=== Signal Processing Pipeline
A computational pipeline was developed and implemented in MATLAB/Python, encompassing:

- _Background Subtraction_: Removal of static artifacts using averaged background samples.
- _Polynomial Smoothing & Deconvolution_: Polynomial fitting was applied to smooth the background noise, facilitating effective deconvolution.
- _Windowing_: To reduce spectral leakage, a windowing function was applied prior to the Fourier transformation.
- _Fourier Transformation_: Conversion from spectral domain to spatial domain, generating complex A-scans.

=== Image Reconstruction (B-Scans)
Multiple A-scans were combined without redundancy to generate B-Scan images. Contrast enhancement and image filtering were applied after examining individual A-scans to mitigate mirror-image artifacts and maximize image clarity.

=== Spectral Domain Phase Microscopy (SDPM)
Sub-pixel displacements were extracted by tracking phase shifts in successive A-scans. Time-series data from M-scans were processed, employing angle unwrapping methods to achieve accurate displacement measurements in nanometers.

---

== Results
=== Image Quality and Resolution
Processed B-Scan images demonstrated significant improvements compared to raw and partially processed data. Axial and lateral resolutions were calculated based on system parameters:

- _Lateral resolution_: Limited primarily by the numerical aperture, calculated to be approximately [...] μm.
- _Axial resolution_: Determined by the source bandwidth, approximately [...] μm.
- _Pixel Aspect Ratio_: Computed considering the mirror artifact, the correct aspect ratio for physical accuracy was found to be [...] compared to an uncorrected ratio of [...].

=== Displacement Analysis
Phase microscopy revealed speaker membrane displacements accurately at both single-tone (1-tone) and complex-tone (40-tone) inputs:

- _Single-tone Analysis_: The dominant frequency was determined to be [...] kHz, consistent with input conditions.
- _Complex-tone Analysis_: Forty distinct frequencies were accurately identified within the measured displacement signals. The linearity and frequency response of the speaker were characterized and analyzed, indicating [...] in frequency response and linearity of the speaker.

---

== Discussion
=== Image Reconstruction Improvements
Processed images significantly reduced background noise and mirror artifacts. Contrast enhancement using polynomial background fitting provided clear differentiation between layers, allowing precise identification of physical structures, such as tape layers.

=== Displacement Measurement Accuracy
The accuracy of sub-pixel displacement measurements was confirmed through spectral domain phase microscopy. Frequency domain analysis verified expected speaker output frequencies, supporting the system’s sensitivity in measuring subtle displacements.

=== Methodological Considerations
The processing pipeline’s efficiency was evaluated by timing computational steps. Background subtraction and deconvolution notably improved signal clarity, despite adding computational overhead. Future implementations could optimize processing time further by employing parallel processing techniques or GPU acceleration.

---

== Conclusion
This paper demonstrates a robust computational pipeline for processing spectral domain OCT data to obtain high-resolution images and precise displacement measurements. The methodology significantly improves image quality, provides accurate quantification of physical properties, and reliably captures sub-pixel scale displacements. This pipeline is broadly applicable for enhancing the diagnostic capabilities of SD-OCT systems in clinical and research settings.

---

== References
[Insert relevant references here.]

---

_Keywords_: Spectral Domain OCT, Image Processing, Deconvolution, Spectral Domain Phase Microscopy, Sub-pixel Displacement Measurement, Medical Imaging.

---