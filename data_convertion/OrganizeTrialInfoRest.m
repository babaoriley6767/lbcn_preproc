function OrganizeTrialInfoRest(sbj_name, project_name, block_names, dirs)

for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    load(sprintf('%s/CARiEEG%s_%.2d.mat',globalVar.CARData,bn,1));

    x = 10;
    trialinfo = table;
    trialinfo.allonsets = [1:x:(size(data.wave,2)/data.fsample)-11]';
    trialinfo.condNames = repmat({'Rest'},size(trialinfo,1),1);
    
    % Save
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    
end

end