clc; clear variables; close all;
caller = "samples_elem";
script_time = tic;
samples_vec = [10 20 50 100 200 500 1000 2000 5000 10000];
% samples_vec = [2000];
elem_vec = [0, 1, 2, 4, 8, 10, 16, 20];
pfa_target = 0.1;
num_elems = length(elem_vec);
num_samples = length(samples_vec);
pd_results = zeros(num_elems, num_samples);
auc_results = zeros(num_elems, num_samples);
colors = lines(num_elems);
total_iters = num_elems * num_samples;
iter_count = 0;
for idx_e = 1:num_elems
    elem_value = elem_vec(idx_e);
    for idx_s = 1:num_samples
        iter_count = iter_count + 1;
        sample_value = samples_vec(idx_s);
        fprintf('(%d / %d) Elements: %d | Samples: %d\n', ...
            iter_count, total_iters, elem_value, sample_value);
        main;
        [Pfa_u, ia] = unique(Pfa, 'stable');
        Pd_u = Pd(ia);
        pd_results(idx_e, idx_s) = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');
        auc_results(idx_e, idx_s) = AUC;
        save('checkpoint_samples_elem.mat', 'pd_results', 'elem_vec', 'samples_vec');
        fig = figure('Visible','off');
        hold on; grid on;
        for r = 1:idx_e
            if r < idx_e
                semilogx(samples_vec, pd_results(r, :), '-*', 'LineWidth', 1.6, 'Color', colors(r,:));
            else
                semilogx(samples_vec(1:idx_s), pd_results(r, 1:idx_s), '-*', 'LineWidth', 1.6, 'Color', colors(r,:));
            end
        end
        xlabel('Number of Samples');
        ylabel('P_d');
        title(sprintf('Progress: %d%%', round(100*iter_count/total_iters)));
        saveas(fig, 'checkpoint_pd_vs_samples.png');
        close(fig);
        remaining_time_sec = main_time_sec * (total_iters - iter_count);
        remaining_time_dur = seconds(remaining_time_sec);
        remaining_time_dur.Format = 'hh:mm:ss';
        fprintf('Est. remaining: %s\n\n', char(remaining_time_dur));
    end
end
figure('Color', 'w');
hold on; grid on; box on;
for k = 1:num_elems
    semilogx(samples_vec, pd_results(k, :), '-*', 'LineWidth', 2, ...
        'Color', colors(k,:), ...
        'DisplayName', [num2str(elem_vec(k)) ' Elements']);
end
xlabel('Number of Samples');
ylabel(['P_d (@ P_{fa} = ' num2str(pfa_target) ')']);
legend('Location', 'best');
savefig('pd_vs_samples_final.fig');
fprintf('Total runtime: %s\n', char(seconds(toc(script_time))));