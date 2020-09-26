function [grouped_trials,grouped_condnames] = groupConds(conds,trialinfo,column,noise_method,noise_fields,groupall)
% This function returns the trial numbers associated with particular
% conditions or sets of conditions.
%% INPUTS:
%   conds: cell of conditions (can be cell of cells if grouping conditions
%          together)
%   trialinfo:   trialinfo table (field of data)
%   column: column name of data.trialinfo containing the condition names in conds
%   noise_method: 'trials','timepts', or 'none' (how to eliminate bad epochs)
%   noise_fields: if eliminating bad trials, select which fields of
%           data.trialinfo to use  (e.g. {'bad_epochs'} or
%           {'bad_epochs_HFO','bad_inds_raw_HFspike'})
%   groupall:    true or false (if true, will group all of the conditions in
%           conds together; useful for plotting multiple elecs on same
%           plot)
%% OUTPUTS:
%   grouped_trials: cell containing trial indeces (in trialinfo) corresponding to each
%                   cond (or group of conds)
%   grouped_condnames:  condition names (will concatenate cond names if
%                       grouping multiple conds together)

if isempty(noise_fields) && strcmp(noise_method,'trials')
    noise_fields = {'bad_epochs'};
end

if (groupall)
    nconds = 1;
else
    nconds = length(conds);
end

% if eliminating bad trials, use the selected noise rejection algorithms
% (in noise_fields)
if strcmp(noise_method,'trials')
    bad_trials = [];
    for i = 1:length(noise_fields)
        bad_trials = union(bad_trials,find(trialinfo.(noise_fields{i})));
    end
end

grouped_trials = cell(1,nconds);
for ci = 1:nconds
    trials1 = find(~cellfun(@isempty,trialinfo.(column)));
    if groupall
        trials2 = find(ismember(trialinfo.(column)(trials1),conds));
    else
        trials2 = find(ismember(trialinfo.(column)(trials1),conds{ci}));
    end
    if strcmp(noise_method, 'trials')
        trials2 = setdiff(trials2,bad_trials);
    end
    grouped_trials{ci} = trials1(trials2);
end
grouped_condnames = groupCondNames(conds,groupall);