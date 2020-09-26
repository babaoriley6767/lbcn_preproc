function export_encoding_features(task,subj,dirs)

    block_names = BlockBySubj(subj, task);
    cfg = [];
    cfg.decimate = false;
    concat_params = genConcatParams(task, cfg);
    concat_params.data_format = 'regular'; %'fieldtrip_fq' fieldtrip_raw
    concat_params.noise_method = 'none';
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,subj,task,subj,block_names{1}),'globalVar');
    data = ConcatenateAll(subj,task,block_names,dirs, [],'Band','HFB','stim', concat_params); % 'HFB'

    %% Convert to encoding matrix
    cfg = [];
    cfg.time_window = concat_params.t_stim; % in secs
    [enc_matrix, stim_features_table] = convertEncodingMatrix(data, cfg);
    sbj_name_num = strsplit(subj, '_');
    sbj_name_num = sbj_name_num{2};

    %% export basic condition features per task
    basic_stim_features = get_basic_features(data, task);
    writetable(basic_stim_features, sprintf('%s/%s_basic_stim_features.csv', dirs.outdir, sbj_name_num));
    writetable(stim_features_table, sprintf('%s/%s_stim_features.csv',  dirs.outdir, sbj_name_num));
    csvwrite(sprintf('%s/%s_brain_features.csv',  dirs.outdir, sbj_name_num),enc_matrix)
    sprintf('encoding matrix saved for subject %s', subj)

end

