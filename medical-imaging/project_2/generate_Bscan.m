function [Bscan, timing] = generate_Bscan(detector_current, N_axial, D, L2K, do_bg_subtract, do_deconv, verbose)
    timing = struct();

    detector_current_reshaped   = reshape(detector_current, N_axial, []);

    if verbose
        processing_fig = figure("Name", "Ascan Processing Steps");
        steps_fig = tiledlayout(processing_fig, 'vertical');
        nexttile(steps_fig);
        plot(detector_current_reshaped(:,D+1));
        axis tight;
        set(gca, 'XTick', [], 'YTick', []);
        title('Detector Current');

        detector_fig = figure("Name", "Detector Current");
        detector_current_fig = tiledlayout(detector_fig, 2, 1, "TileSpacing", "tight", "Padding", "tight");
        nexttile(detector_current_fig);
        plot(detector_current_reshaped(:,1));
        axis tight;
        set(gca, 'XTick', [], 'YTick', []);
        title('Background');
        nexttile(detector_current_fig);
        plot(detector_current_reshaped(:,D+1));
        axis tight;
        set(gca, 'XTick', [], 'YTick', []);
        title('Imaging');
        exportgraphics(detector_fig, 'figures/Detector_Current.png', 'Resolution', 300);
    end

    %% 1. Convert Raw Data from Lambda to k Domain
    tStart = tic;
    data_k = L2K * detector_current_reshaped;
    timing.L2K_conversion = toc(tStart);
    fprintf('L2K conversion time: %.4f sec\n', timing.L2K_conversion);
    if verbose
        nexttile(steps_fig);
        plot(data_k(:,D+1));
        axis tight;
        set(gca, 'XTick', [], 'YTick', []);
        title('K-space');
    end

    avg_bg = mean(data_k(:, 1:D), 2);
    data_scans = data_k(:, D+1:end);

    %% 2. Background Subtraction in k Domain
    if do_bg_subtract
        tStart = tic;
        data_bs = data_scans - avg_bg;
        timing.bg_subtraction = toc(tStart);
        fprintf('Background subtraction time: %.4f sec\n', timing.bg_subtraction);
        if verbose
            nexttile(steps_fig);
            plot(data_bs(:,1));
            axis tight;
            set(gca, 'XTick', [], 'YTick', []);
            title('Background Subtraction');
        end
    else
        data_bs = data_scans;
    end

    %% 3. Windowing
    tStart = tic;
    window = gausswin(N_axial);
    data_win = data_bs .* window;
    timing.windowing = toc(tStart);
    fprintf('Windowing time: %.4f sec\n', timing.windowing);
    if verbose
        nexttile(steps_fig);
        plot(data_win(:,1));
        axis tight;
        set(gca, 'XTick', [], 'YTick', []);
        title('Gaussian Window');
    end

    %% 4. Deconvolution
    if do_deconv
        tStart = tic;
        x = (1:N_axial)';
        p = polyfit(x, avg_bg, 3);
        smooth_bg = polyval(p, x);
        data_deconv = data_win ./ smooth_bg;
        timing.deconvolution = toc(tStart);
        fprintf('Deconvolution time: %.4f sec\n', timing.deconvolution);
        if verbose
            nexttile(steps_fig);
            plot(data_deconv(:,1));
            axis tight;
            set(gca, 'XTick', [], 'YTick', []);
            title('Deconvolution');
        end
    else
        data_deconv = data_win;
    end

    %% 6. FFT to Spatial Domain
    tStart = tic;
    Bscan = fft(data_deconv, [], 1);
    timing.fft = toc(tStart);
    fprintf('FFT time: %.4f sec\n', timing.fft);
    if verbose
        nexttile(steps_fig);
        plot(abs(Bscan(:,1)));
        axis tight;
        set(gca, 'XTick', [], 'YTick', []);
        title('FFT');
        processing_fig.Position = [100, 100, 560, 420 * 3];
        exportgraphics(processing_fig, 'figures/Ascan_Processing.png', 'Resolution', 300);
    end
end
