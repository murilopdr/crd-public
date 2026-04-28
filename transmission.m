% Generates the transmitted signal according to the selected transmission type.
%
%   Inputs:
%       tx               : struct with fields:
%                            - tx.type          : transmission type
%                                                   0 : single-carrier (upsampled symbols)
%                                                   1 : OFDM
%                                                   2 : unmodulated (all-ones, upsampled)
%                            - tx.n_simb        : number of symbols
%                            - tx.sample_factor : upsampling factor K
%                            - tx.m             : modulation order
%                            - tx.mod           : modulation type (passed to symbol_gen)
%       toggle_timeplot  : if 1, enables time-domain plot for tx.type = 2
%       i                : current Monte Carlo iteration index
%       runs             : total number of Monte Carlo runs
%
%   Output:
%       Data_Mod : complex vector [1 x N] of the transmitted signal (N = n_simb * sample_factor)

function [Data_Mod] = transmission(tx, toggle_timeplot, i, runs)

N = tx.n_simb * tx.sample_factor;
K = tx.sample_factor;

if tx.type == 1         % OFDM
    Data_Mod = func_ofdm_gen(tx.m, N, tx.mod, i, runs, toggle_timeplot);

elseif tx.type == 0     % Single-carrier with upsampling
    Data     = symbol_gen(tx.m, tx.n_simb, tx.mod, i, runs, toggle_timeplot);
    Data_Kx  = zeros(1, K*tx.n_simb);
    for j = 1:K
        Data_Kx(j:K:end) = Data;
    end
    Data_Mod = Data_Kx;

else                    % Unmodulated: all-ones with upsampling
    Data    = ones(1, tx.n_simb);
    Data_Kx = zeros(1, K*tx.n_simb);
    for j = 1:K
        Data_Kx(j:K:end) = Data;
    end
    Data_Mod = Data_Kx;

    if i == 1 && toggle_timeplot == 1
        figure;
        plot(real(Data_Mod), 'b');
        hold on;
        plot(imag(Data_Mod), 'r');
        grid on;
        title('Time-Domain Signal');
        xlabel('Sample');
        ylabel('Amplitude');
        legend('Real Part', 'Imaginary Part');
    end
end
end