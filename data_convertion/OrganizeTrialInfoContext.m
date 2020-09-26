%% Updated OrganizeTrialInfo Late January

function OrganizeTrialInfoContext(sbj_name, project_name, block_names, dirs)

for bi = 1:length(block_names)
    bn = block_names{bi};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    %soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    if strcmp(sbj_name,'S13_53_KS2')
        soda_name = dir(fullfile(globalVar.psych_dir, 'KS*.mat'));
    elseif strcmp(sbj_name,'S13_57_TVD')
        soda_name = dir(fullfile(globalVar.psych_dir, 'TVD*.mat'))
    else
        soda_name = dir(fullfile(globalVar.psych_dir, '73*.mat'));
    end
    
    K = load([globalVar.psych_dir '/' soda_name.name]);
    
    %% TESTING< REMOVE LATER
    %K = load('/Volumes/neurology_jparvizi$/SHICEP_S13_57_TVD/Data/Context/TVD_23/TVD_dv3_2_all.mat');
    %K = load('/Volumes/CLARA HD/Context/TVD_23/TVD_dv3_2_all.mat')
    %A = load('Volumes/CLARA HD/trialinfo_E15-579_0004.mat')
    
    
    %%
    % Context has:
    % 4 categories: all_num, all_word, one_word, one_num
    % should have around 12 in the "all" categories and 6 events in the
    % "one"
    % have both active and passive trials 
    
    %%
    trialinfo = table;
    trials = K.trials;
    if strcmp(sbj_name,'S12_43_HH') && strcmp(bn,'HH-13');
        ntrials = 30; %issues with timing for 31
    else
        ntrials = length(K.trials);
    end 
    %lsi= length(trials);
    
    
    for i=1:ntrials
        for ii=1:5
            problem{i,ii} = trials(i).problem{ii};
        end
    end
    
    %trying to determine what condition it is: problems are labeled as "sN"
    %or "sW" meaning "number" and "word"
        
    
    for i=1:(size(problem,1)*size(problem,2))
        tempN = startsWith(problem,'sN_','IgnoreCase',true);
        tempW = startsWith(problem,'sW_','IgnoreCase',true);
        for a=1:ntrials
            if tempN(a,1)==1
                condition{a}='numerals';
            elseif tempW(a,1)==1
                condition{a}='numword';
                %add mixed!
            end
        end
        %problem{i} = strsplit(problem{i},'_')
        problem{i} = erase(problem{i},'sW_');
        problem{i} = erase(problem{i},'sN_');
    end
    
    problem = cell2table(problem);
    
    trialinfo.stim1 = problem.problem1;
    trialinfo.stim2 = problem.problem3;
    trialinfo.stim3 = problem.problem5;
    trialinfo.condition = condition'; 
    %N
    
    for i=1:ntrials
        trialinfo.operation(i) = problem.problem2(i);
        if strcmp(problem.problem2(i),'plus')
            trialinfo.operator(i) = 1;
        elseif strcmp(problem.problem2(i),'minus')
            trialinfo.operator(i) = -1; 
        elseif strcmp(problem.problem2(i),'times') % don't know if this should be 2
            trialinfo.operator(i) = 2; 
        else 
            trialinfo.operator(i) = 0; %should never be the case
        end 
    end 
    
    %Converting from number word to digit in order to do the rest of the
    %calculations; saved in the trialinfo as operand1,operand2, presResult
    trialinfo = words2numb(K,trialinfo,ntrials);
    
    %calculating CorrResult
    for i=1:ntrials
        if strcmp (trialinfo.operation,'times')
            trialinfo.corrResult(i) = trialinfo.operand1(i)*trialinfo.operand2(i);
        else
            trialinfo.corrResult(i) = trialinfo.operand1(i) + trialinfo.operand2(i)*trialinfo.operator(i);
        end 
        trialinfo.minOperand(i) = min(trialinfo.operand1(i), trialinfo.operand2(i));
        trialinfo.maxOperand(i) = max(trialinfo.operand1(i), trialinfo.operand2(i));
        trialinfo.Correctness(i) = double(trialinfo.presResult(i) == trialinfo.corrResult(i));
        trialinfo.Deviant(i) = trialinfo.corrResult(i) - trialinfo.presResult(i);
        trialinfo.absDeviant(i) = abs(trialinfo.Deviant(i));
    end    
        
    
    
    %% Conditions - confusing here
    for iii=1:ntrials
        cond(iii) = (K.trials(iii).cond);
    end 
    cond = cond';
    
    condNames= {'easy_add_corr','easy_add_incorr','letter_add_corr','letter_add_incorr','hard_add_corr','hard_add_incorr','hard_sub_corr','hard_sub_incorr'};
    %condNames = {'all_num','all_word','one_word','one_num','NaN','NaN','NaN','NaN'};
    nstim_per_trial=[5];
    nstim_all = nan(ntrials,1);
    for ci = 1:length(condNames)
        conds(cond==ci)=condNames(ci);
        %nstim_all(trials.cond==ci) = nstim_per_trial(ci);
    end
    trialinfo.condNames = conds';
    

%TEMPORARY!!! ^should run about once know all condNames!; Might want to
%just use"condition" variable




%% MODIFIED FROM AMY's SCRIPT
    
    % Just need the onset of the first stimulus onset for each trial (there
    % are a total of 5)
   
     %added for trials that do not have the right amount of stimuli
     %(mistake); trials that were ended ready
     
            %defining the task
        %Task 1 is active; task 2 is passive
        for si= 1:ntrials
            if trials(si).instr == 1
                task(si) = 1;
            elseif trials(si).instr ==2
                task(si) = 0;
            else
                task(si) = task(si-1);
            end
        end
     trialinfo.isActive = task';
     
     start_time=trials(1).instr_time(1); %need to move this earlier because sometimes there are errors in first trials
     
     for si= 1:ntrials
        if (strcmp(trials(si).event{9},'probe'))==0 %should be probe
            temp_si(si) = si; %getting this variable, to remove that row
        end
     end 
    
     if exist('temp_si')
         temp_si=nonzeros(temp_si);
         trials(temp_si)=[];
         trialinfo(temp_si,:)=[];
         ntrials = length(trials); %if there is a change, need to change the variable
     end
    
    SOT= NaN*ones(1,ntrials);
    sbj_resp= NaN*ones(1,ntrials);
    RT = NaN*ones(1,ntrials);
    eq_corr = NaN*ones(1,ntrials);
    %task = NaN*ones(1,ntrials);
    
    for si= 1:ntrials
%         if (strcmp(trials(si).event{9},'probe'))==0
%             trials(si)=[]
%         end 
        SOT(si)= trials(1,si).time(1);
        temp_rsp = {trials(si).resp_b{9:end}};
        temp_rt = {trials(si).resp_t{9:end}};
        pressed = find(~cellfun(@isempty,temp_rsp),1);
        if (~isempty(pressed))
            %if strcmp(temp_rsp{pressed},'End')
            %strrep(temp_rsp{pressed},'End',0)
            %end 
            sbj_resp(si)=str2num(temp_rsp{pressed});
            RT(si)=temp_rt{pressed}-trials(si).time(9);
        end
    end
    
    % Is it correct? 
    %eq_corr(eq_corr==2)=0;
    %trialinfo.eq_corr = eq_corr'; %same thing as correctness
    %trialinfo.PresResult = trialinfo.stim3;
    
    trialinfo.keys = sbj_resp';
    trialinfo.RT = RT';
    trialinfo.StimulusOnsetTime = SOT';
    clear task
    clear sbj_resp
    clear RT
    
    for i=1:ntrials 
        if trialinfo.keys(i) == 1 && trialinfo.Correctness(i) == 1 || trialinfo.keys(i) == 2 && trialinfo.Correctness(i) == 0
            trialinfo.Accuracy(i) = 1;
        elseif trialinfo.keys(i) == 0
            trialinfo.Accuracy(i) = NaN;
        else
            trialinfo.Accuracy(i) = 0;
        end
    end
    
   %onsets need 1,3,5,7,9 place     
   n = [1,3,5,7,9];
        %onset=[trials(c).time(n)]
        %onset=[trials(c).time]
        %onsets = {trials(si).time(n)}; 
   %if trials.time 
    
    
   %getting onsets
   
    A = struct2table(trials);
    A = A(1:ntrials,:); %only matters for HH-13, 43_HH
    trialinfo.onsets = A.time;
%     B = A.time
%     C = num2cell(B);
%     clear A
%     clear B
%     onsets = C(:,n);
%     trialinfo.onsets = C(:,n);    
    clear problem
    clear C
    clear temp_rsp
    clear temp_rt
    
    
    %% Save trialinfo
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    
end
end
