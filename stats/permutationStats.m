function [p,greater] = permutationStats(data,column,conds,stats_params)

% This function takes in a data structure (trials x time) for a single
% channel and compares either two conditions (if conds has two elements) or
% a single condition vs. baseline (if conds has a single element)

%% INPUTS:
%       data:           data structure
%       column:         column name of data.trialinfo where conds are found
%       conds:          cell containing cond name(s) (1 or 2) to compare
%       stats_params:   .task_win:   2-element vector specifying window of time to use in stats (in sec)    
%                       .bl_win:     2-element vector specifying window to use for baseline (in sec)- only relevent when 1 condition
%                       .paired:     true or false: 
%                                    when comparing two conditions, can only do unpaired test (i.e. false)
%                                    when comparing one condition to baseline, can do paired or unpaired test 
%                                    (for paired, will only use baseline periods just prior to trials of interest; 
%                                    for unpaired, will use baseline periods from all trials)    
%                       .nreps:      # of reps for permutation: default = 10000
%                       .noise_method:   'trials' or 'timepts': how to eliminate trials
%                       .freq_range:    2-element vector specifying freq range to use for stats 
%                                       (for spectral data only)

%% OUTPUTS
%   p: p-value
%   greater: 1 if dataA > dataB; 2 if dataB > dataA
%%

if ndims(data.wave)== 3 %if spectral data, average across frequencies of interest
    freq_inds = find(data.freqs >= stats_params.freq_range(1) & data.freqs <= stats_params.freq_range(2));
    data.wave = squeeze(nanmean(data.wave(freq_inds,:,:)));
end

[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],true);

[grouped_trials,~] = groupConds(conds,data.trialinfo,column,stats_params.noise_method,stats_params.noise_fields_trials,false);

if strcmp(stats_params.noise_method,'timepts') % eliminate noisy timepts but not entire trials
    ntrials = size(data.trialinfo,1);
    for ti = 1:ntrials
        data.wave(ti,find(data.trialinfo.bad_inds{ti}))=NaN;
    end
end
    
task_inds = find(data.time >= stats_params.task_win(1) & data.time <= stats_params.task_win(2));
bl_inds = find(data.time >= stats_params.bl_win(1) & data.time <= stats_params.bl_win(2));

% trials = cell(1,length(conds));
% for ci = 1:length(conds)
%     trials{ci}= find(strcmp(data.trialinfo.(column),conds{ci}));
% end

dataA = nanmean(data.wave(grouped_trials{1},task_inds),2); % average across timepts within each trial
if length(conds)==1 % comparing one condition vs. baseline
    if stats_params.paired
        dataB = nanmean(data.wave(grouped_trials{1},bl_inds),2);
        p = permutation_paired(dataA,dataB,stats_params.nreps);
    else
        dataB = nanmean(data.wave(grouped_trials_all{1},bl_inds),2);
        p = permutation_unpaired(dataA,dataB,stats_params.nreps);
    end
else  % comparing two conditions
    dataB = nanmean(data.wave(grouped_trials{2},task_inds),2);
    p = permutation_unpaired(dataA,dataB,stats_params.nreps);
end

if nanmean(dataA(:))>nanmean(dataB(:))
    greater = 1;
else
    greater = 2;
end


