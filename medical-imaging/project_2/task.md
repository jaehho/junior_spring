The raw data in `BScan_Layers.raw` is a matrix consisting of \( N \) rows and \( M + D \) columns. The first \( D \) columns are the background samples and the remaining \( M \) correspond to A-Scans. A-Scans are taken at \( M \) points along a line segment in optical coordinates. The full B-Scan is 1 mm wide.

The files titled `MScanX.raw`, where X is 1 or 40, contain samples from a speaker playing X tones at 80 dB SPL. The first \( D \) columns of each data set are background, and the next \( R \) are A-Scans taken at one location with a sampling rate of \( f_s \) — that is, spaced \( \Delta t = 1 / f_s \) apart.

Data is taken on a ThorLabs Telesto 3, which uses an SLD with center wavelength \( \lambda_0 \approx 1300 \) nm and bandwidth \( \Delta\lambda \approx 100 \) nm. Axial pixel size \( dz = 3.6 \, \mu \)m. Data is taken using an LSM-03 objective lens, which has numerical aperture \( NA = 0.055 \). The data is taken in air, which has \( n = 1 \).

In all cases, recall the mirror image effect and the fact that spurious high-value DC components should not contribute to your image significantly (but may appear).

---

Given the information in the introduction, compute the following:

1. The lateral resolution of the system. What limits the lateral resolution?
2. The axial resolution of the system. What limits the axial resolution?
3. The B-Scan “pixel” aspect ratios. What will the B-Scan’s aspect ratio be, with/without accounting for the “mirror image” artifact of OCT.
