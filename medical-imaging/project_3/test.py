def compress_array(arr, s, interpolate=False):
    pass

def compress_fft(img, s, cmap='gray', norm='linear', hist_bins=300, axes=None, axes_row=0):
    FFT_img = np.fft.fftshift(np.fft.fft2(img))
    
    F_compressed = compress_array(FFT_img, s, interpolate=True)
    
    reconstructed = np.real(np.fft.ifft2(np.fft.ifftshift(F_compressed)))
    
    F_mag = np.abs(F_compressed)
    F_log_mag = np.log1p(F_mag)
    
    mse = get_mse(normalize_01(reconstructed), normalize_01(img))
    
    if axes is not None:
        plot_row(
            axes, axes_row,
            reconstructed, f"{s}% zeroed\nMSE={mse:.4f}",
            F_log_mag, "FFT Log Magnitude",
            F_log_mag, hist_bins, "FFT Log Mag Histogram",
            cmap=cmap, norm=norm
        )
    return reconstructed, mse
