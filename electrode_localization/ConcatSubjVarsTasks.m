function subjVar_all = ConcatSubjVarsTasks(subjects, dirs, vars)
% vars = {'chan_num', 'FS_label', 'WMvsGM', 'LvsR', 'sEEG_ECoG', 'DK_lobe', 'Destr_long', 'DK_long_josef', 'LBCN_josef', 'MNI_coord'}

%% Define final cohorts
% read the google sheets
[DOCID,GID] = getGoogleSheetInfo('math_network','cohort');
sinfo = GetGoogleSpreadsheet(DOCID, GID);
subject_names = sinfo.sbj_name;

tasks = unique(sinfo.task);
subjVar_all = table;
for is = 1:length(subjects)
    s = subjects{is};
    load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
    subjVar_tmp = subjVar.elinfo(:, contains(subjVar.elinfo.Properties.VariableNames, vars));
    subjVar_tmp.sbj_name = repmat({s}, size(subjVar_tmp,1),1,1);
    sinfo_tmp = sinfo(strcmp(sinfo.sbj_name, s),:);
    for it = 1:length(tasks)
        if sum(strcmp(sinfo_tmp.task, tasks{it})) == 1
            subjVar_tmp.(tasks{it}) = ones(size(subjVar_tmp,1),1,1);
        else
            task_present = 0;
            subjVar_tmp.(tasks{it}) = zeros(size(subjVar_tmp,1),1,1);
        end
    end
    subjVar_all = [subjVar_all; subjVar_tmp];
end
end

