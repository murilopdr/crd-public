% Generates N random modulated symbols from an M-point constellation.
% Optionally plots the constellation, time-domain signal, and frequency spectrum.
%
%   Inputs:
%       M                : modulation order (number of constellation points)
%       N                : number of symbols to generate
%       mod              : modulation type selector
%                            1 : M-PSK
%                            2 : M-QAM
%                            3 : M-ASK
%       i                : current Monte Carlo iteration index
%       runs             : total number of Monte Carlo runs
%       toggle_time_plot : if 1, enables plots at the first signal iteration
%
%   Output:
%       Simbolos : complex vector [1 x N] of normalized random symbols

function [Simbolos] = symbol_gen(M, N, mod, i, runs, toggle_time_plot)

% Build normalized constellation
if mod == 1         % M-PSK
    Vec_Simbol = pskmod(0:M-1, M);
elseif mod == 2     % M-QAM
    Vec_Simbol = qammod(0:M-1, M, 'UnitAveragePower', true);
else                % M-ASK
    Vec_Simbol = (0:M-1);
    Vec_Simbol = Vec_Simbol - mean(Vec_Simbol);
    Vec_Simbol = Vec_Simbol / sqrt(mean(abs(Vec_Simbol).^2));
end

% Normalize constellation energy
Energy   = (sum(real(Vec_Simbol).^2) + sum(imag(Vec_Simbol).^2)) / length(Vec_Simbol);
cte_norm = sqrt(Energy);
Vec_Simbol = Vec_Simbol / cte_norm;

% Generate N random symbols
Simbolos = Vec_Simbol(randi([1, length(Vec_Simbol)], 1, N));

% Plot constellation, time-domain signal, and frequency spectrum
if i == runs/2+1 && toggle_time_plot == 1
    figure(1);
    scatter(real(Vec_Simbol), imag(Vec_Simbol), 'filled');
    grid on;
    title('Constellation');
    xlabel('Real Part');
    ylabel('Imaginary Part');

    figure(2);
    subplot(2,1,1);
    plot(real(Vec_Simbol), '*--b');
    hold on;
    plot(imag(Vec_Simbol), '*--r');
    grid on;
    title('Time-Domain Signal');
    xlabel('Sample');
    ylabel('Amplitude');
    legend('Real Part', 'Imaginary Part');

    subplot(2,1,2);
    sinal_fft  = fft(Simbolos, 5000);
    frequencias = linspace(-2, 2, 5000);
    plot(frequencias, abs(fftshift(sinal_fft)));
    grid on;
    title('Signal Frequency Spectrum');
    xlabel('Normalized Frequency');
    ylabel('Magnitude');
end

end