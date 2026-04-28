% FADING Generates complex fading channel samples and the corresponding envelope PDF.
%
%   Inputs:
%       fading_type  : fading model selector
%                        -1 : no fading (AWGN), returns unit gains
%                         0 : Rayleigh fading
%                         1 : Rician fading
%       nsamples     : number of channel samples to generate; if 1 that means slow varying channel
%       CannelParam  : Rician K-factor
%
%   Outputs:
%       x  : complex vector [1 x nsamples] of fading channel coefficients
%       r  : envelope grid [1 x 1001] over [0, 10] used to evaluate the PDF
%       fr : envelope PDF evaluated over r (empty for fading_type = -1)

function [x, r, fr] = fading(fading_type, nsamples, K)

% Envelope sampling grid
r = 0:0.01:10;
switch fading_type
    case -1
        x  = ones(1, nsamples);
        fr = [];
        return
    case 0
        p  = 1;                                         % default normalization
        fr = (2*r/p) .* exp(-(r/p).^2);                 % Rayleigh PDF
        A  = randpdf(fr, r, [1 nsamples]);              % envelope samples
        phi = 2*pi*rand(1, nsamples);                   % random phase
        x  = A .* exp(1j*phi);                          % complex fading coefficients
    case 1
        rc = 1;
        fr = (2*(K+1)/rc) .* r .* exp(-(K+(K+1)*(r/rc).^2)) ...
            .* besseli(0, 2*sqrt(K*(K+1)) .* (r/rc));   % Rice PDF
        A  = randpdf(fr, r, [1 nsamples]);              % envelope samples
        phi_scatter = 2*pi*rand(1, nsamples);           % scattered component phase
        phi_LOS     = 2*pi*randn;                       % LOS component phase
        x  = sqrt(K/(K+1))*exp(1j*phi_LOS) ...
            + sqrt(1/(K+1))*A.*exp(1j*phi_scatter);     % complex Rician coefficients
    otherwise
        error('fading_type must be -1, 0, or 1.')
end

end