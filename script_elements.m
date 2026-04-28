clc; clear variables; close all;

caller = "elem";

script_time = tic;
elem_vec = 0:50;
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

    remaining_time_sec = main_time_sec*(length(elem_vec)-k);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';
    fprintf('Partial runtime: %s\n\n', char(main_time_dur));
end

plot(elem_vec, auc_vec, 'b-*');
total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n\n', char(total_time));