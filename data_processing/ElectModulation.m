function reg_stats = ElectModulation(sbj_name,project_name, block_names, dirs, datatype, freq_band, mod_par)

% Get stats parameters
if isempty(mod_par)
    mod_par = genModulationParams(project_name);
end

% Concatenate all trials all channels
cfg = [];
cfg.decimate = false;
concat_params = genConcatParams(project_name, cfg);
data_sbj = ConcatenateAll(sbj_name,project_name,block_names,dirs,[],datatype,freq_band,mod_par.tag, concat_params);

% Run regression across fields - 1 predictor!
conds = mod_par.conds;
reg_stats = [];
for ii = 1%:length(mod_par.preds.(conds{i}))
    for imod = 1:length(mod_par.dep_vars.(conds{ii}))
        for el = 1:length(data_sbj.trialinfo_all)
            dep_n = mod_par.dep_vars.(conds{ii}){imod};
            pred_n = mod_par.preds.(conds{ii}){imod};
            [dep_var, pred] = getDepPred(data_sbj, datatype, el, dep_n, pred_n, conds{ii}, mod_par);
            % zscore variables to get standardized coef
            dep_var = zscore(dep_var);
            pred = zscore(pred);
            try
                regstats_tmp = regstats(dep_var,pred, 'linear', 'all');
                reg_stats.(conds{ii}).([dep_n '_' pred_n]).all{el} = regstats_tmp;
                reg_stats.(conds{ii}).([dep_n '_' pred_n]).betas(el,1) = regstats_tmp.beta(2);
                reg_stats.(conds{ii}).([dep_n '_' pred_n]).pvals(el,1) = regstats_tmp.fstat.pval;
            catch
                reg_stats.(conds{ii}).([dep_n '_' pred_n]).all{el} = {};
                reg_stats.(conds{ii}).([dep_n '_' pred_n]).betas(el,1) = nan;
                reg_stats.(conds{ii}).([dep_n '_' pred_n]).pvals(el,1) = nan;
            end
        end
        reg_stats.(conds{ii}).([dep_n '_' pred_n]).pvalsFDR = mafdr(reg_stats.(conds{ii}).([dep_n '_' pred_n]).pvals, 'bhfdr', true);
    end
end

end

