% POISSON_LOGNORMAL Generates complex Poisson-Lognormal (PLN) impulsive noise samples.
% Impulsive events arrive at positions drawn from an exponential inter-arrival
% distribution. Each event has a lognormal amplitude and uniform random phase.
%
%   Inputs:
%       n       : number of samples
%       K       : impulsive-to-noise power ratio
%       mu_Z    : mean of the log-amplitude (dB) of each impulse
%       sigma_Z : standard deviation of the log-amplitude (dB) of each impulse
%       epsilon : mean inter-arrival distance between impulses (exponential)
%
%   Output:
%       pln_noise : complex vector [1 x n] of PLN impulsive noise samples

function pln_noise = poisson_lognormal(n, K, mu_Z, sigma_Z, epsilon)

Sigma_i = sqrt(K);
N = zeros(1, n) + 1i * zeros(1, n);

% First impulse position, drawn from exponential inter-arrival
position_imp_noise = round(exprnd(epsilon));
for i = 1 : n
    if i == position_imp_noise
        % Lognormal amplitude from log-amplitude X ~ N(A, B^2)
        X = mu_Z + sigma_Z * randn(1);
        x = 10 .^ (X / 20);

        % Uniform random phase in [0, 2*pi]
        theta = unifrnd(0, 2*pi);

        % Complex impulsive sample (in-phase + quadrature)
        N(1, i) = x .* cos(theta) + 1i * x .* sin(theta);

        % Next impulse position
        position_imp_noise = i + round(exprnd(epsilon));
    end
end

% Power of impulsive noise
P = 1/n * sum(abs(N).^2);

if P == 0
    pln_noise = N * 0;
else
    % Normalize and apply power ratio K
    pln_noise = N / sqrt(P) * Sigma_i;
end

end