clear variables; clc; close all; 



max_dist = 50;
dist_vec = 1:max_dist;
auc_vec = zeros(1,max_dist);

for d = 1:max_dist   
    disp(['d = ', num2str(d)]);
    main
    auc_vec(d) = AUC;
end

plot(dist_vec, auc_vec, '*-b')