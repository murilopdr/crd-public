% DETECTION_ED Computes the test statistic T for Energy Detection (ED).
% The statistic is the total received signal energy across all samples.
%
%   Input:
%       signal_rx : complex vector [1 x nsamples] of received signal samples
%
%   Output:
%       T : test statistic

function [T] = detection_ed(signal_rx)
    T = sum(abs(signal_rx).^2);
end
