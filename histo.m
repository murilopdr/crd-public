% HISTO Computes the normalized empirical PDF of the input data using a histogram.
% Optionally plots the PDF at the first noise-only and first signal runs.
%
%   Inputs:
%       data          : vector of input samples to compute the histogram from
%       bins          : number of histogram bins
%       i             : current Monte Carlo iteration index
%       toggle        : if 1, enables PDF plotting at selected iterations
%       fosc          : carrier frequency (Hz), passed to plot_pdf
%       Fs            : sampling frequency (Hz), passed to plot_pdf
%       runs          : total number of Monte Carlo runs
%       snr           : signal-to-noise ratio (dB), passed to plot_pdf
%       delta         : spacing between samples to calculate the phase difference
%       freq_missmatch: carrier frequency offset (Hz), passed to plot_pdf
%
%   Outputs:
%       xo : bin centers vector [1 x bins]
%       yo : normalized PDF values vector [1 x bins] (unit area)

function [xo, yo] = histo(data, bins, i, toggle, fosc, Fs, runs, snr, delta, freq_missmatch)

[n, xout] = hist(data, bins);
n = n ./ sum(n) ./ (xout(2) - xout(1));    % normalize to unit area
xo = xout;
yo = n;

if toggle == 1
    if i == 1
        plot_pdf(xo, yo, fosc, Fs, i, snr, delta, freq_missmatch);
        title('PDF of Phase Difference (only noise)')
    elseif i == runs/2 + 1
        plot_pdf(xo, yo, fosc, Fs, i, snr, delta, freq_missmatch);
        title('PDF of Phase Difference (PU signal)')
    end
end

end