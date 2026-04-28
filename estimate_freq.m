% Estimates the carrier frequency of a complex input signal using the selected method.
%
%   Inputs:
%       x      : complex input signal vector [N x 1]
%       fs     : sampling frequency (Hz)
%       method : frequency estimation method selector
%                  1 : Periodogram       - peak of zero-padded FFT power spectrum
%                  2 : Welch             - peak of Welch power spectral density
%                  3 : MVDR             - minimum variance distortionless response
%                  4 : MUSIC            - subspace-based spectral estimator
%                  5 : Instantaneous frequency - circular mean of lag-1 phase increments
%                  6 : Unwrapped phase slope   - amplitude-weighted linear regression
%                  7 : Kay estimator           - lag-1 autocorrelation phase
%
%   Output:
%       f0 : estimated carrier frequency (Hz)

function f0 = estimate_freq(x, fs, method)

N = length(x);
x = x(:);

if method < 4
    M     = round(N/4);
    freqs = linspace(0, fs/2, 2000);
    P     = zeros(size(freqs));
end

switch method
    case 1  % Periodogram
        X   = fft(x, 4*N);
        Pxx = abs(X).^2 / (N*fs);
        f   = (0:length(X)-1) * (fs/length(X));
        [~, idx] = max(Pxx(1:end/2));
        f0  = f(idx);

    case 2  % Welch
        win   = hamming(round(N/4));
        nover = round(length(win)/2);
        [Pxx, f] = pwelch(x, win, nover, 4*N, fs);
        [~, idx] = max(Pxx);
        f0 = f(idx);

    case 3  % MVDR
        for k = 1:length(freqs)
            a    = exp(-1j*2*pi*freqs(k)/fs * (0:M-1)).';
            P(k) = 1 / abs(a' * (R \ a));
        end

    case 4  % MUSIC
        [E, D] = eig(R);
        [~, idx] = sort(diag(D));
        En = E(:, idx(1:end-1));                        % noise subspace [M x (M-1)]
        for k = 1:length(freqs)
            a    = exp(-1j*2*pi*freqs(k)/fs * (0:M-1)).';
            P(k) = 1 / abs(a' * (En*En') * a);
        end

    case 5  % Instantaneous frequency via lag-1 phase increments
        prodlag = x(2:end) .* conj(x(1:end-1));
        dphi    = angle(prodlag);                       % lag-1 phase increments in (-pi, pi]
        C       = sum(exp(1j*dphi));
        phi_hat = angle(C);                             % circular mean of increments
        f0      = (fs/(2*pi)) * phi_hat;

    case 6  % Unwrapped phase slope via amplitude-weighted linear regression
        mag    = abs(x);
        thresh = 0.05 * median(mag);
        valid  = mag >= thresh;
        phi_raw = angle(x);
        t  = (0:N-1).';
        ph = exp(1j*phi_raw);
        if any(~valid)                                  % interpolate low-power samples
            rp = real(ph); ip = imag(ph);
            rp(~valid) = interp1(t(valid), rp(valid), t(~valid), 'pchip', 'extrap');
            ip(~valid) = interp1(t(valid), ip(valid), t(~valid), 'pchip', 'extrap');
            ph = complex(rp, ip);
        end
        phi    = unwrap(angle(ph));
        n_cent = t - mean(t);                           % centered index for numerical stability
        w      = mag.^2;                                % power-based weights
        slope  = sum(w .* (n_cent .* phi)) / (sum(w .* (n_cent.^2)) + eps);
        f0     = (fs/(2*pi)) * slope;

    case 7  % Kay estimator via lag-1 autocorrelation phase
        r1   = sum(x(1:end-1) .* conj(x(2:end)));      % lag-1 autocorrelation
        phi1 = angle(r1);
        f0   = (fs/(2*pi)) * phi1;
end
end