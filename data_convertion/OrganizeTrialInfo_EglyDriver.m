function OrganizeTrialInfo_EglyDriver(sbj_name, project_name, block_names, dirs)

for bi = 1:length(block_names)
    bn = block_names{bi};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'data*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]);
    
%     
%     fieldnames = K.full_data(1,:);
%     trialinfo = table;
%     for i = 1:length(fieldnames)
%         trialinfo.(fieldnames{i}) = vertcat(K.full_data{2:end,i});
%         
%     end
    
    trialinfo = K.slist;
    
    for i = 1:size(trialinfo.is_targ)
        if trialinfo.is_targ(i) == 1
            trialinfo.CondNames{i} = 'target_present';
        else
            trialinfo.CondNames{i} = 'target_absent';
        end
    end
    interval_tmp = discretize(trialinfo.int_cue_targ_time, 5);
    trialinfo.condNames_interval = cellstr(num2str(interval_tmp));
    
    %% Save trialinfo
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    
end
end
