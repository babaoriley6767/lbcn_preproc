function xcorr_multiple_subj(s, el_info,task, dirs)


s_tmp = el_info(strcmp(el_info.sbj_name, s),:);
electrodes = s_tmp.chan_num;
block_names = BlockBySubj(s, task);
xcorr_all = laggedCorrPerm(s, task,block_names,dirs,electrodes,electrodes,'HFB',[],'condNames',{'math'});
fname = sprintf('%s%s_%s_x_corr.mat', dirs.result_dir, s, task);
save(fname,'xcorr_all')


end

