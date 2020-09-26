function OrganizeTrialInfoMemoria(sbj_name, project_name, block_names, dirs,language)

% language: 'english' or 'spanish'

condNames= {'autobio','math'};
nstim_per_trial = [4 5];

for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO
      
    
    %% Account for empty last responses
    if isempty(K.theData(end).flip)
       K.wlist(end) = [];
       K.theData(end) = [];
       K.conds(end) = [];
    end
    
    ntrials = length(K.conds);
    for ti = ntrials:-1:1  % if 'empty' trials at end, eliminate
        if isempty(K.theData(ti).flip)
            ntrials = ntrials-1;
        else
            break
        end
    end
    
    trialinfo = table;
    trialinfo.wlist = K.wlist(1:ntrials)';
    tmp = [K.theData(1:ntrials).RT]';
    trialinfo.RT = tmp;
    tmp = {K.theData(:).keys};
    blanks = find(strcmp(tmp,'noanswer') | isempty(tmp));
    for bb = 1:length(blanks)
        K.theData(blanks(bb)).keys = '0'; % replace 'noanswer' with '0' so can perform vertcat
    end
    for iii = 1:length(K.theData)
        if length(K.theData(iii).keys) == 2
            K.theData(iii).keys = K.theData(iii).keys(1);
        else
        end
    end
    
    tmp = vertcat(K.theData(1:ntrials).keys);
    
    
    trialinfo.keys = tmp;
        
    conds = cell(ntrials,1);
    nstim_all = nan(ntrials,1);
    for ci = 1:length(condNames)
        conds(K.conds(1:ntrials)==ci)=condNames(ci);
        nstim_all(K.conds(1:ntrials)==ci) = nstim_per_trial(ci);
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
        trialinfo.nstim(i) =length([K.theData(i).flip.StimulusOnsetTime]);%
        for ii = 1:trialinfo.nstim(i)
            allonset(i,ii)=K.theData(i).flip(ii).StimulusOnsetTime;
            trialinfo.(['stim',num2str(ii)])(i)=split_stim(ii);
        end
        
    end

    trialinfo.StimulusOnsetTime = allonset;

    
    counter = 1;
    nblocks = ntrials/K.bSize;
    mathtype = cell(ntrials,1);
    conds_all = cell(ntrials,1);
    for bi = 1:nblocks
        inds = counter:(counter+K.bSize-1);
        if K.bType(bi)==2
            mathtype(inds)={'digit'};
            conds_all(inds)={'digit'};
        elseif K.bType(bi)==3
            mathtype(inds)={'numword'};
            conds_all(inds)={'numword'};
        elseif K.bType(bi)==1
            conds_all(inds)={'autobio'};
        end
        counter = counter+K.bSize;
    end
    
    trialinfo.mathtype = mathtype;
    trialinfo.conds_all = conds_all;
    
    %% define the general and specific veb
    if strcmp(language,'spanish')
        general_verb={' di',' usé',' vi',' tenía',' tome',' envié',' conocí',' visité',' asistí'};
    else
        general_verb={' gave',' used',' saw',' had',' took',' sent',' met',' visited',' attended'};
    end
    auto_indx = ismember(trialinfo.condNames,'autobio');
    auto_indx=find(auto_indx==1);
    genindx=[];
    for i= 1:length(general_verb)
        general_i = ismember(trialinfo.stim3,general_verb{i});
        genindx = [genindx;find(general_i==1)];
    end
    specindx=setdiff(auto_indx,genindx);
    newcondNames=trialinfo.condNames;
    newcondNames(specindx)={'autobio-specific'};
    newcondNames(genindx)={'autobio-general'};
    trialinfo.newcondNames=newcondNames;
    
    %% Define Math variables
    for i = 1:size(trialinfo,1)
        % Calculation info
        [C,matches] = strsplit(trialinfo.wlist{i},{'+','-','=', 'and', 'is', 'plus', 'equals','mas','es'},'CollapseDelimiters',true);
        if strcmp(trialinfo.condNames(i), 'math')
            isCalc = 1;
            if strcmp(trialinfo.mathtype(i), 'digit')
                Operand1 = str2num((C{1}));
                Operand2 = str2num((C{2}));
                PresResult = str2num((C{3}));
            else
                if strcmp(language,'english')
                    Operand1 = words2num((C{1}));
                    Operand2 = words2num((C{2}));
                    PresResult = words2num((C{3}));
                else  % need to find permanent solution for spanish
                    Operand1 = NaN;
                    Operand2 = NaN;
                    PresResult = NaN;
                end
            end
            
            if strcmp(matches{1}, '-') == 1 || strcmp(matches{1}, 'minus') == 1
                Operator = -1;
            else
                Operator = 1;
            end
            CorrectResult = Operand1 + Operand2*Operator;
            %             PresResult = str2num((C{3}(1:3))); % this is because sometimes there is a wrong character after the last digit
            Deviant = CorrectResult - PresResult;
            AbsDeviant = abs(Deviant);
            if (Deviant == 0 && strcmp(trialinfo.keys(i), '1') == 1) || (Deviant ~= 0 && strcmp(trialinfo.keys(i), '2') == 1)
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
    end
    
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end

