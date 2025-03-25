function [deconv_fft, timing] = generateAScan(rawData, D, L2K)
        [nPixels, ~] = size(rawData);
        timing = struct();
        
        %% 1. Convert Raw Data from Lambda to k Domain
        tStart = tic;
        data_k = L2K * rawData; % Data_k should 2048 x nScans
        timing.L2K_conversion = toc(tStart);
        fprintf('L2K conversion time: %.4f sec\n', timing.L2K_conversion);
        
        %% 2. Background Subtraction in k Domain
        tStart = tic;
        avg_bg_k = mean(data_k(:, 1:D), 2);
        data_scans = data_k(:, D+1:end);
        data_bs = data_scans - avg_bg_k;
        timing.bg_subtraction = toc(tStart);
        fprintf('Background subtraction time: %.4f sec\n', timing.bg_subtraction);
        
        %% 3. Polynomial Fit for Background Smoothing (for deconvolution)
        tStart = tic;
        x = (1:nPixels).';
        p = polyfit(x, avg_bg_k, 3); % Fit polynomial of qualitatively good order.
        smooth_bg = polyval(p, x);
        timing.poly_fit = toc(tStart);
        fprintf('Polynomial fitting time: %.4f sec\n', timing.poly_fit);
        
        %% 4. Windowing
        tStart = tic;
        window = gausswin(nPixels); % Gaussian window (maybe use Hamming)
        data_win = data_bs .* window;
        timing.windowing = toc(tStart);
        fprintf('Windowing time: %.4f sec\n', timing.windowing);
        
        %% 5. Deconvolution
        tStart = tic;
        deconv = data_win ./ smooth_bg;
        timing.deconvolution = toc(tStart);
        fprintf('Deconvolution time: %.4f sec\n', timing.deconvolution);

        %% 6. FFT 
        tStart = tic;
        deconv_fft =  fftshift(fft(deconv, [], 1));
        timing.fft = toc(tStart);
        fprintf('FFT time: %.4f sec\n', timing.fft);
    end
    