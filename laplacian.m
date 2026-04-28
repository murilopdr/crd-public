% LAPLACIAN Generates complex Laplacian noise samples.
%
% Each component (real and imaginary) is built as the difference of two
% independent Exponential random variables, scaled by sqrt(1/2).
%
%   Input:
%       b   : scale parameter of the underlying exponential distributions
%       n   : number of samples per realization
%       Nmc : number of realizations (i.e., Monte Carlo trials)
%
%   Output:
%       laplacian_noise : complex matrix [Nmc x n] of Laplacian noise samples

function laplacian_noise = laplacian(b,n,Nmc)

    laplacian_noise_real = random('exp',b,Nmc,n)-random('exp',b,Nmc,n);
    laplacian_noise_imag = random('exp',b,Nmc,n)-random('exp',b,Nmc,n);
    laplacian_noise = sqrt(1/2)*(laplacian_noise_real + 1i*laplacian_noise_imag);

end
