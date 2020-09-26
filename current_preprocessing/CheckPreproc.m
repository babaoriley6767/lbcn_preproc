%
% sbj_names = {}
% project_names = {}


for i = 1:length(sbj_names)
    
    %     d_stim = sprintf([dirs.result_root '/%s/%s/Figures/BandData/HFB/stimlock'], project_names{i}, sbj_names{i});
    %     d_resp = sprintf([dirs.result_root '/%s/%s/Figures/BandData/HFB/resplock'], project_names{i}, sbj_names{i});
    
    block_names = BlockBySubj(sbj_names{i}, project_names{i})
    
    if strcmp(block_names{1}, 'none')
        dir_stim_HFB(i) = 0;
        dir_resp_HFB(i) = 0;
        block_names_exist(i) = 0;
    else
        block_names_exist(i) = 1;
        dir_in = [dirs.data_root,filesep,'Band','Data',filesep,'HFB',filesep,sbj_names{i},filesep,block_names{1},filesep,'EpochData'];
        d_stim_HFB = sprintf('%s/%siEEG_%s_%s_%.2d.mat',dir_in,'HFB','stimlock_bl_corr', block_names{1},1);
        d_resp_HFB = sprintf('%s/%siEEG_%s_%s_%.2d.mat',dir_in,'HFB','resplock_bl_corr', block_names{1},1);
        
        d_stim_plot = sprintf([dirs.result_root '/%s/%s/Figures/BandData/HFB/stimlock'], project_names{i}, sbj_names{i});
        d_resp_plot = sprintf([dirs.result_root '/%s/%s/Figures/BandData/HFB/resplock'], project_names{i}, sbj_names{i});
        
       
        if exist(d_stim_HFB, 'file') > 0
            dir_stim_HFB(i) = 1;
        else
            dir_stim_HFB(i) = 0;
        end
        if exist(d_resp_HFB, 'file') > 0
            dir_resp_HFB(i) = 1;
        else
            dir_resp_HFB(i) = 0;
        end
    end
    
end