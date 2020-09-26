function [dep, pred] = getDepPred(data, datatype, el, dep, pred, conds, mod_par)

dep_pred = {dep,pred};
data_win = min(find(data.time>mod_par.task_win(1))):max(find(data.time<mod_par.task_win(2)));
trial_idx = find(strcmp(data.trialinfo.(mod_par.column), conds));

for i = 1:length(dep_pred)
    dep_pred_tmp = dep_pred{i};
    
    switch dep_pred_tmp
        case 'RT'
            dep_pred_tmp_final{i} = data.trialinfo.RT(trial_idx);
            
        case 'OperandMin'
            dep_pred_tmp_final{i} = data.trialinfo.OperandMin(trial_idx);
            
        case 'initial'
            % Average across conds
            data_field = 'wave';
            if strcmp(datatype, 'Band')
                dep_pred_tmp_final{i} = nanmean(data.(data_field)(trial_idx,el,data_win),3); % average time win by electrode
            else strcmp(datatype, 'Spec')
%                 dep_pred_tmp_final{i} = nanmedian(data_sbj.(data_field)(trial_idx,:,:,:),4); % average time win by electrode
            end
            
        case 'total'
            data_field = 'wave';
            for ii = 1:length(trial_idx)
                tmp = data.(data_field)(trial_idx(ii),el,data_win(1):max(find(data.time <= data.trialinfo.RT(trial_idx(ii)))));
                dep_pred_tmp_final{i}(ii,1) = trapz(tmp); 
                % Should I only take the positive values? 
                %  dep_pred_tmp_final{i}(ii) = trapz(tmp(tmp>0)); 
            end
    end
    
end
    % Define dep and pred
    dep = dep_pred_tmp_final{1};
    pred = dep_pred_tmp_final{2};    
    
end

