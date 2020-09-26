function el_selectivity = get_HFO_electrodes(dirs, el_selectivity, sbj_name, task)
    
    block_names = BlockBySubj(sbj_name,task);
    
    for i = 1:length(block_names)
        bn = block_names{i};
        load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));

    end



end

