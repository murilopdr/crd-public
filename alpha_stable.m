% ALPHA_STABLE Generates complex alpha-stable samples using the Chambers-Mallows-Stuck method.
% Real and imaginary parts are generated independently and scaled by sqrt(1/2).
% Handles the special case alpha = 1 (Cauchy) separately.
%
% Note that the so-called "zero-mean symetric-alpha-stable (S-alpha-S) noise" refers to the 
% specific case where beta = delta = 0.
%
%   Inputs:
%       alpha : stability index, in (0, 2]
%       beta  : skewness parameter, in [-1, 1]
%       c     : scale parameter (dispersion)
%       delta : location parameter (shift)
%       N     : number of samples per realization
%       Nmc   : number of realizations (i.e., Monte Carlo trials)
%
%   Output:
%       alpha_stable_samples : complex matrix [Nmc x N] of alpha-stable samples

function alpha_stable_samples = alpha_stable(alpha, beta, c, delta, N, Nmc)

% Generate independent alpha-stable samples for real part
U_real = pi * (rand(N, Nmc) - 0.5);
W_real = exprnd(1, N, Nmc);

if alpha ~= 1
    B = atan(beta * tan(pi * alpha / 2));
    S = (1 + beta^2 * (tan(pi * alpha / 2))^2)^(1/(2 * alpha));
    X_real = S .* sin(alpha * (U_real + B)) ./ (cos(U_real)).^(1/alpha) ...
        .* (cos(U_real - alpha * (U_real + B)) ./ W_real).^((1 - alpha)/alpha);
    alpha_stable_real = c * X_real + delta;
else
    X_real = (2/pi) * ((pi/2 + beta .* U_real) .* tan(U_real) ...
        - beta .* log((pi/2 .* W_real .* cos(U_real)) ./ (pi/2 + beta .* U_real)));
    alpha_stable_real = c * X_real + 2/pi*beta*c*log(c) + delta;
end

% Generate independent alpha-stable samples for imaginary part
U_imag = pi * (rand(N, Nmc) - 0.5);
W_imag = exprnd(1, N, Nmc);

if alpha ~= 1
    B = atan(beta * tan(pi * alpha / 2));
    S = (1 + beta^2 * (tan(pi * alpha / 2))^2)^(1/(2 * alpha));
    X_imag = S .* sin(alpha * (U_imag + B)) ./ (cos(U_imag)).^(1/alpha) ...
        .* (cos(U_imag - alpha * (U_imag + B)) ./ W_imag).^((1 - alpha)/alpha);
    alpha_stable_imag = c * X_imag + delta;
else
    X_imag = (2/pi) * ((pi/2 + beta .* U_imag) .* tan(U_imag) ...
        - beta .* log((pi/2 .* W_imag .* cos(U_imag)) ./ (pi/2 + beta .* U_imag)));
    alpha_stable_imag = c * X_imag + 2/pi*beta*c*log(c) + delta;
end

alpha_stable_samples = sqrt(1/2)*(alpha_stable_real + 1i * alpha_stable_imag).';

end
