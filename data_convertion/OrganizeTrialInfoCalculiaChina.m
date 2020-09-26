function OrganizeTrialInfoCalculiaChina(sbj_name, project_name, block_names, dirs)

for bi = 1:length(block_names)
    bn = block_names{bi};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    
    RT = [K.theData(:).RT]';
    ntrials = K.nTrials;
    
    trialinfo = K.slist;
    if ~isfield(trialinfo,  'operator')
        trialinfo.operator = trialinfo.operator_inv.*-1;
    else
    end
    
    keys = trialinfo.keys;
    trialinfo.keys = trialinfo.correct;
    for ii = 1:length(keys)
        if ~strcmp(keys{ii}, 'noanswer')
            if strcmp(keys{ii}, 'n')
                keys{ii} = '1';
            elseif  strcmp(keys{ii}, 'm')
                keys{ii} = '2';
            end
        else
        end
        
        key = str2num(keys{ii}(1));
        
        if ~isempty(key)
            trialinfo.keys(ii) = key;
        else
            trialinfo.keys(ii) = NaN;
        end
    end
    
    % Accurracy
    for i = 1:length(trialinfo.keys)
        if (trialinfo.keys(i) == 1 && trialinfo.correct(i) == 1) || (trialinfo.keys(1) == 2 && trialinfo.correct(i) == 0)
            trialinfo.Accuracy(i) = 1;
        else
            trialinfo.Accuracy(i) = 0;
        end
    end
    
    allonset = nan(ntrials,5);
    for i = 1:ntrials
        for ii = 1:5
            allonset(i,ii)=K.theData(i).flip(ii).StimulusOnsetTime;
        end
    end
    trialinfo.StimulusOnsetTime = allonset;
    trialinfo.RT = RT;
    
    for i = 1:size(trialinfo,1)
        if trialinfo.operator(i) == 1
            trialinfo.condNames{i,1} = 'Addition';
        elseif trialinfo.operator(i) == -1
            trialinfo.condNames{i,1} = 'Subtraction';
        end
    end
   
       
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end

