function param_validation(toggle, filename, folder, runs, th_points, param)

    %% --- TOGGLE VALIDATION ---
    toggleFields = {'timeplot','histogram','h0_h1_pdf'};
    for f = toggleFields
        val = toggle.(f{1});
        if ~ismember(val, [0,1])
            error('toggle.%s must be 0 (off) or 1 (on).', f{1});
        end
    end

    %% --- GENERAL NUMERIC PARAMETERS ---
    mustBePositiveInteger(runs, 'runs');
    mustBePositiveInteger(th_points, 'th_points');
    mustBePositiveInteger(param.ss.n, 'param.ss.n');
    mustBePositiveInteger(param.ss.nbins, 'param.ss.nbins');

    %% --- delta >= 1 ---
    if ~isscalar(param.ss.delta) || param.ss.delta < 1
        error('param.ss.delta must be >= 1.');
    end

    %% --- SPECTRUM SENSING TECHNIQUE ---
    validTech = 0:13;
    if ~ismember(param.ss.tech, validTech)
        error('param.ss.tech must be one of: %s', num2str(validTech));
    end

    %% --- CHANNEL PARAMETERS ---
    if ~ismember(param.ch.ris_toggle, [0,1])
        error('param.ch.ris_toggle must be 0 or 1.');
    end

    validChTypes = -1:6;
    if param.ch.ris_toggle == 1
        if ~ismember(param.ch.tx_ris, 0:6)
            error('When RIS is enabled, param.ch.tx_ris must be in [0–6].');
        end
        if ~ismember(param.ch.ris_rx, 0:6)
            error('When RIS is enabled, param.ch.ris_rx must be in [0–6].');
        end
        if ~ismember(param.ch.tx_rx, validChTypes)
            error('param.ch.tx_rx must be in [-1–6] when RIS is enabled.');
        end
    else
        if param.ch.tx_rx == -1
            error('When param.ch.ris_toggle = 0, param.ch.tx_rx cannot be -1.');
        end
        if ~ismember(param.ch.tx_rx, 0:6)
            error('param.ch.tx_rx must be in [0–6].');
        end
    end

    %% --- TRANSMISSION PARAMETERS ---
    mustBePositiveInteger(param.tx.sample_factor, 'param.tx.sample_factor');
    mustBePositiveInteger(param.tx.m, 'param.tx.m');

    if ~ismember(param.tx.type, [0,1,2])
        error('param.tx.type must be 0, 1, or 2.');
    end

    if ~ismember(param.tx.mod, [1,2,3])
        error('param.tx.mod must be 1, 2, or 3.');
    end

    if ~ismember(param.tx.mp, [0,1])
        error('param.tx.mp must be 0 or 1.');
    end

    %% --- a >= 0 ---
    if ~isscalar(param.tx.a) || param.tx.a <= 0
        error('param.tx.a must be >= 0.');
    end

    %% --- FILENAME AND FOLDER ---
    if ~ischar(filename) && ~isstring(filename)
        error('filename must be a string or char.');
    end
    if ~ischar(folder) && ~isstring(folder)
        error('folder must be a string or char.');
    end
end


%% --- Helper: Positive integer validator ---
function mustBePositiveInteger(val, name)
    if ~isscalar(val) || val <= 0 || mod(val,1) ~= 0
        error('%s must be a positive integer (got %g).', name, val);
    end
end
