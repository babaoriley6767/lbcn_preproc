function OrganizeTrialInfoCalculia_production(sbj_name, project_name, block_names, dirs)

for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    
    RT = [K.theData(:).RT]';
    ntrials = K.nTrials;
    
    trialinfo = K.slist;
       
    allonset = nan(ntrials,3);
    for i = 1:ntrials
        for ii = 1:3
            allonset(i,ii)=K.theData(i).flip(ii).StimulusOnsetTime;
        end
    end
    trialinfo.StimulusOnsetTime = allonset;
    trialinfo.RT = RT;
    
    for i = 1:size(trialinfo,1)
        if trialinfo.operation(i) == 1
            trialinfo.condNames{i,1} = 'Addition';
        elseif trialinfo.operation(i) == -1
            trialinfo.condNames{i,1} = 'Subtraction';
        end
    end
    
    trialinfo.conds_calc = repmat({'calc'}, size(trialinfo,1),1);

   
       
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end

