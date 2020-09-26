function OrganizeTrialInfoGradCPT(sbj_name, project_name, block_names, dirs,n_delete,Windows)

for i = 1:length(block_names)
    bn = block_names{i};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % load psychtoolbox behav file
    behavfile = dir([globalVar.psych_dir '/Data*']);
    load([globalVar.psych_dir '/',behavfile(1,1).name]);
    
    ntrials = size(data,1)-n_delete;
    trialinfo = table;
    
    % FROM AARON'S SCRIPT
    
    % delete beginning trials if selected
    if n_delete>0
        response_orig=response;
        data_orig=data;
        response=response(n_delete+1:end,:);
        data=data(n_delete+1:end,:);
    end
    
    if Windows=='0'
        CPT_analyze_func2(response,ttt);
    elseif Windows=='1'
        CPT_analyze_func3(response,ttt);
    end
%     CV_overall=ans(44);
%     RT_tot=ans(19);
%     STD_tot=ans(24);
%     OE_rate=ans(14);
%     CE_rate=ans(9);
%     dprime_overall=ans(34);
    
    if Windows=='0'
        CO_indices=find(response(:,1)==1 & response(:,7)==0);
        CE_indices=find(response(:,1)==1 & response(:,7)==-1);
        CC_indices=find(response(:,1)==2 & response(:,7)==1);
        OE_indices=find(response(:,1)==2 & response(:,7)==0);
    elseif Windows=='1'
        CO_indices=find(response(:,1)==1 & response(:,2)==0);
        CE_indices=find(response(:,1)==1 & response(:,2)~=0);
        CC_indices=find(response(:,1)==2 & response(:,2)~=0);
        OE_indices=find(response(:,1)==2 & response(:,2)==0);
    end
    
    trialinfo.respType = cell(ntrials,1);
    trialinfo.respType(CO_indices)={'CO'}; % correct omission
    trialinfo.respType(CE_indices)={'CE'}; % commission error
    trialinfo.respType(CC_indices)={'CC'}; % correct reponse
    trialinfo.respType(OE_indices)={'OE'}; % omission error
    
    trialinfo.RT = response(:,5);
    trialinfo.RT(trialinfo.RT == 0)= NaN;
    trialinfo.StimulusOnsetTime = data(:,9);
    
    CEs_total=length(CE_indices);
    COs_total=length(CO_indices);
    
    total_time=endtime-starttime;
%     ECoG_start=TTL_onsets(2);
    
    % Get CE RTs
    CE_RTs=response(CE_indices,5);
    
    % Get RT time course
    RT=response(1:end,5); % get RTs
    RT(find(RT==0))=NaN;    % Turn zeros (COs + OEs) into NaNs;
    RT(CE_indices)=NaN; % Turn CEs into NaNs
    
    % Subtract start time from onset of each stimulus
    for x=1:length(RT)
        RT(x,2)=data(x,9)-starttime;
    end;
    stimulus_onsets_PTB=RT(:,2)-RT(1,2);
    
    if n_delete>0
        stimulus_onsets_PTB=[];
        task_onset=data_orig(1,9)-starttime;
        stimulus_onsets_PTB=RT(:,2)-task_onset;
    end
    
    RT=RT(:,1); 
    
    % Calculate button press onsets
    RT_onset=RT+stimulus_onsets_PTB;
    
    % Find mountain and city event onset times
    mountain_ind=find(response(:,1)==1);
    city_ind=find(response(:,1)==2);
    
    trialinfo.condNames = cell(ntrials,1);
    trialinfo.condNames(mountain_ind)={'mtn'};
    trialinfo.condNames(city_ind)={'city'};
    
    % create new column of conditions for cities and mountains not preceded
    % by a mountain
    
    mt_dif=diff(mountain_ind); % Find and delete repeating mountain events
    mt_repeat_ind=find(mt_dif==1);
    mountain_ind(mt_repeat_ind+1)=[];
    
    % Delete cities preceded by mountains
    city_mnt_diffs=diff(response(:,1));
    city_post_mt_ind=find(city_mnt_diffs==1)+1;
    for j=1:length(city_post_mt_ind)
        city_ind_rm(j,:)=find(city_ind==city_post_mt_ind(j));
    end
    city_ind(city_ind_rm)=[];
    
    trialinfo.condNotAfterMtn = cell(ntrials,1);
    trialinfo.condNotAfterMtn(mountain_ind)={'mtn'};
    trialinfo.condNotAfterMtn(city_ind)={'city'};
    
    % Save
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    disp(['block ',num2str(i)])
end

end

