clc; clear variables; close all;

caller = "elem_samples";
script_time = tic;

% Define the sets of element counts you want to compare
% Note: Using 10000 might take significant time depending on your 'main' script
n_targets = [30, 300, 3000, 30000, 50000]; 
pfa_target = 0.1;

% Pre-allocate a cell array or matrix to store results for each N
all_pd_results = cell(1, length(n_targets));
all_elem_vecs = cell(1, length(n_targets));

% Set up a color map for the final plot
colors = lines(length(n_targets));

for n_idx = 1:length(n_targets)
    sample_value = n_targets(n_idx);
    
    % Define the range of elements to test for this specific N
    % Adjust this vector if you want different steps for different N
    elem_vec = 0:20; 
    elem_vec = unique(elem_vec);
    
    pd_vec = zeros(1, length(elem_vec));
    auc_vec = zeros(1, length(elem_vec));
    
    fprintf('--- Starting Simulation for N = %d ---\n', sample_value);
    
    for k = 1:length(elem_vec)
        elem_value = elem_vec(k);
        fprintf('Batch %d/%d | Element %d/%d: %d elements\n', ...
                n_idx, length(n_targets), k, length(elem_vec), elem_value);
        
        % --- Your original core logic ---
        main 
        
        [Pfa_u, ia] = unique(Pfa, 'stable');
        Pd_u = Pd(ia);
        pd_vec(k)  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');
        auc_vec(k) = AUC;
        % -------------------------------
        
        % Progress Tracking
        remaining_time_sec = main_time_sec * (length(elem_vec) - k);
        fprintf('Est. time for this N: %s\n', char(seconds(remaining_time_sec)));
    end
    
    % Store results for this N batch
    all_pd_results{n_idx} = pd_vec;
    all_elem_vecs{n_idx} = elem_vec;
    
    % Save intermediate batch data
    save(sprintf('results_N_%d.mat', sample_value), 'elem_vec', 'pd_vec', 'auc_vec');
end

%% Final Multi-Curve Plot
figure('Color', 'w', 'Name', 'Pd vs Number of RIS Elements');
hold on;
legend_labels = cell(1, length(n_targets));

for n_idx = 1:length(n_targets)
    plot(all_elem_vecs{n_idx}, all_pd_results{n_idx}, ...
        '-*', 'Color', colors(n_idx, :), 'LineWidth', 1.6, 'MarkerSize', 6);
    legend_labels{n_idx} = ['N = ', num2str(n_targets(n_idx))];
end

xlabel('Number of RIS elements');
ylabel(['P_d (at P_{fa} = ', num2str(pfa_target), ')']);
title('Performance Comparison for Different Maximum Elements');
grid on;
legend(legend_labels, 'Location', 'best');
hold off;

% Finalize
savefig('multi_n_comparison.fig');
total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('\nDone! Total script runtime: %s\n', char(total_time));