function deleteContinuousData(sbj_name, dirs, project_name, block_names, freq_band, datatype)

for i = 1:length(block_names)
    bn = block_names{i};
    
    % Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_names{1}),'globalVar');
    
    disp(['deleting all files from block ' bn])
    dir_data = [globalVar.([datatype,'Data']),filesep,freq_band,filesep,sbj_name,filesep,bn];
  
    dinfo = dir(fullfile(dir_data,'*.mat'));
    for i = 1:length(dinfo)
        thisfile = fullfile(dir_data, dinfo(i).name);
        disp(['deleted ' thisfile])
        delete(thisfile);
    end

end


end