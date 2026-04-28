clear variables; clc; close all;

script_check = 1;
caller = "number_of_k";
script_time = tic;

% --- Parameter Setup ---
% Define the range for number_of_k
number_of_k_vec = [1:25 30 50 70 100]; 
pfa_target = 0.1;

% Initialize result vectors
pd_vec  = zeros(1,length(number_of_k_vec));
auc_vec = zeros(1,length(number_of_k_vec));

figure; hold on;

for k_idx = 1:length(number_of_k_vec)
    % Set the current parameter value for the 'main' script
    number_of_k = number_of_k_vec(k_idx);
    
    fprintf('(%d / %d) Variation: number_of_k = %d\n', ...
            k_idx, length(number_of_k_vec), number_of_k);
    
    % Call the simulation engine
    main 
    
    % Data processing: Ensure unique Pfa for interpolation
    [Pfa_u, ia] = unique(Pfa, 'stable');
    Pd_u = Pd(ia);
    
    % Interpolate Pd at the target Pfa
    pd_vec(k_idx)  = interp1(Pfa_u, Pd_u, pfa_target, 'linear', 'extrap');
    auc_vec(k_idx) = AUC;
    
    % Timing logic
    remaining_time_sec = main_time_sec * (length(number_of_k_vec) - k_idx);
    remaining_time_dur = seconds(remaining_time_sec);
    remaining_time_dur.Format = 'hh:mm:ss';
    
    fprintf('Partial runtime: %s | Estimated remaining: %s\n\n', ...
            char(main_time_dur), char(remaining_time_dur));
end

% --- Visualization ---
subplot(2,1,1);
plot(number_of_k_vec, pd_vec, 'b-o', 'LineWidth', 1.5);
grid on;
xlabel('Number of k');
ylabel(['Pd (at Pfa = ', num2str(pfa_target), ')']);
title('Detection Probability vs Number of k');

subplot(2,1,2);
plot(number_of_k_vec, auc_vec, 'r-s', 'LineWidth', 1.5);
grid on;
xlabel('Number of k');
ylabel('AUC');
title('Receiver Operating Characteristic AUC');

total_time = seconds(toc(script_time));
total_time.Format = 'hh:mm:ss';
fprintf('Total script runtime: %s\n', char(total_time));