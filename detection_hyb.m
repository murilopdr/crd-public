% Computes two test statistics for the Hybrid ED/CRD sensing technique (case 5).
% T1 is the energy detection statistic and T2 is the CRD cosine projection
% of the empirical phase-difference PDF onto the carrier frequency.
%
%   Inputs:
%       signal_rx     : complex matrix [runs x nsamples] of received signal samples
%       ss            : struct with fields:
%                         - ss.nbins : number of histogram bins
%       i             : current Monte Carlo iteration index
%       toggle        : if 1, enables PDF plotting at selected iterations
%       fosc          : carrier frequency (Hz)
%       Fs            : sampling frequency (Hz)
%       runs          : total number of Monte Carlo runs
%       snr           : signal-to-noise ratio (dB)
%       freq_missmatch: carrier frequency offset (Hz)
%
%   Outputs:
%       T1 : energy detection statistic (sum of squared magnitudes)
%       T2 : CRD statistic (cosine projection of PD-PDF onto carrier frequency)

function [T1, T2] = detection_hyb(signal_rx, ss, i, toggle, fosc, Fs, runs, snr, freq_missmatch)

delta = 1;

fi_n   = atan2(imag(signal_rx), real(signal_rx));
theta_n = mod((fi_n(:, 2:end) - fi_n(:, 1:end-1)), 2*pi);

T1 = sum(abs(signal_rx).^2);    % Energy detection statistic

[xpdf_empirical, ypdf_empirical] = histo(theta_n, ss.nbins, i, toggle, fosc, Fs, runs, snr, delta, freq_missmatch);
thetai = xpdf_empirical;
T2 = sum(ypdf_empirical .* cos(2*pi*(1+freq_missmatch)*fosc/Fs - thetai) * 2*pi/ss.nbins);
end