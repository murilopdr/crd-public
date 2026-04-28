clc; clear variables; close all;

caller = "pnquant";

tic
L_vec = 1:6;
pfa_target = 0.1;
pd_vec = zeros(1,length(L_vec));
auc_vec = zeros(1,length(L_vec));

for k = 1:length(L_vec)
    L_value = L_vec(k);
    disp(['# of quantization bits L = ', num2str(L_value)]);
    main
    [~, idx] = min(abs(Pfa - pfa_target));
    pd_vec(k) = Pd(idx);
    auc_vec(k) = AUC;
end

plot(L_vec, pd_vec, 'b-*');
toc