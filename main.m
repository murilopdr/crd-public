check = dbstack;

if isscalar(check)
    close all;
    clear variables; clc;
    check = 1;
    caller = "standalone";
end
main_tic = tic;

% This is a fork of 'crdsimulation' (https://github.com/murilopdr/crdsimulation)
% GitHub repo of this project: https://github.com/murilopdr/crd-ris

% Descripition: this code generates the simulated and theoretical ROC curves for non-cooperative
% Phase Diference Distribution Spectrum Sensing

%% Simulation parameters

% Defines whether or not the plots are displayed
if isscalar(check)
    toggle.timeplot = 0;            % Toggles time-domain plots of PU signal exhibition
    toggle.histogram = 0;           % Toggles PD histogram exhibition
    toggle.h0_h1_pdf = 0;
else                                % Disables the exhibition when 'main.m' is called from a script
    toggle.timeplot = 0;
    toggle.histogram = 0;
    toggle.h0_h1_pdf = 0;
end

filename = 'crd_20db_n1000_1elem_quan_ferr0_b100';            % NO NEED TO PUT '.mat'.
folder = 'trashbin';                   % Folder in which the results are saved

runs = 20000;                       % Number of Monte Carlo events
th_points = 300;                    % Number of threshold points to generate of the ROC curves
param.snr_dB = -10;       % Mean SNR (dB)
snr = 10.^(param.snr_dB/10);        % SNR conversion to linear

% SS parameters
%param.ss.m = 1;                    % Number of Cognitive Radios (for cooperative, not implemented)
param.ss.n = 10000;                 % Numer of samples collected for each spectrum sensing period
param.ss.tech = 0;                 % Spectrum sensing Technique: (0) ED, (1) SRD, (2) CRD, (3) PDP-Var, (4) GED, (5) Hybrid ED/CRD,
% (6) Hybrid CRD delta, (7) CRD freq. estimation, from PD, (8) CRD comp. & blind, (9) Hybrid conv./comp, (10) CRD-abs.,
% (11) CRD freq. estimation, from signal_rx, (12) E-CRD, (13) E-CRD Gaussian
param.ss.nbins = 40;                % Number of bins to calculate PD-distribution
param.ss.delta = 1;                 % Sample spacing for calculating phase difference, example: a phase difference calculated between 4th–1st samples means a delta = 3
param.ss.number_of_k = 5; 
param.freq_est_method = 1;          % (1) periodogram, (2) welch, (3) mvdr, (4) music
param.ss.threshold = 0;             % Manualy defined threshold value (if only ROC curve is wanted, then this doesn't matter)

% Channel pararameters
param.ch.ris_toggle = 0;            % (0) Only Tx-Rx channel, no RIS; (1) RIS present
param.ch.elements = 4;              % Number of RIS reflective elements
param.ch.phase_noise_type = 3;      % Phase noise model: (0) No phase noise, (1) Gaussian, (2) Von Mises, (3) Quantization error
param.ch.g.std = 0;                 % ONLY GAUSSIAN: std. dev. of phase increment [rad/sample]
param.ch.vm.kappa = 0;              % ONLY VON MISES: concentration parameter
b = 1;                              % ONLY QUANTIZATION ERROR: Number of quantization bits
param.ch.uni.q = 2^(-b);
% Channel Types: (0) No-fading; (1) Rayleigh; (2) Rice; (3) Nakagami-m; (4) Alpha-Mu; (5) Kappa-Mu; (6) Eta-Mu
param.ch.tx_ris = 2;                % Channel model for Tx-RIS
param.ch.ris_rx = 2;                % Channel model for RIS-Rx
param.ch.tx_rx = 1;                % Channel model for the direct Tx-Rx channel, put (-1) for no direct path
% Fading model parameters
param.ch.Rice.kappa = 3;

param.ch.Naka.mu = 5;
param.ch.AlphaMu.alpha = 2;
param.ch.AlphaMu.mu = 3;
param.ch.KappaMu.kappa = 10;
param.ch.KappaMu.mu = 2;
param.ch.EtaMu.eta = 3;
param.ch.EtaMu.mu = 0.5;
param.ch.name = 'default';
param.ch.parameter = 100000;


% Transmission parameters
param.tx.sample_factor = 100;       % Sample factor fs/Rs
param.tx.n_simb = ceil(param.ss.n/param.tx.sample_factor);     % Number of transmitted symbols
param.tx.m = 2;                     % Number of symbols M of modulation for sigle and ofdm.
param.tx.interp = 1;                % Only for OFDM (fs = interp*fifftclock)
param.tx.type = 0;                  % Tx_Type: (0) SingleCarrier, (1) OFDM, (2) CW
param.tx.mod = 1;                   % Modulation, (1) M-PSK, (2) M-QAM, (3) M-ASK
param.tx.mp = 0;                    % Channel MP: (0) no MP, (1) Multipath
param.Rb = 1;                       % Bit rate
Rs = param.Rb/log2(param.tx.m);     % Symbol rate
fs = param.tx.sample_factor*Rs;     % Sample rate
param.tx.a = 4;                     % Fs/fc
param.tx.fc = fs/param.tx.a;        % Local oscilating frequency

% Practical problems
param.nu_dB = 3;                    % Noise uncertainty [dB] (the same for the whole set of samples)
nu = 10.^(param.nu_dB/10);          % Noise uncertainty
param.freq_error_var = 50;
param.freq_error_mean = 0;%fs*0.1;

% Impulsive noise
param.in.type = 1;                  % IN type: (0) None, (1) PLN, (2) Laplacian, (3) Alpha-Stable, (4) Sub-gaussian

% Poisson-log-normal                                    
param.in.pln.K = 5;                 % Impulsive-to-noise power ratio
param.in.pln.mu_Z = 500;            % Mean of the log-amplitude (dB) of each impulse
param.in.pln.sigma_Z = 7.5;         % Standard deviation of the log-amplitude (dB) of each impulse
param.in.pln.epsilon = 30;          % mean inter-arrival distance between impulses (exponential)

% Laplacian noise
param.in.lapl.b = 3;

% Alpha-stable noise % ERROR
param.in.as.alpha = 1.1;            % Stability parameter
param.in.as.c = 1;                  % Scale parameter

% Sub-gaussian
% ATENTION: 'alpha-SGNm-master' folder and subfolders must be in path
param.in.sg.alpha = 1.5;            % Stability parameter
param.in.sg.c = 1;                  % Scale parameter
shrimp = load('shrimp.mat');
param.in.sg.R_norm = shrimp.R_norm;
param.in.sg.R = param.in.sg.c^2 * param.in.sg.R_norm;   % Scaled covariance matrix

% Checks for any errors in the inserted parameters
param_validation(toggle, filename, folder, runs, th_points, param);

%% Variable overwriting
switch caller 
    case "snr"
        param.snr_dB = snr_value;
    case "pngauss"
        if param.ch.phase_noise_type == 1
            param.ch.g.std = std_value;
        else
            error("'main' was called from 'script_pngauss', which varies the std. deviation for " + ...
                "Gaussian phase noise, in order to run the simulation this way put " + ...
                "param.ch.phase_noise_type = 1");
        end
    case "pnvm"
        if param.ch.phase_noise_type == 2
            param.ch.vm.kappa = kappa_value;
        else
            error("'main' was called from 'script_pnvm', which varies the kappa value for " + ...
                "von Mises phase noise, in order to run the simulation this way put " + ...
                "param.ch.phase_noise_type = 2");
        end
    case "pnquant"
        if param.ch.phase_noise_type == 3
            q = L_value;
            param.ch.uni.q = 2^(-q);
        else
            error("'main' was called from 'script_pnquant', which varies number of quantization bits," + ...
                " in order to run the simulation this way put param.ch.phase_noise_type = 3");
        end
    case "elem"
        param.ch.elements = elem_value;
    case "freq_miss"
        param.freq_error = delta_freq;
    case "freq_error_var"
        param.freq_error_var = freq_error_var;
    case "number_of_k"
        param.ss.number_of_k = number_of_k;
    case {"samples_elem", "min_elem_search", "elem_samples"}
        if param.ch.ris_toggle == 1
            param.ss.n = sample_value;
            param.tx.n_simb = ceil(param.ss.n/param.tx.sample_factor);
            param.ch.elements = elem_value;
        else
            error("'main' was called from 'script_samples_elements', which requires param.ch.ris_toggle = 1");
        end
end

%% Initialization of arrays and variables
oldmsg = '';
T_H0 = zeros(1,runs/2);
T_H1 = zeros(1,runs/2);
T1_H0 = zeros(1,runs/2);
T2_H0 = zeros(1,runs/2);
T1_H1 = zeros(1,runs/2);
T2_H1 = zeros(1,runs/2);
Pfa = zeros(1,th_points);
Pd = zeros(1,th_points);
impulsive_noise = zeros(1,param.ss.n);
save_signal_rx = zeros(runs,param.ss.n);
freq_error = zeros(1,runs);
switch param.in.type
    case 2
        impulsive_noise_matrix = laplacian(param.in.lapl.b, param.ss.n, runs);
    case 3
        impulsive_noise_matrix = alpha_stable(param.in.as.alpha, 0, param.in.as.c, 0, param.ss.n, runs);
end

%% Loop of MC events
for i = 1 : runs
    pct = floor(100 * i / runs);
    msg = sprintf('Event: %d / %d (%d%%)', i, runs, pct);
    fprintf(repmat('\b', 1, length(oldmsg)));
    fprintf('%s', msg);
    oldmsg = msg;
    
    H = 0;
    signal_tx = zeros(1,param.ss.n);            % Initialize the signal vector as empty, under H_0 it will stay as such

    thermal_noise = sqrt(unifrnd(1/nu,nu)) ...  % Generates unitary complex gaussian noise
        * (1/sqrt(2)*randn(1,param.ss.n) + 1i*1/sqrt(2)*randn(1,param.ss.n));
    power_tn = var(thermal_noise);              % Checks for the noise power

    if i > runs/2                               % Under H_1 Tx signal is generated
        signal_tx = transmission(param.tx,toggle.timeplot,i,runs);        % Generate Tx signal, OFDM or single carrier
        signal_tx = signal_tx(1:param.ss.n);    % Clips the data vector into the number of samples
        power_signal_norm = var(signal_tx);     % Verifies if the signal has unitary power
        signal_tx = sqrt(snr)*signal_tx;        % Adjusts the signal power according to the desired SNR
        power_signal = var(signal_tx);          % Verifies if the signal average power at Rx
        len = 0:length(signal_tx)-1;
        signal_tx = signal_tx .* exp(1j*2*pi*param.tx.fc*len/fs);

        if param.ch.ris_toggle == 0                 % No RIS, only Direct Tx-Rx Channel
            H = fading(param.ch.tx_rx-1, 1, param.ch.Rice.kappa);
        else                                        % RIS enabled
            H_ris = 0; H0 = 0;
            for l = 1:param.ch.elements
                H1 = fading(param.ch.tx_ris-1, 1, param.ch.Rice.kappa);   % Tx-RIS
                H2 = fading(param.ch.ris_rx-1, 1, param.ch.Rice.kappa);   % RIS-Rx
                
                if param.ch.inst_csi == 1
                    theta_opt = -(angle(H1) + angle(H2));
                else
                    K = param.ch.Rice.kappa;
                    phi1_LOS = 2*pi*(l-1)*param.ch.delta;
                    phi2_LOS = 2*pi*(l-1)*param.ch.delta;
                    H1_mean = sqrt(K/(K+1)) * exp(1j*phi1_LOS);
                    H2_mean = sqrt(K/(K+1)) * exp(1j*phi2_LOS);
                    theta_opt = -(angle(H1_mean) + angle(H2_mean));
                end

                phi = phase_noise(param.ch);
                theta = theta_opt + phi;
                H_ris = H1 * H2 * exp(1j*theta) + H_ris;          % Cascaded channel
            end
            if param.ch.tx_rx ~= -1                 % Direct link also present
                H0 = fading(param.ch.tx_rx, 1, param.ch.Rice.kappa);
            end
            H = H0 + H_ris;
        end
    end

    switch param.in.type
        case 1
            impulsive_noise = poisson_lognormal(param.ss.n, param.in.pln.K, param.in.pln.mu_Z, ...
                param.in.pln.sigma_Z, param.in.pln.epsilon);
        case 2
            impulsive_noise = impulsive_noise_matrix(i,:);
        case 3
            impulsive_noise = impulsive_noise_matrix(i,:);
        case 4
            noise_samples = asgn(param.in.sg.alpha, param.in.sg.R, 2*param.ss.n);
            impulsive_noise = sqrt(1/2)*(noise_samples(1:param.ss.n) + 1i*noise_samples(param.ss.n+1:2*param.ss.n));
    end

    signal_rx = H * signal_tx + thermal_noise + impulsive_noise;

    freq_error = randn*param.freq_error_var + param.freq_error_mean;
    param.freq_error = freq_error;

    % Detection
    if param.ss.tech == 5 % Hybrid detection
        [T1,T2] = detection_hyb(signal_rx, i, toggle.histogram, param.tx.fc, fs, runs, snr, param.freq_error);
        if i<= runs/2
            T1_H0(i)  = T1;
            T2_H0(i) = T2;
        else
            T1_H1(i - runs/2)  = T1;
            T2_H1(i - runs/2) = T2;
        end
    else
        if param.ss.tech == 0                   % Energy detection
            T = detection_ed(signal_rx);
        elseif param.ss.tech == 8
            [T, freq_error(i)] = detection_ferr(signal_rx, param.ss, i, toggle.histogram, param.tx.fc, fs, runs, snr, param.freq_error);
        elseif param.ss.tech == 11
            fc_est = estimate_freq(signal_rx, fs, param.freq_est_method);
            freq_error(i) = param.tx.fc - fc_est;
            param.ss.tech = 2;
            T = detection_pd(signal_rx, param.ss, i, toggle.histogram, fc_est, fs, runs, snr, param.freq_error);
            param.ss.tech = 11;
        else                                    % PD-based detection
            T = detection_pd(signal_rx, param.ss, i, toggle.histogram, param.tx.fc, fs, runs, snr, 0, 0);
        end
        if i <= runs/2; T_H0(i) = T;            % Hypotesis H0
        else; T_H1(i-runs/2) = T; end           % Hypotesis H1
    end
end
fprintf('\n')

if param.ss.tech == 5 || param.ss.tech == 6 || param.ss.tech == 9
    total_range1 = max(max(T1_H1))-min(min(T1_H0));
    total_range2 = max(max(T2_H1))-min(min(T2_H0));
    threshold1 = linspace(min(T1_H0)-0.05*range(T1_H0), max(T1_H1)+0.05*total_range1, th_points);
    threshold2 = linspace(min(T2_H0)-0.05*range(T2_H0), max(T2_H1)+0.05*total_range2, th_points);
else
    total_range = max(max(T_H1))-min(min(T_H0));
    threshold = linspace((min(min(T_H0)))-0.05*total_range, (max(max(T_H1))+0.05*total_range),th_points);
end

for w = 1:th_points
    if param.ss.tech == 5 || param.ss.tech == 6 || param.ss.tech == 9
        Pfa(w) = sum((T1_H0 > threshold1(w)) & (T2_H0 > threshold2(w)), 'all') / length(T1_H0);
        Pd(w)  = sum((T1_H1 > threshold1(w)) & (T2_H1 > threshold2(w)), 'all') / length(T1_H1);
    else
        Pfa(w) = sum((T_H0>threshold(w)).')/length(T_H0);
        Pd(w) = sum((T_H1>threshold(w)).')/length(T_H1);
    end
end

if toggle.h0_h1_pdf == 1 && ~(param.ss.tech == 5 || param.ss.tech == 6 || param.ss.tech == 9 || param.ss.tech == 11)
    figure;
    hold on; grid on;
    % Flatten to 1-D vectors
    H0 = T_H0(:);
    H1 = T_H1(:);
    % Plot histograms (normalized)
    histogram(H0, 'Normalization', 'pdf', 'FaceAlpha', 0.5);
    histogram(H1, 'Normalization', 'pdf', 'FaceAlpha', 0.5);
    xlabel('Test statistic T');
    ylabel('PDF estimate');
    legend('H0','H1');
    title('Empirical distribution of H0 and H1');
    hold off;
end

AUC = abs(trapz(Pfa,Pd)); disp(['AUC = ', num2str(AUC)]);   % AUC calculation
if isscalar(check); plot_save_results(filename, folder, Pd, Pfa, AUC, param); end

%freq_error_mean_H0 = mean(freq_error(1:runs/2));
%freq_error_mean_H1 = mean(freq_error(runs/2:runs));

%save('rx_signal.mat', 'save_signal_rx');

main_time_sec = toc(main_tic);
main_time_dur = seconds(main_time_sec);
main_time_dur.Format = 'hh:mm:ss';
if caller == "standalone"
    fprintf('Runtime: %s\n', char(main_time_dur));
end
