clc; clear variables; close all;

caller = "snr";

tic
snr_vec = -25:1:5;
pfa_target = 0.1;
pd_vec = zeros(1,length(snr_vec));
auc_vec = zeros(1,length(snr_vec));

for k = 1:length(snr_vec)
    snr_value = snr_vec(k);
    disp(['SNR = ', num2str(snr_value)]);
    main
    [~, idx] = min(abs(Pfa - pfa_target));
    pd_vec(k) = Pd(idx);
    auc_vec(k) = AUC;
end

plot(snr_vec, pd_vec, 'b-*');
toc