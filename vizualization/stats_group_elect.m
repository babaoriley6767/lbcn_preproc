function STATS = stats_group_elect(data, time, task,cond_names, column, stats_params)

% Get stats parameters
if isempty(stats_params)
    stats_params = genStatsParams(task);
end

data_win = min(find(time>stats_params.task_win(1))):max(find(time<stats_params.task_win(2)));

stats_data = [];
for i = 1:length(data.wave)
    for ic = 1:length(cond_names)
        trials = find(strcmp(data.trialinfo_all{i}.(column), cond_names{ic}));
        stats_tmp = nanmean(data.wave{i}(trials,:));
        stats_data{ic}(i,1) = mean(stats_tmp(data_win));
    end
end


[H,P,CI,STATS] = ttest2(stats_data{1},stats_data{2}); STATS.H = H; STATS.P = P; STATS.CI = CI;
% try
%     STATS.P_perm = permutation_unpaired(stats_data{1}, stats_data{2}, stats_params.nreps);
%     sc1c2 = STATS;
% catch
%     STATS.P_perm = 999;
%     sc1c2 = STATS;
% end


end