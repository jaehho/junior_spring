#import "conf.typ": ieee

#show: ieee.with(
  title: [Wavelets, Compression and Compressed Sensing in Magnetic Resonance Imaging],
  abstract: [
    Magnetic Resonance Imaging is a powerful non-invasive imaging modality widely used in clinical and research settings. However, MRI suffers from inherently long acquisition times, which limits its accessibility and utility in time-sensitive applications. This report explores the role of wavelets, frequency-domain compression, and compressed sensing techniques in accelerating MRI data acquisition and reconstruction. The sparsity of MRI images is investigated in both the Fourier and wavelet domains using multiple wavelet bases (Haar, Daubechies 4, and Coiflet 3) and quantifies reconstruction performance through Mean Squared Error (MSE) analysis. Results demonstrate that wavelet-based compression achieves superior visual fidelity and lower MSE compared to the Fourier domain. Furthermore, compressed sensing with proximal gradient descent and optimized regularization parameters effectively reconstructs undersampled MRI data, with the best performance observed at a sampling probability of 0.5.
  ],
  index-terms: ("Wavelets", "Compressed Sensing", "Magnetic Resonance Imaging", "Proximal Gradient Descent"),
  authors: (
    (
      name: "Jaeho Cho",
      department: [ECE425 - Medical Imaging],
      organization: [The Cooper Union for the Advancement of Science and Art],
      location: [New York City, NY],
      email: "jaeho.cho@cooper.edu"
    ),
  ),
  bibliography: bibliography("refs.bib")
)

= Introduction

Magnetic Resonance Imaging (MRI) offers high-resolution, contrast-rich images of internal anatomy without the use of ionizing radiation. Despite its clinical advantages, MRI remains limited by relatively slow data acquisition, primarily due to the need for extensive sampling in k-space (the spatial frequency domain). To address this bottleneck, researchers have turned to signal processing techniques that leverage the inherent sparsity of MRI data.

Two key innovations, wavelet transforms and compressed sensing (CS), have emerged as powerful tools for accelerating MRI. Wavelets provide a multiresolution representation that captures both global and localized image features, making them ideal for representing MRI images sparsely. Compressed sensing further exploits this sparsity by allowing accurate image reconstruction from undersampled data, thereby reducing scan times.

This report examines the effectiveness of wavelet-based compression and compressed sensing techniques in the context of structural brain MRI. Using various wavelet bases and decomposition levels, the effectiveness of how well MRI images can be compressed while retaining structural integrity is evaluated. The project also implements CS with proximal gradient descent to reconstruct images from partial data, tuning hyperparameters to optimize performance. Comparisons across methods are made using Mean Squared Error (MSE) and visual assessment. Through this analysis, practical pathways for enhancing MRI acquisition efficiency without sacrificing image quality are identified.

= Methodology

== Data Acquisition

This report uses structural and functional MRI data from the BOLD5000 dataset, which includes imaging from four participants (CSI1–CSI4) across multiple sessions. Functional data were acquired during slow event-related presentations of over 5,000 real-world scenes, with participants performing a simple valence judgment task.

For analysis, T1 and T2-weighted anatomical scans were used to extract sagittal, coronal, and axial cross-sections. These slices were processed in Python, including wavelet decomposition, Fourier transform-based compression, and compressed sensing reconstruction using proximal gradient descent.

== Image Processing

The wavelets coefficients are displayed in the standard layout described in the pywavelet documentation @leePyWaveletsPythonPackage2019. The images are however scaled such that each coefficients array is normalized independently to make smaller coefficients more visible. the coefficients are also displayed as their absolute values to maintain simplicity.

= Results & Discussion

== Navigating the Volumes
Patient CSI1's T1 and T2-weighted images are shown in @fig:cross-sections, where it can be seen that the gray matter is darker than the white matter in T1-weighted images, while the opposite is true for T2-weighted images. The cerebrospinal fluid (CSF) appears bright in T2-weighted images but dark in T1-weighted images. This is consistent with the T1 and T2 values of the different tissues, as shown in @tab:structural-values, which shows that T1 rewards small T1 values, while T2 rewards large T2 values.

The contrast in MRI images is determined by how pulse sequence parameters interact with tissue-specific relaxation times. The T1-weighted sequence parameters are given in @tab:json-params, the short echo time, moderate repetition time, and inversion time are optimized to exploit differences in T1 relaxation, enhancing contrast between white and gray matter while suppressing CSF signal due to its long T1. Conversely, the T2-weighted sequence uses a much longer TE and TR, which allows signal from tissues with long T2 (like CSF) to remain high while signal from white and gray matter decays more, creating strong T2 contrast. The time units in the JSON metadata are in seconds, as indicated by the consistency of their values with the known millisecond-scale T1 and T2 times of brain tissues from @tab:structural-values.

#figure(
  placement: auto,
  image("figures/cross-sections.svg"),
  caption: [Sagittal, coronal, and axial cross-sections of the A-scan image in grayscale and scaled magnitude. The Sagittal image is a 2D slice with 256x256 pixels, while the coronal and axial images are 2D slices with 256x176 pixels.],
)<fig:cross-sections>

#figure(
  placement: auto,
  caption: [Structural T1 and T2 Values],
  table(
    columns: 3,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Structure][T1 (ms)][T2 (ms)],
    [White Matter],[510],[67],
    [Grey Matter],[760],[77],
    [Cerebrospinal Fluid],[2650],[280]
  )
)<tab:structural-values>

#figure(
  placement: auto,
  caption: [T1 and T2 JSON Parameters],
  table(
    columns: 3,
    stroke: (x, y) => if y <= 1 { (top: 0.5pt) },
    fill: (x, y) => if y > 0 and calc.rem(y, 2) == 0  { rgb("#efefef") },

    table.header[Time][T1 (ms)][T2 (ms)],
    [Echo Time],[1.97],[422],
    [Repetition Time],[2300],[3000],
    [Inversion Time],[900],[N/A]
  )
)<tab:json-params>

== Fourier Domain Compression

@fig:fft-compression shows compression in the Fourier domain, with the first row showing no compression, where the sparsity in the Fourier domain is apparent. At 90% compression, most of the brain structures are still discernable, but the image appears noisy. At 95% compression, it is difficult to identify the brain structures, and the image appears very noisy and blurry. Despite the visual quality of the compressed images, the MSE values are still relatively low.

#figure(
  placement: auto,
  caption: [Compression in the Fourier domain at [0%, 90%, 95%] compression, (zero compression shown on the first row as a base line). The MSE value of the compressed image to the original is provided above the images on the left column. The center column presents the shifted log magnitude of the Fourier domain, such that low freqency values are depicted in the center and high frequency components near the edges. The histogram of the FFT Log Magnitude values are shows on the right with the zero bin removed for better visualization. The histogram was created with 300 bins and aligned to the left.],
  image("figures/fft-compression.svg"),
)<fig:fft-compression>

== Wavelet Domain Compression

@fig:cameraman-wavelets shows the 2-level 2D wavelet decompositions of the standard cameraman image using Haar, Daubuchies 4, and Coiflet 3 wavelet bases, and the three wavelet bases appear relatively similar with subtle differences in the brighter edges. @fig:standard-basis-element-wavelets shows the 2-level 2D wavelet decompositions of a standard basis element image using Haar, Daubuchies 4, and Coiflet 3 wavelet bases. The wavelet decompositions appear near identical with almost a blurring effect to the standard element. However, after taking the Fourier transform of the wavelet coefficients, the differences between the three wavelet bases become apparent. @fig:fft-coeff-haar, @fig:fft-coeff-db4, and @fig:fft-coeff-coif3 show the Fourier transform magnitudes of the wavelet coefficients of the standard basis element image. The Fourier transform magnitudes of the Haar wavelet coefficients appear blank which may make sense given that the Fourier transform of an impulse should be constant. The Fourier transform magnitudes of the Daubuchies 4 and Coiflet 3 wavelet coefficients appear similar, and are expected as the horizontal coefficients appear to have more vertical frequency components, while the vertical coefficients appear to have more horizontal frequency components. Unexpectedly the Daubuchies 4 level 1 horizontal coefficients appear to have more vertical frequency components than the Coiflet 3 level 1 horizontal coefficients, which may be due to the shape of the wavelet functions.

#figure(
  placement: auto,
  caption: [2-level 2D wavelet decompositions of standard cameraman image using Haar, Daubuchies 4, and Coiflet 3 wavelet bases.],
  image("figures/cameraman-wavelets.svg"),
)<fig:cameraman-wavelets>

#figure(
  placement: auto,
  caption: [2-level 2D wavelet decompositions of standard basis element image using Haar, Daubuchies 4, and Coiflet 3 wavelet bases. The standard basis element is a 256x256 img that is zero everywhere except the pixel located at [128, 128].],
  image("figures/standard-basis-element-wavelets.svg", height: 95%),
)<fig:standard-basis-element-wavelets>

#figure(
  placement: auto,
  caption: [Fourier transform magnitudes of the Haar wavelet coefficients of the standard basis element image.],
  image("figures/fft-coeff-haar.svg"),
)<fig:fft-coeff-haar>

#figure(
  placement: auto,
  caption: [Fourier transform magnitudes of the Daubuchies 4 wavelet coefficients of the standard basis element image.],
  image("figures/fft-coeff-db4.svg"),
)<fig:fft-coeff-db4>

#figure(
  placement: auto,
  caption: [Fourier transform magnitudes of the Coiflet 3 wavelet coefficients of the standard basis element image.],
  image("figures/fft-coeff-coif3.svg"),
)<fig:fft-coeff-coif3>

Various representations of the wavelet functions of the Haar, Daubuchies 4, and Coiflet 3 wavelet bases are illustrated in @fig:wavelet-functions, @fig:wavelet-2d, and @fig:wavelet-3d. The wavelet decompositions of the guide image using wavelet bases are shown in @fig:guide-wavelets. 

#figure(
  image("figures/wavelet-functions.svg"),
  caption: [Wavelet functions of the Haar, Daubuchies 4, and Coiflet 3 wavelet bases. The scaling functions are shown in the first row, while the wavelet functions are shown in the second row. The functions were calculated at a level of refinement of 10.],
  placement: auto,
)<fig:wavelet-functions>

#figure(
  image("figures/wavelet-3d.svg"),
  caption: [3D plots of the scaling functions of the Haar, Daubuchies 4, and Coiflet 3 wavelet bases. The functions were calculated at a level of refinement of 10.],
  placement: auto,
)<fig:wavelet-3d>

#figure(
  image("figures/wavelet-2d.svg"),
  caption: [2D plots of the scaling functions of the Haar, Daubuchies 4, and Coiflet 3 wavelet bases. The functions were calculated at a level of refinement of 10.],
  placement: auto,
)<fig:wavelet-2d>

#figure(
  image("figures/guide-wavelets.svg"),
  caption: [2-level 2D wavelet decompositions of guide image using Haar, Daubuchies 4, and Coiflet 3 wavelet bases.],
  placement: auto,
)<fig:guide-wavelets>

Histograms of the wavelet decomposition coefficients of the guide image using the 3 wavelet bases are shown in @fig:wavelet-histograms-haar, @fig:wavelet-histograms-db4, and @fig:wavelet-histograms-coif3. From these histograms, it can be noticed that higher level decompositions have more low magnitude coefficients(that are not zero), which points to using higher level wavelet decompositions for compression. From the histograms, the best domain to compress appears to be the level 3 Daubuchies 4 wavelet decomposition.

#figure(
  placement: auto,
  caption: [Histograms of the wavelet decomposition coefficients of the guide image using the Haar wavelet basis. The histograms were created with 300 bins and aligned to the left. The zero bin was removed to assess which domain would have the most non-zero coefficients that could be compressed.],
  image("figures/wavelet-histograms-haar.svg"),
)<fig:wavelet-histograms-haar>

#figure(
  placement: auto,
  caption: [Histograms of the wavelet decomposition coefficients of the guide image using the Daubuchies 4 wavelet basis. The histograms were created with 300 bins and aligned to the left. The zero bin was removed to assess which domain would have the most non-zero coefficients that could be compressed.],
  image("figures/wavelet-histograms-db4.svg"),
)<fig:wavelet-histograms-db4>

#figure(
  placement: auto,
  caption: [Histograms of the wavelet decomposition coefficients of the guide image using the Coiflet 3 wavelet basis. The histograms were created with 300 bins and aligned to the left. The zero bin was removed to assess which domain would have the most non-zero coefficients that could be compressed.],
  image("figures/wavelet-histograms-coif3.svg"),
)<fig:wavelet-histograms-coif3>

The wavelet decompositions of the compressed image using the 3 level Daubuchies 4 wavelet basis are shown in @fig:wavelet-compression. Compared to the FFT compression, the wavelet compression appears to maintain more visual quality at 90% and 95% compression. The MSE values of the compressed images are also lower than those of the FFT compressed images.

#figure(
  image("figures/wavelet-compression.svg"),
  caption: [Compression in the 3 level Daubuchies 4 wavelet domain at [0%, 90%, 95%] compression, (zero compression shown on the first row as a base line). The MSE value of the compressed image to the original is provided above the images on the left column. The center column presents the wavelet decompositions of the compressed image, and the histogram of the wavelet coefficients are shows on the right with the zero bin removed for better visualization. The histogram was created with 300 bins and aligned to the left.],
  placement: auto,
)<fig:wavelet-compression>

== How Sparse

@fig:mse-compression and @fig:mse-compression-T2 show the MSE values of the compressed guide image using 1 to 3 levels of 3 wavelet bases. If 10% MSE is acceptable, then up to around 98% compression on any one of the wavelet bases at 3 levels of decomposition is acceptable.

#figure(
  image("figures/mse-compression.svg"),
  caption: [MSE values of the compressed guide image (T1 sagittal slice) using 1 to 3 levels of Haar, Daubuchies 4, and Coiflet 3 wavelet bases.],
  placement: auto,
)<fig:mse-compression>

#figure(
  image("figures/mse-compression_T2.svg"),
  caption: [MSE values of the compressed guide image (T2 sagittal slice) using 1 to 3 levels of Haar, Daubuchies 4, and Coiflet 3 wavelet bases.],
  placement: auto,
)<fig:mse-compression-T2>

== Compressed Sensing

@fig:lambdas shows the convergence plots for different #sym.lambda values for 50 iterations to identify the best #sym.lambda value. The convergence plots show that the best #sym.lambda value will be the lowest one, however the lower #sym.lambda values also appear to be more "cloudy". Thus the #sym.lambda value for the deeper convergence iterations was arbitrarily chosen to be .01, and the convergence plots for different p values over 1000 iterations are shown in @fig:average-convergence. The reconstructed images after 1000 iterations using different p values are shown in @fig:average-images, and it can be seen that a p value of 0.5 appears to be the best choice, as it has the least amount of noise and is able to reconstruct the image well. The p value of 0.1 appears to be too low, as it is unable to reconstruct the image well, while the p value of 0.75 appears to be too high, as it loses some of the details in the image.

#figure(
  image("figures/lambdas.svg"),
  caption: [Convergence plots for various #sym.lambda s, over 50 iterations to identify best lambda.],
  placement: auto,
)<fig:lambdas>

#figure(
  image("figures/lambdas-frames.svg"),
  caption: [Reconstructed images for various #sym.lambda s, over 50 iterations to identify best lambda.],
  placement: auto,
)

#figure(
  image("figures/average-convergence.svg"),
  caption: [Convergence plots over 1000 iterations of proximal gradient descent after undersampling of p=[0.1, 0.5, 0.75].],
  placement: auto,
)<fig:average-convergence>

#figure(
  image("figures/average-images.svg"),
  caption: [Reconstructed images after 1000 iterations of proximal gradient descent after undersampling of p=[0.1, 0.5, 0.75].],
  placement: auto,
)<fig:average-images>
