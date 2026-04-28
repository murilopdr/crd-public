% Generates a single random sample from the von Mises distribution
% using the Best-Fisher algorithm.
%
%   Inputs:
%       mu    : mean direction (rad)
%       kappa : concentration parameter (kappa = 0 yields a uniform sample)
%
%   Output:
%       phi : random sample in (-pi, pi] from von Mises(mu, kappa)

function phi = randvonmises(mu, kappa)

if kappa == 0
    phi = 2*pi*rand - pi;
    return
end

a = 1 + sqrt(1 + 4*kappa^2);
b = (a - sqrt(2*a)) / (2*kappa);
r = (1 + b^2) / (2*b);

while true
    u = rand(3,1);
    z = cos(pi * u(1));
    f = (1 + r*z) / (r + z);
    c = kappa * (r - f);
    if u(2) < 1 + c*exp(1-c) || log(u(2)) <= c
        break
    end
end

phi = mu + sign(u(3)-0.5) * acos(f);
phi = mod(phi + pi, 2*pi) - pi;

end