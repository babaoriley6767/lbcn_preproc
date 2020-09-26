function s = get_encoding_scores(subjects,project_name,dirs)

for is = 1:length(subjects)
    
    sbj_name = subjects{is};
    sbj_name_num_tmp = strsplit(sbj_name, '_');
    subj_num = sbj_name_num_tmp{2};
    s.(sbj_name).scores = load(sprintf('%s/%s_scores.csv', dirs.encoding.result_dir, subj_num));
    s.(sbj_name).coefs = load(sprintf('%s/%s_coefs.csv',dirs.encoding.result_dir, subj_num));
    s.(sbj_name).intercept = load(sprintf('%s/%s_intercept.csv', dirs.encoding.result_dir, subj_num));
    s.(sbj_name).scores_single_trials = load(sprintf('%s/%s_scores_single_trials.csv', dirs.encoding.result_dir, subj_num));
    s.(sbj_name).basic_stim_features = readtable(sprintf('%s/%s_basic_stim_features.csv', dirs.encoding.data_dir, subj_num));
    s.(sbj_name).trialinfo = concatenate_trialinfo(sbj_name, project_name, dirs);
    disp(['done subject ' sbj_name])
end

end
