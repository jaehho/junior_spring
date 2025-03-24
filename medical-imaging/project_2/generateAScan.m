function [A_complex, timing] = generateAScan(rawData, D, polyOrder, L2K)
    % generateAScan Processes raw spectral data and returns complex A-scans.
    %
    %   [A_complex, timing] = generateAScan(rawData, D, polyOrder, L2K)
    %
    %   INPUTS:
    %       rawData   - 2048 x nA-scans matrix of spectral data (lambda domain).
    %       D         - Number of columns (A-scans) to use for background estimation.
    %       polyOrder - Order of the polynomial for smoothing the average background.
    %       L2K       - 2048x2048 matrix converting lambda domain to k domain.
    %
    %   OUTPUTS:
    %       A_complex - Processed complex A-scans in the spatial domain.
    %       timing    - Structure with timing info for each processing step.
    %
    %   Steps:
    %       1. Background subtraction (using the regular average background).
    %       2. Polynomial fitting to smooth the background (for deconvolution).
    %       3. Windowing using a Hann window.
    %       4. Convert from lambda to k domain (via L2K multiplication).
    %       5. FFT on the k–domain data.
    %       6. Deconvolution in the frequency domain.
    %       7. Inverse FFT to yield the complex A-scan.
    %
    %   Note: No for-loops are used; all operations are vectorized.
    
        [nSamples, nScans] = size(rawData);
        timing = struct();
        
        %% 1. Background Subtraction
        tStart = tic;
        avg_bg = mean(rawData(:,1:D), 2);          % Average background (lambda domain)
        data_bs = rawData - avg_bg;                % Implicit expansion subtracts avg_bg from each column
        timing.bg_subtraction = toc(tStart);
        fprintf('Background subtraction time: %.4f sec\n', timing.bg_subtraction);
        
        %% 2. Polynomial Fit for Background Smoothing (for deconvolution)
        tStart = tic;
        x = (1:nSamples).';                       % Pixel indices as column vector
        p = polyfit(x, avg_bg, polyOrder);          % Polynomial coefficients
        smooth_bg = polyval(p, x);                  % Smoothed background (lambda domain)
        timing.poly_fit = toc(tStart);
        fprintf('Polynomial fitting time: %.4f sec\n', timing.poly_fit);
        
        %% 3. Windowing (using a Hann window)
        tStart = tic;
        window = hann(nSamples, 'periodic');        % Generate Hann window
        data_win = data_bs .* window;               % Implicit expansion applies window columnwise
        timing.windowing = toc(tStart);
        fprintf('Windowing time: %.4f sec\n', timing.windowing);
        
        %% 4. Convert Data from Lambda to k Domain
        % Multiply the windowed data by L2K so that data is evenly sampled in k.
        tStart = tic;
        data_k = L2K * data_win;                    % data_k is 2048 x nScans
        timing.L2K_conversion = toc(tStart);
        fprintf('L2K conversion time: %.4f sec\n', timing.L2K_conversion);
        
        % Also convert the polynomial-smoothed background
        tStart = tic;
        smooth_bg_k = L2K * smooth_bg;              % Expected to be 2048 x 1
        timing.L2K_bg_conversion = toc(tStart);
        fprintf('L2K background conversion time: %.4f sec\n', timing.L2K_bg_conversion);
        
        %% 5. FFT (convert k-domain data to the frequency domain)
        tStart = tic;
        data_fft = fft(data_k, [], 1);              % FFT along rows (k domain)
        timing.fft = toc(tStart);
        fprintf('FFT time: %.4f sec\n', timing.fft);
        
        %% 6. Deconvolution in the Frequency Domain
        tStart = tic;
        % Compute FFT of the k-domain smoothed background.
        smooth_bg_fft = fft(smooth_bg_k, nSamples); % Should be [2048 x 1]
        % Replicate to match data_fft dimensions
        smooth_bg_fft = repmat(smooth_bg_fft, 1, nScans);
        epsilon = 1e-12;                            % To prevent division by zero
        % Element-wise division (using implicit expansion)
        data_deconv_fft = data_fft ./ (smooth_bg_fft + epsilon);
        timing.deconvolution = toc(tStart);
        fprintf('Deconvolution time: %.4f sec\n', timing.deconvolution);
        
        %% 7. Inverse FFT to Obtain Complex A-scan (Spatial Domain)
        tStart = tic;
        A_complex = ifft(data_deconv_fft, [], 1);
        timing.ifft = toc(tStart);
        fprintf('Inverse FFT time: %.4f sec\n', timing.ifft);
    end
    