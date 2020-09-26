function OrganizeTrialInfoCalculia_EglyDriver(sbj_name, project_name, block_names, dirs)

for bi = 1:length(block_names)
    bn = block_names{bi};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'data*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]);
    
    
    fieldnames = K.full_data(1,:);
    trialinfo = table;
    for i = 1:length(fieldnames)
        trialinfo.(fieldnames{i}) = vertcat(K.full_data{2:end,i});
        
    end
    
    
    %% Save trialinfo
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    
end
end
