function [s_beh, good_beh] = CheckBehavioralPerformance(task,trialinfo)

% Standardize some variable names
if sum(contains(trialinfo.Properties.VariableNames, 'accuracy')) > 0
    trialinfo.Properties.VariableNames{contains(trialinfo.Properties.VariableNames, 'accuracy')} = 'Accuracy';
else
end

switch task
    case {'MMR', 'UCLA', 'MFA', 'Memoria', 'Calculia', 'Context', 'VTCLoc'}
        ti = trialinfo(~contains(trialinfo.condNames, 'rest'),:);
        conds = unique(ti.condNames);
        s_beh = table;
        s_beh.conds = conds;
        
        for ic = 1:length(conds)
            ti_tmp = ti(contains(ti.condNames, conds{ic}),:);
            s_beh.n_trials(ic,1) = size(ti_tmp,1);
            s_beh.valid_trials(ic,1) = sum(ti_tmp.RT>0.1 & ti_tmp.RT<10);
            s_beh.perc_valid_trials(ic,1) = s_beh.valid_trials(ic,1)/s_beh.n_trials(ic);
            ti_tmp_val = ti_tmp(ti_tmp.RT>0.1 & ti_tmp.RT<10,:);
            s_beh.correct_trials(ic,1) = sum(ti_tmp_val.Accuracy);
            s_beh.perc_correct_trials(ic,1) =  s_beh.correct_trials(ic,1)/s_beh.valid_trials(ic,1);
            RT_summary = [min(ti_tmp_val.RT) max(ti_tmp_val.RT) mean(ti_tmp_val.RT) median(ti_tmp_val.RT) std(ti_tmp_val.RT)];
            s_beh.RT_summary(ic,:)= RT_summary;
        end
        
        if contains(task, {'MMR', 'UCLA', 'Memoria'})
            if sum(s_beh.valid_trials>.25) == length(conds) && s_beh.perc_correct_trials(find(contains(conds, 'math'))) > .6
                good_beh =  1;
            else
                good_beh =  0;
            end
            
        elseif contains(task, {'MFA', 'Calculia'})
            if sum(s_beh.valid_trials>.25) == length(conds) && sum(s_beh.perc_correct_trials>.6) == length(conds)
                good_beh =  1;
            else
                good_beh =  0;
            end
        elseif contains(task, {'Context'})
            if sum(s_beh.valid_trials)/sum(s_beh.n_trials)>.25 && sum(s_beh.correct_trials)/sum(s_beh.valid_trials)>.6
                good_beh =  1;
            else
                good_beh =  0;                
        end
end

end



