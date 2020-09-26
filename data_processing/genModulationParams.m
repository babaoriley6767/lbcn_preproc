function mod_par = genModulationParams(project_name)

%% INPUTS:
%   project_name: task name
[column,conds] = getCondNames(project_name);

switch project_name
    case 'MMR'
        mod_par.task_win = [0 1];
        mod_par.bl_win = [-0.2 0];
        
        mod_par.tag = 'stim';
        
        mod_par.conds = conds;
        mod_par.column = column;
        mod_par.preds.(conds{find(strcmp(conds, 'math'))}) = {'OperandMin', 'OperandMin', 'initial', 'total'};
        mod_par.dep_vars.(conds{find(strcmp(conds, 'math'))}) = {'initial', 'total', 'RT', 'RT'};

    case 'Memoria'
        mod_par.task_win = [0 1.5];
        mod_par.bl_win = [-0.5 0];
    case 'GradCPT'
        mod_par.task_win = [0 0.8];
        mod_par.bl_win = [-0.2 0];
end

mod_par.nreps= 5000;
mod_par.freq_range = [70 180];
mod_par.paired = false;
mod_par.noise_method = 'trials';
mod_par.noise_fields_trials= {'bad_epochs_HFO','bad_epochs_raw_HFspike'}; % can combine any of the bad_epoch fields in data.trialinfo (will take union of selected fields)
mod_par.noise_fields_timepts= {'bad_inds_HFO','bad_inds_raw_HFspike'}; % can combine any of the bad_epoch fields in data.trialinfo (will take union of selected fields)
mod_par.alpha = 0.05;

mod_par.blc=1;
mod_par.smooth=1;
mod_par.fwer=0.05;
mod_par.tail=0;
mod_par.sm=0.1;
mod_par.twin=[-0.5 7];
mod_par.mincluster = 0.02;   %% define the minimum cluster threshold.
mod_par.isplot=1;




