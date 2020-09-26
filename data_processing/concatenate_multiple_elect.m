function data_all = concatenate_multiple_elect(elec_list, project_name, dirs, datatype, freq_band, locktype)
%% Concatenates data for multiple electrodes within or across subjects




% Get concat params
cfg = [];
cfg.decimate = false;
concat_params = genConcatParams(project_name, cfg);
concat_params.noise_fields_trials(3)= {'spike_hfb'};


% Define data type
if strcmp(datatype,'Spec')
    tdim = 4; % time dimension after concatenating
    tag = [locktype,'lock_bl_corr']; % specifies type of data to load
    
elseif strcmp(datatype,'Band')
    tdim = 3;
    tag = [locktype,'lock_bl_corr']; % specifies type of data to load
elseif strcmp(datatype,'CAR')
    tdim = 3;
    tag = [locktype,'lock']; % specifies type of data to load
end


data_all.trialinfo = [];
concatfields = {'wave'}; % type of data to concatenate
for ie = 1:size(elec_list,1)
    s = elec_list.sbj_name{ie};
    % Load subject variable
    load([dirs.original_data filesep s filesep 'subjVar_' s '.mat'])
    block_names = BlockBySubj(s,project_name);
    el = elec_list.chan_num(ie);
    % Concat blocks of the same electrode
    data_bn = concatBlocks(s,project_name,block_names,dirs,el,freq_band,datatype,concatfields,tag);
    data_bn = spike_detector(data_bn,el,subjVar,project_name);

    % Filter bad trials
    if strcmp(concat_params.noise_method,'timepts')
        data_bn = removeBadTimepts(data_bn,concat_params.noise_fields_timepts);
    elseif strcmp(concat_params.noise_method,'none')
        
    elseif strcmp(concat_params.noise_method,'trials')
        bad_trials = [];
        for i = 1:length(concat_params.noise_fields_trials)
            bad_trials = union(bad_trials,find(data_bn.trialinfo.(concat_params.noise_fields_trials{i})));
%             bad_trials = unique([bad_trials find(data_bn.trialinfo.spike_hfb == true)]);
            bad_trials = reshape(bad_trials,length(bad_trials),1);
        end
    end
    
    % Decimate or not
    if concat_params.decimate % smooth and downsample (optional)
        if data_bn.fsample == 999
            ds_rate = 2; % FIX THIS, it assumes fs = 1000Hz.
            data_all.fsample =concat_params.fs_targ ;
            data_all.time = data_bn.time(1:ds_rate:end);
        else
            ds_rate = floor(data_bn.fsample/concat_params.fs_targ); % FIX THIS, it assumes fs = 1000Hz.
            data_all.fsample = data_bn.fsample/ds_rate;
            data_all.time = data_bn.time(1:ds_rate:end);
        end
        if strcmp(datatype,'Band') || strcmp(datatype,'CAR')
            data_bn.wave = data_bn.wave(:,1:ds_rate:end);
        elseif strcmp(datatype,'Spec')
            data_bn.wave = data_bn.wave(:,:,1:ds_rate:end);
        end
    else
        data_all.time = data_bn.time;
        data_all.fsample = data_bn.fsample;
    end
    
    % Exclude bad trials
    if strcmp(concat_params.noise_method,'trials')
        data_bn.wave(bad_trials,:) = [];
        data_bn.trialinfo(bad_trials,:) = [];
    else
    end

    
    
    % Concatenate all subjects all trials
    if strcmp(datatype,'Band') || strcmp(datatype,'CAR')
        data_all.wave{ie} = data_bn.wave;
    elseif strcmp(datatype,'Spec')
        data_all.wave(:,:,ie,:) = data_bn.wave;
    end
    
    %     data_all.label = data_bn.label;
    
    data_all.trialinfo_all{ie} = [data_bn.trialinfo];
    %     data_all.labels{ei} = data_bn.label;
    disp(['concatenating elec ',num2str(el)])
    data_all.label(ie) = subjVar.elinfo.FS_label(el); % just modified that
    data_all.subj_name{ie} = s;
    data_all.chan_num(ie) = subjVar.elinfo.chan_num(el); % just modified that
    if strcmp(concat_params.noise_method,'trials')
        data_all.bad_trials{ie} = bad_trials;
    else
    end
    
    % Exclude bad trials
    
        
    
end


