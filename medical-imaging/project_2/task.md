The raw data in `Bscan_Layers.raw` is a matrix consisting of \( N \) rows and \( M + D \) columns. The first \( D \) columns are the background samples and the remaining \( M \) correspond to Ascans. Ascans are taken at \( M \) points along a line segment in optical coordinates. The full Bscan is 1 mm wide.

The files titled `MscanX.raw`, where X is 1 or 40, contain samples from a speaker playing X tones at 80 dB SPL. The first \( D \) columns of each data set are background, and the next \( R \) are Ascans taken at one location with a sampling rate of \( f_s \) — that is, spaced \( \Delta t = 1 / f_s \) apart.

Data is taken on a ThorLabs Telesto 3, which uses an SLD with center wavelength \( \lambda_0 \approx 1300 \) nm and bandwidth \( \Delta\lambda \approx 100 \) nm. Axial pixel size \( dz = 3.6 \, \mu \)m. Data is taken using an LSM-03 objective lens, which has numerical aperture \( NA = 0.055 \). The data is taken in air, which has \( n = 1 \).

In all cases, recall the mirror image effect and the fact that spurious high-value DC components should not contribute to your image significantly (but may appear).

---

Given the information in the introduction, compute the following:

1. The lateral resolution of the system. What limits the lateral resolution?
2. The axial resolution of the system. What limits the axial resolution?
3. The Bscan “pixel” aspect ratios. What will the Bscan’s aspect ratio be, with/without accounting for the “mirror image” artifact of OCT.

---

Write a function that generates a complex Ascan in the spatial domain. It should include background subtraction as well as windowing and deconvolution. For deconvolution, smooth your background using a polynomial fit (you will want to toy around with the order of this fit by looking at the average background vs the fit). Do not use the smoothed background for background subtraction, but instead use the regular average background. This should not require any for loops at all.

This function may take a bit of time to run. Add time markers to your function and either return or print the amount of time each step takes. Comment on these values in your report.

Display the magnitude (in dB) of 2 Ascans from Bscan_Layers.raw, and one from each of the Mscan files. The Mscan ones should look pretty similar to one another.

For your report, I would like a brief summary of how the function works, a discussion of the time taken by different steps in the function, and the plots of these Ascan magnitudes. I want you to then try to run the same code on any single Ascan you found looked nice a) without deconvolution or background subtraction, and b) without deconvolution but with background subtraction. In your report, compare these to the signal processed with the full pipeline, and explain the differences you see.

---

Create an image from all of the scans in Bcan_Layers.raw. Do not use the function from above, but instead write a new Bscan function of a similar form to the Ascan function that avoids any redundant computation. This should not require any loops at all. 

---

The files titled `MscanX.raw`, where X is 1 or 40, contain samples from a speaker playing X tones at 80 dB SPL. The first \( D \) columns of each data set are background, and the next \( R \) are Ascans taken at one location with a sampling rate of \( f_s \) — that is, spaced \( \Delta t = 1 / f_s \) apart.

To begin, produce the average of the Ascan magnitudes from the 1-tone Mscan.

Then write a script which performs spectral domain phase microscopy (SDPM) given a time series of complex Ascans, \( \Delta t \), and a pixel at which to track sub-pixel motion. It should return a vector of time-domain data in units nm. Remember to unwrap the angle.

Do the same for the other Mscan. Present these outputs in time and frequency.
