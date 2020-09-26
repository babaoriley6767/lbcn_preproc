function ElecSelectivityAll(s, dirs, task, locktype, datatype, freq_band, cfg)

    % Get parameters
    if isempty(cfg)
        cfg = [];
        [cfg.column,cfg.conds] = getCondNames(task);
        cfg.stats_params = genStatsParams(task);
    else
    end
    
    load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
    fprintf('processing subject %s\n', s)
    block_names = BlockBySubj(s,task);
    try
        elect_select = ElectSelectivity(s, task, block_names, dirs, locktype, cfg.column, cfg.conds, datatype, freq_band, cfg.stats_params);
        el_selectivity = [subjVar.elinfo elect_select];
        fname = sprintf('%sel_selectivity/el_selectivity_%s_%s_%s.mat',dirs.result_dir, s, task, cfg.column);
        save(fname, 'el_selectivity');
    catch
        fname = sprintf('%sel_selectivity/%s_%s_error.csv',dirs.result_dir, task, s);
        csvwrite(fname, 's')
    end
end
