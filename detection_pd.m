% DETECTION_PD Computes the test statistic T for spectrum sensing using phase-difference (PD)-based
% techniques. The phase difference is computed between samples separated by ss.delta positions.
%
%   Inputs:
%       signal_rx  : complex matrix [runs x nsamples] of received signal samples
%       ss         : struct with fields:
%                      - ss.delta  : lag used for phase difference computation
%                      - ss.tech   : sensing technique selector (1, 2, 3, 4, or 12)
%                      - ss.nbins  : number of histogram bins
%                      - ss.number_of_k : number of SCR search points (case 12 only)
%       i          : current Monte Carlo iteration index
%       toggle     : auxiliary flag passed to histo
%       fc         : carrier frequency (Hz)
%       Fs         : sampling frequency (Hz)
%       runs       : number of Monte Carlo runs
%       snr        : signal-to-noise ratio (dB)
%       freq_error : carrier frequency offset (Hz)
%
%   Output:
%       T : test statistic value for the selected sensing technique
%
%   Techniques:
%       1  - SRD     : slope of the empirical PD-PDF
%       2  - CRD     : correlation between the PD and a (fc/fs)-dependant cosine
%       3  - PDP-Var : ratio of max to min of the empirical PD-PDF
%       4  - GED     : ratio of max to min of the empirical PD-PDF (alternative bins)
%       12 - E-CRD   : max cosine projection over a SCR search range [1, 25]

function [T] = detection_pd(signal_rx, ss, i, toggle, fc, Fs, runs, snr, freq_error)

fi_n = atan2(imag(signal_rx), real(signal_rx));
delta = ss.delta;
theta_n = mod((fi_n(:, 1+delta:end) - fi_n(:, 1:end-delta)), 2*pi);

switch ss.tech
    case 1  % SRD
        [xpdf_empirical, ypdf_empirical] = histo(theta_n(l,:), ss.nbins);
        ypdf_empirical = smooth(xpdf_empirical, ypdf_empirical, 0.86, 'loess');
        tan_am = (ypdf_empirical(floor(ss.nbins/2)+1) - ...
            ypdf_empirical(1)) / xpdf_empirical(floor(ss.nbins/2)+1);
        tan_bm = (ypdf_empirical(floor(ss.nbins/2)+1) - ...
            ypdf_empirical(ss.nbins)) / (xpdf_empirical(floor(ss.nbins/2)+1) - 2*pi);
        T = (tan_am - tan_bm) / 2;

    case 2  % CRD
        [xpdf_empirical, ypdf_empirical] = histo(theta_n, ss.nbins, i, toggle, fc, Fs, runs, snr, delta, freq_error);
        thetai = xpdf_empirical;
        T = sum(ypdf_empirical .* cos(2*pi*fc/(Fs+freq_error) - thetai) * 2*pi/ss.nbins);

    case 3  % PDP-Var
        T = max(ypdf_empirical) / min(ypdf_empirical);

    case 4  % GED
        [~, ypdf_empirical] = fcn_coder_pdf(theta_n(l,:), 3);
        T = max(ypdf_empirical) / min(ypdf_empirical);

    case 12  % E-CRD
        [xpdf_empirical, ypdf_empirical] = histo(theta_n, ss.nbins, i, toggle, fc, Fs, runs, snr, delta, freq_error);
        thetai = xpdf_empirical;
        delta_bin = 2*pi / ss.nbins;

        % Search over SCR range k = Fs/fc in [1, 25]
        K_search = linspace(1, 25, ss.number_of_k);
        T_k = zeros(size(K_search));
        for j = 1:length(K_search)
            k = K_search(j);
            theta0_k = 2*pi / k;    % theoretical PD center for this SCR
            T_k(j) = sum(ypdf_empirical .* cos(theta0_k - thetai) * delta_bin);
        end

        % T is the maximum projection over the search range
        [T, ~] = max(T_k);
end

end