function OrganizeTrialInfoUCLA_rest(sbj_name, project_name, block_names, dirs)

for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
    if length(K.conds) < length(K.theData)
        K.conds(end+1) = 8; % CHECK IF THIS IS SYSTEMATIC
    else
    end
    
    if  isempty(K.theData(1).flip)
        K.theData = K.theData(2:end);
        K.conds = K.conds(2:end);
        K.wlist = K.wlist(2:end);
    else
    end

    % start trialinfo
    trialinfo = table;
    trialinfo.wlist = reshape(K.wlist,length(K.wlist),1); % 
    
    % Correct for when two keys and RTs
    for i = 1:length(K.theData)
        if iscell(K.theData(i).keys)
            K.theData(i).keys = K.theData(i).keys{1};
        else
            K.theData(i).keys = K.theData(i).keys(1);
        end
        K.theData(i).RT = K.theData(i).RT(1);
    end
    
    for i = 1:length(K.theData)
        trialinfo.keys{i,1} = vertcat(K.theData(i).keys);
    end
    
    for i = 1:length(K.theData)
        if isempty(K.theData(i).RT)
            K.theData(i).RT = nan;
        else
        end
    end

    
    
    trialinfo.RT = vertcat(K.theData(:).RT);
    
    condNames= {'internal-self','internal-other','internal-dist-other',...
        'external-self','external-other','external-Dis-other',...
        'math','episodic','rest'};
    conds_math_memory = {'memory','memory','memory','memory','memory','memory', 'math', 'memory', 'rest'};
    
    % Add calculation info
    for i = 1:size(trialinfo,1)
        % Calculation info
        [C,matches] = strsplit(trialinfo.wlist{i},{'+','-','=', 'and', 'is'},'CollapseDelimiters',true);
        if sum(isstrprop(C{1}, 'digit')) > 0
            isCalc = 1;
            Operand1 = str2num((C{1}));
            Operand2 = str2num((C{2}));
            if strmatch(matches{1}, '-') == 1
                Operator = -1;
            else
                Operator = 1;
            end
            CorrectResult = Operand1 + Operand2*Operator;
            PresResult = str2num((C{3}(1:3))); % this is because sometimes there is a wrong character after the last digit
            Deviant = CorrectResult - PresResult;
            AbsDeviant = abs(Deviant);
            if (Deviant == 0 && strcmp(trialinfo.keys{i}, '1') == 1) || (Deviant ~= 0 && strcmp(trialinfo.keys{i}, '2') == 1)
                trialinfo.Accuracy(i,1) = 1;
            else
                trialinfo.Accuracy(i,1) = 0;
            end
            
        elseif strmatch(trialinfo.wlist{i}, '+') == 1
            isCalc = 0;
            Operand1 = nan;
            Operand2 = nan;
            Operator = nan;
            CorrectResult = nan;
            PresResult = nan;
            Deviant = nan;
            AbsDeviant = nan;
        else
            isCalc = 0;
            Operand1 = nan;
            Operand2 = nan;
            Operator = nan;
            CorrectResult = nan;
            PresResult = nan;
            Deviant = nan;
            AbsDeviant = nan;
        end
        trialinfo.condNames{i,1} = condNames{K.conds(i)};
        trialinfo.conds_math_memory{i,1} = conds_math_memory{K.conds(i)};
        trialinfo.isCalc(i,1) = isCalc;
        trialinfo.Operand1(i,1) = Operand1;
        trialinfo.Operand2(i,1) = Operand2;
        trialinfo.OperandMin(i,1) = min(Operand1,Operand2);
        trialinfo.OperandMax(i,1) = max(Operand1,Operand2);
        trialinfo.Operator(i,1) = Operator;
        trialinfo.CorrectResult(i,1) = CorrectResult;
        trialinfo.PresResult(i,1) = PresResult;
        trialinfo.Deviant(i,1) = Deviant;
        trialinfo.AbsDeviant(i,1) = AbsDeviant;
        if isempty(K.theData(i).flip)
            trialinfo.StimulusOnsetTime(i,1) = nan;
        else
        trialinfo.StimulusOnsetTime(i,1) = K.theData(i).flip.StimulusOnsetTime;
        end
    end

%% Correct for nan in trigger
trialinfo = trialinfo(~isnan(trialinfo.StimulusOnsetTime),:);

%% Rest trials added by Clara
ITIs = nan(1,size(trialinfo,1)-1);
    for t = 2:size(trialinfo,1)
        ITIs(t-1)=trialinfo.StimulusOnsetTime(t,1)-(trialinfo.StimulusOnsetTime(t-1,1)+trialinfo.RT(t-1));
    end
    
    ITIreal = mean(ITIs(ITIs<1));
    
    restInds = find((ITIs > 4 & ITIs < 6) | (ITIs > 9 & ITIs < 11));
    restOnsets = nan(1,length(restInds));
    
    for ri = 1:length(restInds)
        restOnsets(ri)=trialinfo.StimulusOnsetTime(restInds(ri),1)+trialinfo.RT(restInds(ri))+ITIreal;
    end
    
     rest_inds = restInds;
    rest_inds = rest_inds + (1:length(rest_inds));
    ntrials_total = size(trialinfo,1) + length(rest_inds);
    trialinfoNew = table;
    trialinfoNew(setdiff(1:ntrials_total,rest_inds),:)=trialinfo;
    trialinfoNew.condNames(rest_inds)={'rest'};
    trialinfoNew.conds_math_memory(rest_inds)={'rest'};
    trialinfoNew.wlist(rest_inds)={'+'};
    trialinfoNew.RT(rest_inds)=NaN;
    trialinfoNew.allonsets(rest_inds)=NaN;
    trialinfoNew.StimulusOnsetTime(rest_inds) =restOnsets;
    trialinfo = trialinfoNew;
    
    %% Correct for rest trials
    % To accound for different versions of MMR
%     if isfield(K, 'rest_inds')
%         rest_inds = sort(K.rest_inds);
%     elseif isfield(K, 'ind')
%         rest_inds = sort(K.ind);
%     else
%     end
%     
%     ntrials_total = size(trialinfo,1) + length(rest_inds);
%     
    % To accomodate the rest trials
%     trialinfoNew = table;
%     trialinfoNew(setdiff(1:ntrials_total,rest_inds),:)=trialinfo;
%     trialinfoNew.condNames(rest_inds)={'rest'};
%     trialinfoNew.conds_math_memory(rest_inds)={'rest'};
%     trialinfoNew.wlist(rest_inds)={'+'};
%     trialinfoNew.RT(rest_inds)=NaN;
%     trialinfoNew.allonsets(rest_inds)=NaN;
% 
%     trialinfo = trialinfoNew;
    
    % Save
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end

end

