clc; clear variables; close all;

caller = "pngauss";

script_time = tic;
std_vec = linspace(0,1,6);
pfa_target = 0.1;
pd_vec = zeros(1,length(std_vec));
auc_vec = zeros(1,length(std_vec));

for k = 1:length(std_vec)
    std_value = std_vec(k);
    disp(['(', num2str(k), ' / ', num2str(length(std_vec)), ') std. dev. = ', num2str(std_value)]);
    main
    [~, idx] = min(abs(Pfa - pfa_target));
    pd_vec(k) = Pd(idx);
    auc_vec(k) = AUC;
    remaining_time_sec = main_time_sec*(length(std_vec)-k);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';
    fprintf('Partial runtime: %s (remaining time = ~%s)\n\n', char(main_time_dur), char(remaining_time_dur));
end

plot(std_vec, pd_vec, 'b-*');
%xlim([0 4]);
%xticks(0:pi/2:2*pi);
total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n\n', char(total_time));
