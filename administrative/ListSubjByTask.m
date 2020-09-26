function task_table = ListSubjByTask(tasks)

%% List all subject all math tasks
all_folders = dir(fullfile('/Volumes/neurology_jparvizi$/'));

for i = 1:length(all_folders)
    if exist([all_folders(i).folder filesep all_folders(i).name filesep 'Data'], 'DIR') > 0
        subj_name{i} = erase(all_folders(i).name, 'SHICEP_');
        all_folders_tasks = dir(fullfile([all_folders(i).folder filesep all_folders(i).name filesep 'Data']));
        tmp = [];
        for ii = 1:length(all_folders_tasks)
            tmp(ii) = ~contains(all_folders_tasks(ii).name, '.');
        end
        all_folders_tasks = all_folders_tasks(tmp==1);
        subj_tasks{i} = {all_folders_tasks.name};
    end
end

for i = 1:length(subj_tasks)
    if ~isempty(subj_tasks{i})
        for t = 1:length(tasks)
            if strcmp(tasks{t}, '7Heaven')
                data.('SevenHeaven')(i) = sum(contains(subj_tasks{i}, tasks{t}));
            else
                data.(tasks{t})(i) = sum(contains(subj_tasks{i}, tasks{t}));
            end
        end
    end
end

fieldnames_tasks = fieldnames(data);

for t = 1:length(fieldnames_tasks)
    data_task.(fieldnames_tasks{t}) = subj_name(data.(fieldnames_tasks{t})>0)';
    n_subject(t) = length(data_task.(fieldnames_tasks{t}));
end

max_subj = max(n_subject);


for t = 1:length(fieldnames_tasks)
    if length(data_task.(fieldnames_tasks{t})) == max_subj
    else
        data_task.(fieldnames_tasks{t})(end+1:max_subj) = {'nan'};
    end
end

task_table = struct2table(data_task);


end

