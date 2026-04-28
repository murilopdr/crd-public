clc; clear variables; close all;
caller = "min_elem_search";
script_time = tic;

samples_vec  = [10:10:90, 100:100:900, 1000:1000:9000, 10000];
elem_max_vec = [15,11,15,14,13,12,12,11,11,10,9,8,7,7,7,6,5,5,6,5,5,5,4,4,4,4,4,4];                         
pfa_target   = 0;
pd_target    = 1;

num_samples = length(samples_vec);

min_elem_results = zeros(1, num_samples);
pd_at_min        = zeros(1, num_samples);

for idx_s = 1:num_samples
    sample_value = samples_vec(idx_s);

    if idx_s == 1
        elem_max = elem_max_vec(idx_s);
    else
        elem_max = min(elem_max_vec(idx_s), min_elem_results(idx_s - 1));
    end

    fprintf('=== N = %d | Starting from %d elements ===\n', sample_value, elem_max);

    min_elem   = elem_max;   % Fallback if nothing passes
    pd_current = NaN;

    for elem_value = elem_max : -1 : 0
        fprintf('  Testing Elements: %d | Samples: %d\n', elem_value, sample_value);
        main;
        [Pfa_u, ia] = unique(Pfa, 'stable');
        Pd_u        = Pd(ia);
        pd_current  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');
        fprintf('  Pd = %.4f (target = %.4f)\n', pd_current, pd_target);

        if pd_current >= pd_target
            min_elem = elem_value;   % Meets target, try fewer
            fprintf('  --> Meets target. Continuing down...\n');
        else
            fprintf('  --> Below target. Stopping.\n');
            break;
        end
    end

    min_elem_results(idx_s) = min_elem;
    pd_at_min(idx_s)        = pd_current;
    fprintf('  Minimum elements for N=%d: %d\n\n', sample_value, min_elem);

    save('checkpoint_min_elem.mat', 'min_elem_results', 'pd_at_min', 'samples_vec');
end

% --- Save Results Table ---
fid = fopen('min_elem_results_b3.txt', 'w');
fprintf(fid, '%-20s %-20s %-20s\n', 'N (Samples)', 'Min Elements', 'Pd Achieved');
fprintf(fid, '%s\n', repmat('-', 1, 60));
for idx_s = 1:num_samples
    fprintf(fid, '%-20d %-20d %-20.4f\n', samples_vec(idx_s), min_elem_results(idx_s), pd_at_min(idx_s));
end
fclose(fid);
fprintf('Results saved to min_elem_results_b3.txt\n');
fprintf('Total runtime: %s\n', char(seconds(toc(script_time))));