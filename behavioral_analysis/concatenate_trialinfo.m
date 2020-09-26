function trialinfo_all = concatenate_trialinfo(sbj_name, project_name, dirs)

block_names = BlockBySubj(sbj_name, project_name);

trialinfo_all = [];
for i = 1:length(block_names)
    bn = block_names{i};
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));    
    load([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
    % concatenate trial info
    trialinfo_all = [trialinfo_all; trialinfo];
end
end

