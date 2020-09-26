function data_all = ConcatenateAvgTrials(sbj_names,project_name, conds_avg_field, conds_avg_conds,concat_params, bad_chan_reject, dirs, badchan_vis, locktype)

%% Avg task
% conditions to average
data_all.wave_mean = [];
data_all.wave_trimmean = [];
data_all.wave_trimmean_norm = [];
for ii = 1:length(conds_avg_conds)
    % Initialize data_all
    data_all.wave_mean.(conds_avg_conds{ii}) = [];
    data_all.wave_trimmean.(conds_avg_conds{ii}) = [];
    data_all.wave_trimmean_norm.(conds_avg_conds{ii}) = [];
end

%% Group data
% data_all.MNI_coord = [];
data_all.subjects = [];
bad_chans = [];
for i = 1:length(sbj_names)
    disp(['concatenating subject ' sbj_names{i}])
    %% Concatenate trials from all blocks
    block_names = BlockBySubj(sbj_names{i},project_name);
    data_sbj = ConcatenateAll(sbj_names{i},project_name,block_names,dirs,[],'Band','HFB',locktype, concat_params);
%     if ~isempty(badchan_vis)
%         data_sbj.badChan = badchan_vis{i};
%     else
%     end
    % Average across trials, normalize and concatenate across subjects
       
    for ii = 1:length(conds_avg_conds)
        data_tmp_mean = squeeze(nanmean(data_sbj.wave(strcmp(data_sbj.trialinfo.(conds_avg_field), conds_avg_conds{ii}),:,:),1)); % average trials by electrode
        data_tmp_trimmean = squeeze(trimmean(data_sbj.wave(strcmp(data_sbj.trialinfo.(conds_avg_field), conds_avg_conds{ii}),:,:),10,1)); % average trials by electrode
        data_tmp_trimmean_norm = (data_tmp_trimmean-min(data_tmp_trimmean(:)))/(max(data_tmp_trimmean(:))-min(data_tmp_trimmean(:)));
        
        if bad_chan_reject
            data_tmp_mean(data_sbj.badChan,:) = [];
            data_tmp_trimmean(data_sbj.badChan,:) = [];
            data_tmp_trimmean_norm(data_sbj.badChan,:) = [];            
        else
        end
        
        data_all.wave_mean.(conds_avg_conds{ii}) = [data_all.wave_mean.(conds_avg_conds{ii});data_tmp_mean]; % concatenate across subjects
        data_all.wave_trimmean.(conds_avg_conds{ii}) = [data_all.wave_trimmean.(conds_avg_conds{ii});data_tmp_trimmean]; % concatenate across subjects
        data_all.wave_trimmean_norm.(conds_avg_conds{ii}) = [data_all.wave_trimmean_norm.(conds_avg_conds{ii});data_tmp_trimmean_norm]; % concatenate across subjects
    end
    % Concatenate bad channels
    if i == 1
        counter = 0;
    else
        counter = size(data_sbj.wave,2);
    end
    bad_chans = [bad_chans, data_sbj.badChan+counter];
    
    %% Concatenate channel coordinates
    % Load subjVar and add additional info
    load([dirs.original_data filesep sbj_names{i} filesep 'subjVar_' sbj_names{i} '.mat']);
    if size(subjVar.elinfo.MNI_coord,1) ~= size(data_sbj.wave,2)
        error('channel labels mismatch, double check ppt and freesurfer')
    else
    end
    
    subjects_tmp = cellstr(repmat(sbj_names{i}, size(data_sbj.wave,2),1));

    % Concatenate elinfo
    if bad_chan_reject
        subjVar.elinfo(data_sbj.badChan,:) = [];
        subjects_tmp(data_sbj.badChan) = [];
    else
    end
    
    if i == 1
        elinfo_all = subjVar.elinfo;
    else
        elinfo_all = vertcat(elinfo_all, subjVar.elinfo);
    end
%     
%     MNI_coords = subjVar.MNI_coord;
%     native_coords = subjVar.native_coord;
%     %     elect_names = subjVar.elect_names;
%     elect_names = subjVar.labels;
%      %
%      if bad_chan_reject
%          MNI_coords(data_sbj.badChan,:) = [];
%          elect_names(data_sbj.badChan) = [];
%          native_coords(data_sbj.badChan,:) = [];
%      else
%     end
%     
%     data_all.MNI_coord = [data_all.MNI_coord;MNI_coords]; % concatenate electrodes across subjects
%     data_all.native_coord = [data_all.native_coord;native_coords]; % concatenate electrodes across subjects
%     data_all.elec_names{i} = elect_names;
    data_all.subjects = vertcat(data_all.subjects,subjects_tmp);
    
    if bad_chan_reject == false
        data_all.badchans{i} = data_sbj.badChan;
    else
    end
    
end
data_all.time = data_sbj.time;
data_all.badchans_all = bad_chans;
data_all.elinfo = elinfo_all;
end



