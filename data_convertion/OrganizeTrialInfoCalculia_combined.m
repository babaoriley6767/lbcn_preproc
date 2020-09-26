function OrganizeTrialInfoCalculia_combined(sbj_name, project_name, block_names, dirs)

for bi = 1:length(block_names)
    bn = block_names{bi};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]);
    
    %active
    %K = load('/Volumes/neurology_jparvizi$/SHICEP_S15_89_JQa/Data/Calculia/E15-497_0012/sodata.S15_89_JQ.31.08.2015.12.13.mat')
    %passive
    %K = load('/Volumes/neurology_jparvizi$/SHICEP_S16_93_MA/Data/Calculia/E16-022_0012/sodata.S16_93_MA.11.01.2016.11.32.mat')
    %version 1
    %K = load('/Volumes/neurology_jparvizi$/SHICEP_S14_64_SP/Data/Calculia v1/S14_64_SP_12/sodata.S14_64_SP.30.03.2014.12.13.mat')
    
    % Number of trials
    ntrials = length(K.theData);
    if K.trial < length(K.theData)
        for i = (K.trial+1):length(K.theData)
            K.theData(i).keys = NaN;
            K.theData(i).RT = NaN;
            K.theData(i).ifAnsIsDelayed = NaN;
            if ~isstruct(K.theData(i).flip)
                K.theData(i).flip = {};
                K.theData(i).flip.StimulusOnsetTime = NaN;
                %                 fprintf('Making it struct: %d\n',i)
            end
            K.theData(i).flip.StimulusOnsetTime = NaN;
            %K.theData(i).flip.StimulusOnsetTime = NaN;
        end
%            K.theData(end) = [];
    else
    end
    
        
    %PASSIVE OR ACTIVE
    
    %wlistinfo = K.wlistInfo
    %if exist('K.wlistInfo') == '1'
    
    %% initiate trialinfo
    trialinfo = table;
    if isfield(K,'wlistInfo') == 1
        if strcmp(sbj_name, 'S16_94_DR') == 1
            trialinfo.isActive = vertcat(K.wlistInfo(:).isActive);
            trialinfo.isActive = zeros(ntrials,1);
        else
            trialinfo.isActive = vertcat(K.wlistInfo(:).isActive);
        end
        trialinfo.version = ones(ntrials,1)+2;
    else
        trialinfo.isActive = repmat(calculia_blocktype(sbj_name,bn), ntrials, 1);
        trialinfo.version = ones(ntrials,1);
    end
    
    %% List stimuli properties
    trialinfo.wlist = K.wlist;
    [operands,operators] = cellfun(@(x) strsplit(x, {'+','-','=','without','is','and'}, 'CollapseDelimiters',true), K.wlist, 'UniformOutput', false);
    for i = 1:length(operands)
        trialinfo.stim1{i} = operands{i}{1};
        trialinfo.stim2{i} = operands{i}{2};
        trialinfo.stim3{i} = operands{i}{3};
        
        if ~isempty(str2num(operands{i}{1}))
            trialinfo.isCalc(i) = 1;
            trialinfo.condNames{i} = 'digit';
            trialinfo.operand1(i) = str2num(operands{i}{1});
            trialinfo.operand2(i) = str2num(operands{i}{2});
            
            if strcmp(operators{i}{1}, '+')
                trialinfo.operator(i) = 1;
            else
                trialinfo.operator(i) = -1;
            end
            trialinfo.presResult(i) = str2num(operands{i}{3});
            trialinfo.corrResult(i) = trialinfo.operand1(i) + trialinfo.operand2(i)*trialinfo.operator(i);
            trialinfo.minOperand(i) = min(trialinfo.operand1(i), trialinfo.operand2(i));
            trialinfo.maxOperand(i) = max(trialinfo.operand1(i), trialinfo.operand2(i));
            trialinfo.Correctness(i) = double(trialinfo.presResult(i) == trialinfo.corrResult(i));
            trialinfo.Deviant(i) = trialinfo.corrResult(i) - trialinfo.presResult(i);
            trialinfo.absDeviant(i) = abs(trialinfo.Deviant(i));
            
            % Cross decade
            if trialinfo.minOperand(i) < 10 && trialinfo.maxOperand(i) < 10
                if length(operands{i}{3}) > 1
                    trialinfo.crossDecade(i) = 1;
                else
                    trialinfo.crossDecade(i) = 0;
                end
            elseif trialinfo.minOperand(i) > 10 && trialinfo.maxOperand(i) > 10
                trialinfo.crossDecade(i) = 1;
            else
                max_tmp = num2str(trialinfo.maxOperand(i));
                corr_tmp = num2str(trialinfo.corrResult(i));
                if strcmp(max_tmp(1), corr_tmp(1)) == 1
                    trialinfo.crossDecade(i) = 0;
                else
                    trialinfo.crossDecade(i) = 1;
                end
            end
        else
            trialinfo.isCalc(i) = 0;
            trialinfo.condNames{i} = 'letter';
            trialinfo.presResult(i) = nan;
            trialinfo.corrResult(i) = nan;
            trialinfo.minOperand(i) = nan;
            trialinfo.maxOperand(i) = nan;
            trialinfo.Correctness(i) = double(strcmp([operands{i}{1} operands{i}{2}], operands{i}{3}));
            trialinfo.Deviant(i) = nan;
            trialinfo.absDeviant(i) = nan;
            trialinfo.crossDecade(i) = nan;
        end
        
    end
    
%     %% For when the last trials were not run
%     if K.trial < length(K.theData)
%         diff_theData_trial = length(K.theData) - K.trial;
%         K.theData(end-diff_theData_trial:end) = [];
%     else
%     end
    
    %% isDelayed
    
    % If the cells are empty
    for i = 1:length(K.theData)
        if size(K.theData(i).ifAnsIsDelayed,2) ~= 1;
            K.theData(i).ifAnsIsDelayed = NaN;
            K.theData(i).RT = NaN;
            K.theData(i).keys = NaN;
            if ~isstruct(K.theData(i).flip)
                K.theData(i).flip = {};
                K.theData(i).flip.StimulusOnsetTime = NaN;
                %                 fprintf('Making it struct: %d\n',i)
            end
            K.theData(i).flip.StimulusOnsetTime = NaN;
        else
        end
    end
    trialinfo.isDelayed = vertcat(K.theData.ifAnsIsDelayed);
    
    
    % If there are more than two answers at the same time (and not a passive trial), turn it into a NaN:
    for i = 1:length(K.theData)
        if trialinfo.version(1) ~= 3 && length(K.theData(i).RT) > 1
            K.theData(i).RT = NaN;
            K.theData(i).keys = NaN;
        % If there are more than two answers at the same time (and it is 
        % a passive trial), assign the first key as legitimate
        elseif trialinfo.version(1) == 3 && length(K.theData(i).RT) > 1 && trialinfo.isActive(1) == 1
            K.theData(i).RT = K.theData(i).RT(1);
            K.theData(i).keys = K.theData(i).keys(1);
        end
    end
    
    
    % RT & Keys
    if trialinfo.isActive(1) == 0 && trialinfo.version(1) == 3
        trialinfo.RT = nan(size(trialinfo,1),1);
        trialinfo.keys = nan(size(trialinfo,1),1);
        trialinfo.Accuracy = nan(size(trialinfo,1),1);
    else
        trialinfo.RT = [K.theData(:).RT]';
        trialinfo.keys = vertcat({K.theData.keys})';
       
%         %For when keys are = no answer
%         for i = 1:length(K.theData)
%             if strcmp(trialinfo.keys{i}, 'noanswer')
%                 trialinfo.keys{i} = NaN;
%             else
%             end
%         end
        
        
        % Accurracy
        for i = 1:length(operands)
            
            if (strcmp(trialinfo.keys{i}, '1') && trialinfo.Correctness(i) == 1) || (strcmp(trialinfo.keys{i}, '2') && trialinfo.Correctness(i) == 0)
                trialinfo.Accuracy(i) = 1;
            else
                trialinfo.Accuracy(i) = 0;
            end
        end
        
    end
    
    % Stimuli onset
    allonset = nan(ntrials,1);
    for i = 1:ntrials
        for ii = 1
            allonset(i,ii)=K.theData(i).flip(ii).StimulusOnsetTime;
        end
    end
    trialinfo.StimulusOnsetTime = allonset;
    
    
    %% Save trialinfo
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    
end
end
