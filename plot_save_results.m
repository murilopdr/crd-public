% Saves simulation results to a .mat file and plots the ROC curve.https://www.mathworks.com/matlabcentral/fileexchange/26003-random-numbers-from-a-user-defined-distribution
%
%   Inputs:
%       filename : base name for the output file (without extension)
%       folder   : destination folder path (created if it does not exist)
%       Pd       : detection probability matrix [techniques x thresholds]
%       Pfa      : false alarm probability matrix [techniques x thresholds]
%       AUC      : area under the ROC curve
%       param    : struct with simulation parameters (saved alongside results)

function plot_save_results(filename, folder, Pd, Pfa, AUC, param)

% Save results
if ~exist(folder, 'dir')
    mkdir(folder);
end
filepath = fullfile(folder, [filename, '.mat']);
save(filepath, 'Pd', 'Pfa', 'AUC', 'param');

% Plot ROC curve
figure;
plot(Pfa(1,:), Pd(1,:), 'DisplayName', 'RCs Non Coop.', ...
    'Marker', 'square', 'LineWidth', 2, 'LineStyle', '--', 'Color', [1 0 1]);
xlabel('P_{FA}');
ylabel('P_{D}');
grid on;
axis([0 1 0 1]);
legend('show');

end