% Plots the empirical phase-difference PDF against the theoretical PDF.
% For the first iteration (noise only), the theoretical PDF is uniform.
% For signal iterations, the theoretical PDF includes a cosine modulation term.
%
%   Inputs:
%       xpdf_empirical : bin centers vector [1 x bins] (rad)
%       ypdf_empirical : empirical PDF values vector [1 x bins]
%       fosc           : carrier frequency (Hz)
%       Fs             : sampling frequency (Hz)
%       i              : current Monte Carlo iteration index
%                          1       : noise-only iteration
%                          other   : signal iteration
%       gamma          : SNR linear value, used in theoretical signal PDF
%       delta          : phase difference lag
%       freq_missmatch : carrier frequency offset (Hz)

function plot_pdf(xpdf_empirical, ypdf_empirical, fosc, Fs, i, gamma, delta, freq_missmatch)

figure
plot(xpdf_empirical, ypdf_empirical, 'b-', 'LineWidth', 1.5);
hold on;

theta = linspace(0, 2*pi, 1000);

if i == 1   % noise-only: uniform theoretical PDF
    y_theoretical = ones(size(theta)) / (2*pi);
    plot(theta, y_theoretical, 'r--', 'LineWidth', 1.5);
    legend('Empirical PDF', 'Theoretical PDF noise');
else        % signal present: cosine-modulated theoretical PDF
    zeta = (2*pi*(fosc+freq_missmatch)/Fs) - theta + (delta-1)*pi/2;
    theoretical_pdf = (1/(2*pi)) + (gamma/4 - gamma^2/8) * cos(zeta);
    plot(theta, theoretical_pdf, 'g-', 'LineWidth', 1.5);
    legend('Empirical PDF', 'Theoretical PDF signal');
end

xlim([0 2*pi]);
xticks(0:pi/2:2*pi);
xticklabels({'0', '\pi/2', '\pi', '3\pi/2', '2\pi'});
xlabel('Phase Difference (rad)');
ylabel('Probability Density');
grid on;
hold off;

end