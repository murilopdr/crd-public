clear variables; clc; close all;

script_check = 1;
caller = "freq_error_var";

script_time = tic;

freq_error_var_vec = [0 5 10 16 20 30 50 100 200 300 400 600 800 1000 1200];
% freq_error_var_vec = 0:50:1200;

pfa_target = 0.1;
pd_vec  = zeros(1,length(freq_error_var_vec));
auc_vec = zeros(1,length(freq_error_var_vec));

figure; hold on;

for k = 1:length(freq_error_var_vec)

    freq_error_var = freq_error_var_vec(k);
    disp(['(', num2str(k), ' / ', num2str(length(freq_error_var_vec)), ') freq. error variance = ', num2str(freq_error_var)]);

    main

    [Pfa_u, ia] = unique(Pfa, 'stable');
    Pd_u = Pd(ia);
    pd_vec(k)  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');

    auc_vec(k) = AUC;

    remaining_time_sec = main_time_sec * (length(freq_error_var_vec) - k);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';

    fprintf('Partial runtime: %s\n\n', char(main_time_dur));

end

plot(freq_error_var_vec, pd_vec, 'b-*');

total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n\n', char(total_time));
