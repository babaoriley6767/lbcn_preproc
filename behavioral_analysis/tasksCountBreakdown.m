function all_conds_task_group = tasksCountBreakdown(trialinfos, sinfo)

tasks = unique(sinfo.task);

trialinfos_bd = [];
cn_names_group_all = [];
for it = 1:length(tasks)
    cn_names_group = [];
    task = tasks{it};
    sinfo_tmp = sinfo(strcmp(sinfo.task, task),:);
    
    cn_names_all = [];
    cn_count_all = [];
    operators_all = [];
    for is = 1:size(sinfo_tmp,1)
        sbj_name = sinfo_tmp.sbj_name{is};
        cn_names = trialinfos.(task).(sbj_name).condNames;
        if strcmp(task, 'Calculia') == 1
            operators = trialinfos.(task).(sbj_name).operator;
            operators_all = [operators_all; operators];
        else
        end
        
        cn_names_all = [cn_names_all; cn_names];
        
        
        trialinfos_bd.(task).n_trials(is) = size(trialinfos.(task).(sbj_name),1);
    end
    cn_names_all(cellfun(@isempty, cn_names_all)) = [];
    
    if strcmp(task, 'Calculia') == 1
        operators_all(cellfun(@isempty, cn_names_all)) = [];
    end
    
    for ig = 1:length(cn_names_all)
        cn_names_group_tmp = [sinfo_tmp.task_group{1} '_' cn_names_all{ig}];
        
        switch task
            case {'VTCLoc','AllCateg','Logo','ReadNumWord', 'SevenHeaven', 'Scrambled'}
                if strcmp(cn_names_group_tmp, 'localizer_number') == 1
                    cn_names_group_tmp = 'localizer_numbers';
                elseif strcmp(cn_names_group_tmp, 'localizer_letter') == 1
                    cn_names_group_tmp = 'localizer_letters';
                elseif strcmp(cn_names_group_tmp, 'localizer_word') == 1
                    cn_names_group_tmp = 'localizer_words';
                elseif contains(cn_names_group_tmp, 'face') == 1
                    cn_names_group_tmp = 'localizer_faces';
                    
                end
                
                
                
                
            case 'Context'
                if contains(cn_names_group_tmp, 'letter') == 1
                    cn_names_group_tmp = 'calc_sequential_letter_add';
                elseif contains(cn_names_group_tmp, 'add') == 1 && ~contains(cn_names_group_tmp, 'letter') == 1
                    cn_names_group_tmp = 'calc_sequential_math_add';
                elseif contains(cn_names_group_tmp, 'sub') == 1 && ~contains(cn_names_group_tmp, 'letter') == 1
                    cn_names_group_tmp = 'calc_sequential_math_sub';
                end
                
            case 'Calculia'
                if contains(cn_names_group_tmp, 'digit') == 1 && operators_all(ig) == 1
                    cn_names_group_tmp = 'calc_sequential_math_add';
                elseif contains(cn_names_group_tmp, 'digit') == 1 && operators_all(ig) == -1
                    cn_names_group_tmp = 'calc_sequential_math_sub';
                elseif contains(cn_names_group_tmp, 'letter') == 1
                    cn_names_group_tmp = 'calc_sequential_letter_add';                    
                    
                end
            case 'Memoria'
                if contains(cn_names_group_tmp, 'math') == 1 
                    cn_names_group_tmp = 'calc_sequential_math_add';
                else
                end
                
            case 'UCLA'
                if contains(cn_names_group_tmp, 'episodic') == 1
                    cn_names_group_tmp = 'calc_simultaneous_autobio';
                elseif contains(cn_names_group_tmp, 'external-other') == 1 || contains(cn_names_group_tmp, 'external-Dis-other') == 1
                    cn_names_group_tmp = 'calc_simultaneous_other_external';
                elseif contains(cn_names_group_tmp, 'internal-other') == 1 || contains(cn_names_group_tmp, 'internal-dist-other') == 1
                    cn_names_group_tmp = 'calc_simultaneous_other_internal';
                elseif contains(cn_names_group_tmp, 'external-self') == 1
                    cn_names_group_tmp = 'calc_simultaneous_self_external';
                elseif contains(cn_names_group_tmp, 'internal-self') == 1
                    cn_names_group_tmp = 'calc_simultaneous_self_internal';
                elseif contains(cn_names_group_tmp, 'math') == 1
                    cn_names_group_tmp = 'calc_simultaneous_math_add';
                end
                
            case 'MMR'
                if contains(cn_names_group_tmp, 'self-external') == 1
                    cn_names_group_tmp = 'calc_simultaneous_self_external';
                elseif contains(cn_names_group_tmp, 'self-internal') == 1
                    cn_names_group_tmp = 'calc_simultaneous_self_internal';
                elseif contains(cn_names_group_tmp, 'other') == 1
                    cn_names_group_tmp = 'calc_simultaneous_other_internal';
                elseif contains(cn_names_group_tmp, 'math') == 1
                    cn_names_group_tmp = 'calc_simultaneous_math_add';
                end
                
            case 'MFA'
                if contains(cn_names_group_tmp, 'add') == 1
                    cn_names_group_tmp = 'calc_simultaneous_math_add';
                elseif contains(cn_names_group_tmp, 'mult') == 1
                    cn_names_group_tmp = 'calc_simultaneous_math_mult';
                end
        end
        cn_names_group{ig,1} = cn_names_group_tmp;
        
        
    end
    
    
    cn_names_all = cell2table(tabulate(cn_names_all));
    cn_names_all.Properties.VariableNames = {'condNames', 'count', 'pct'};
    cn_names_all.avg_per_sub = round(cn_names_all.count/size(sinfo_tmp,1));
    trialinfos_bd.(task).cond_names = cn_names_all;
    disp([task, ': ' num2str(size(sinfo_tmp,1))]);
    trialinfos_bd.(task).cond_names;
    cn_names_group_all = [cn_names_group_all;cn_names_group];
end

all_conds = cell2table(tabulate(cn_names_group_all))
all_conds.Properties.VariableNames = {'condNames', 'count', 'pct'};
all_conds.pct = []

task_groups = unique(sinfo.task_group);
for i = 1:length(task_groups)
    sinfo_tmp = sinfo(strcmp(sinfo.task_group, task_groups{i}),:);
    table_tmp = all_conds(contains(all_conds.condNames, task_groups{i}), :);
    table_tmp.avg_per_sub = round(table_tmp.count/size(sinfo_tmp,1));
    all_conds_task_group.(task_groups{i}) = sortrows(table_tmp, 'count', 'descend');
    all_conds_task_group.(task_groups{i})
end

end

