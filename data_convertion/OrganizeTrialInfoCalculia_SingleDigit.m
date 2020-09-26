function OrganizeTrialInfoCalculia_SingleDigit(sbj_name, project_name, block_names, dirs)

condNames= {'autobio','math'};
nstim_per_trial = [4 5];

for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    
    RT = [K.theData(:).RT]';
    ntrials = length(K.conds);
    
    trialinfo = table;
    
    % trialinfo.nstim = nan(ntrials,1);
    
    conds = cell(ntrials,1);
    nstim_all = nan(ntrials,1);
    for ci = 1:length(condNames)
        conds(K.conds==ci)=condNames(ci);
        nstim_all(K.conds==ci) = nstim_per_trial(ci);
    end
    trialinfo.condNames = conds;
    trialinfo.nstim = nstim_all;
    trialinfo.stim1 = cell(ntrials,1);
    trialinfo.stim2 = cell(ntrials,1);
    trialinfo.stim3 = cell(ntrials,1);
    trialinfo.stim4 = cell(ntrials,1);
    trialinfo.stim5 = cell(ntrials,1);
    
    allonset = nan(ntrials,max(nstim_per_trial));
    for i = 1:ntrials
        split_stim = strsplit(K.wlist{i},',');
        for ii = 1:trialinfo.nstim(i)
            allonset(i,ii)=K.theData(i).flip(ii).StimulusOnsetTime;
            trialinfo.(['stim',num2str(ii)])(i)=split_stim(ii);
        end
        
    end
    trialinfo.wlist = K.wlist';
    trialinfo.StimulusOnsetTime = allonset;
    trialinfo.RT = RT;
    
    counter = 1;
    nblocks = ntrials/K.bSize;
    mathtype = cell(ntrials,1);
    for bi = 1:nblocks
        inds = counter:(counter+K.bSize-1);
        if K.bType(bi)==2
            mathtype(inds)={'digit'};
        elseif K.bType(bi)==3
            mathtype(inds)={'numword'};
        end
        counter = counter+K.bSize;
    end
    
    trialinfo.mathtype = mathtype;
    
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end

