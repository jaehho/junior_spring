function [B_scan, timing] = generateBScan(detector_current, num_z_pixels, num_bg_scans, L2K, do_bg_subtract, do_deconv, verbose)
    timing = struct();

    detector_current_reshaped   = reshape(detector_current, num_z_pixels, []);

    if verbose
        tiledlayout(2, 1);
        nexttile;
        plot(detector_current_reshaped(:,1));
        axis tight;
        title('Detector Current - Background Scan');
        nexttile;
        plot(detector_current_reshaped(:,num_bg_scans+1));
        axis tight;
        title('Detector Current - Imaging Scan');
    end

    %% 1. Convert Raw Data from Lambda to k Domain
    tStart = tic;
    data_k = L2K * detector_current_reshaped;
    timing.L2K_conversion = toc(tStart);
    fprintf('L2K conversion time: %.4f sec\n', timing.L2K_conversion);

    avg_bg = mean(data_k(:, 1:num_bg_scans), 2);
    data_scans = data_k(:, num_bg_scans+1:end);

    %% 2. Background Subtraction in k Domain
    if do_bg_subtract
        tStart = tic;
        data_bs = data_scans - avg_bg;
        timing.bg_subtraction = toc(tStart);
        fprintf('Background subtraction time: %.4f sec\n', timing.bg_subtraction);
    else
        data_bs = data_scans;
    end

    %% 3. Windowing
    tStart = tic;
    window = gausswin(num_z_pixels);
    data_win = data_bs .* window;
    timing.windowing = toc(tStart);
    fprintf('Windowing time: %.4f sec\n', timing.windowing);

    %% 4. Deconvolution
    if do_deconv
        tStart = tic;
        x = (1:num_z_pixels)';
        p = polyfit(x, avg_bg, 3);
        smooth_bg = polyval(p, x);
        data_deconv = data_win ./ smooth_bg;
        timing.deconvolution = toc(tStart);
        fprintf('Deconvolution time: %.4f sec\n', timing.deconvolution);
    else
        data_deconv = data_win;
    end

    %% 6. FFT to Spatial Domain
    tStart = tic;
    B_scan = fft(data_deconv, [], 1);
    timing.fft = toc(tStart);
    fprintf('FFT time: %.4f sec\n', timing.fft);
end
