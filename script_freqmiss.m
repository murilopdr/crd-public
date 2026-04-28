clear variables; clc; close all;

script_check = 1;
caller = "freq_miss";

script_time = tic;

delta_freq_vec = -2:0.1:2;
pfa_target = 0.1;

pd_vec  = zeros(1,length(delta_freq_vec));
auc_vec = zeros(1,length(delta_freq_vec));

figure; hold on;

for k = 1:length(delta_freq_vec)

    delta_freq = delta_freq_vec(k);
    disp(['(', num2str(k), ' / ', num2str(length(delta_freq_vec)), ') \Deltaf = ', num2str(delta_freq)]);

    main

    [Pfa_u, ia] = unique(Pfa, 'stable');
    Pd_u = Pd(ia);
    pd_vec(k)  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');

    auc_vec(k) = AUC;

    remaining_time_sec = main_time_sec * (length(delta_freq_vec) - k);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';

    fprintf('Partial runtime: %s\n\n', char(main_time_dur));

end

plot(delta_freq_vec, auc_vec, 'b-*');

total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n\n', char(total_time));
