% PHASE NOISE Generates a single phase noise sample according to the selected distribution.
%
%   Input:
%       ch : struct with fields:
%              - ch.phase_noise_type : distribution selector
%                                        0 : no phase noise (psi = 0)
%                                        1 : Gaussian
%                                        2 : von Mises
%                                        3 : generalized uniform
%              - ch.g.std    : standard deviation (case 1)
%              - ch.vm.kappa : concentration parameter (case 2)
%              - ch.uni.q    : half-range factor, in [0,1] (case 3)
%
%   Output:
%       psi : phase noise sample (radians)

function psi = phase_noise(ch)

switch ch.phase_noise_type
    case 0      % No phase noise
        psi = 0;
    case 1      % Gaussian phase noise, wrapped to [-pi, pi)
        raw = ch.g.std * randn;
        psi = mod(raw + pi, 2*pi) - pi;
    case 2      % Von Mises phase noise
        psi = randvonmises(0, ch.vm.kappa);
    case 3      % Generalized uniform phase noise over [-q*pi, q*pi]
        psi = unifrnd(-ch.uni.q*pi, ch.uni.q*pi);
end

end