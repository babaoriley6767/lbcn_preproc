function scores_cat = concat_enconding_scores_conds(scores,conditions)

subjects = fieldnames(scores);

for ic = 1:length(conditions)
    cond = conditions{ic};
    scores_cat.(cond) = [];
    for is = 1:length(subjects)
        s = scores.(subjects{is});
        scores_tmp = nanmean(s.scores_single_trials(:,strcmp(s.trialinfo.condNames, cond)),2);
        scores_cat.(cond) = [scores_cat.(cond); scores_tmp];
    end
    
end


end

