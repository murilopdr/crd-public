  clc; clear variables; close all;

caller = "elem";

script_time = tic;
% elem_vec = round(logspace( log10(1), log10(100), 15));
% elem_vec(elem_vec < 0) = 0;
% elem_vec = unique(elem_vec);
elem_vec = 0:30;
pfa_target = 0.1;
pd_vec = zeros(1,length(elem_vec));
auc_vec = zeros(1,length(elem_vec));

for k = 1:length(elem_vec)
    elem_value = elem_vec(k);
    disp(['(', num2str(k), ' / ', num2str(length(elem_vec)), ') # of elements = ', num2str(elem_value)]);

    main

    [Pfa_u, ia] = unique(Pfa, 'stable');
    Pd_u = Pd(ia);
    pd_vec(k)  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');
    auc_vec(k) = AUC;

    % Save checkpoint data (overwrite)
    save('checkpoint_elem.mat', ...
        'k', 'elem_value', 'elem_vec', ...
        'pd_vec', 'auc_vec');

    % Save checkpoint figure (overwrite)
    fig = figure('Visible','off');
    plot(elem_vec(1:k), pd_vec(1:k), 'b-*', 'LineWidth', 1.6)
    xlabel('Number of RIS elements')
    ylabel('P_d')
    grid on
    title(sprintf('Progress: k = %d of %d', k, length(elem_vec)))
    savefig(fig, 'checkpoint_pd_vs_elements.fig');
    saveas(fig, 'checkpoint_pd_vs_elements.png');
    close(fig)

    remaining_time_sec = main_time_sec*(length(elem_vec)-k);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';
    fprintf('Partial runtime: %s\n\n', char(main_time_dur));
end

% Final plot
figure;
plot(elem_vec, pd_vec, 'b-*', 'LineWidth', 1.6)
xlabel('Number of RIS elements')
ylabel('P_d')
grid on
savefig('pd_vs_elements.fig');
save('pd_vs_elements.mat', 'elem_vec', 'pd_vec', 'auc_vec');

total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n\n', char(total_time));
