% Computes the CRD blind test statistic and estimates the carrier frequency error
% from the first harmonic of the empirical phase-difference PDF.
%
%   Inputs:
%       signal_rx     : complex matrix [runs x nsamples] of received signal samples
%       ss            : struct with fields:
%                         - ss.delta : lag used for phase difference computation
%                         - ss.nbins : number of histogram bins
%       i             : current Monte Carlo iteration index
%       toggle        : if 1, enables PDF plotting at selected iterations
%       fosc          : nominal carrier frequency (Hz)
%       Fs            : sampling frequency (Hz)
%       runs          : total number of Monte Carlo runs
%       snr           : signal-to-noise ratio (dB)
%       freq_missmatch: carrier frequency offset (Hz)
%
%   Outputs:
%       T     : blind CRD test statistic (magnitude of first harmonic)
%       f_err : estimated carrier frequency error, fosc - fc_est (Hz)

function [T, f_err] = detection_ferr(signal_rx, ss, i, toggle, fosc, Fs, runs, snr, freq_missmatch)

    fi_n    = atan2(imag(signal_rx), real(signal_rx));
    delta   = ss.delta;
    theta_n = mod((fi_n(:, 1+delta:end) - fi_n(:, 1:end-delta)), 2*pi);

    [xpdf_empirical, ypdf_empirical] = histo(theta_n, ss.nbins, i, toggle, fosc, Fs, runs, snr, delta, freq_missmatch);
    thetai = xpdf_empirical;

    C     = sum(ypdf_empirical .* exp(1j * thetai));    % first harmonic of PD-PDF
    T     = abs(C);                                     % blind CRD statistic

    phi_hat = angle(C);
    if phi_hat < 0; phi_hat = phi_hat + 2*pi; end       % map to [0, 2*pi)
    fc_est  = (Fs / (2*pi)) * phi_hat;                  % frequency estimate from phase
    f_err   = fosc - fc_est;                            % carrier frequency error
end

