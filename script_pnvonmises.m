clc; clear variables; close all;

caller = "pnvm";

script_time = tic;
kappa_vec = 0:1:20;
pfa_target = 0.1;
pd_vec = zeros(1,length(kappa_vec));
auc_vec = zeros(1,length(kappa_vec));

for k = 1:length(kappa_vec)
    kappa_value = kappa_vec(k);
    disp(['(', num2str(k), ' / ', num2str(length(kappa_vec)), ') kappa = ', num2str(kappa_value)]);
    main
    % [~, idx] = min(abs(Pfa - pfa_target));
    % pd_vec(k) = Pd(idx);
    
    [Pfa_u, ia] = unique(Pfa, 'stable');
    Pd_u = Pd(ia);

    pd_vec(k)  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');

    auc_vec(k) = AUC;
    remaining_time_sec = main_time_sec*(length(kappa_vec)-k);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';
    fprintf('Partial runtime: %s (remaining time = ~%s)\n\n', char(main_time_dur), char(remaining_time_dur));
end

plot(kappa_vec, auc_vec, 'b-*');
total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n\n', char(total_time));