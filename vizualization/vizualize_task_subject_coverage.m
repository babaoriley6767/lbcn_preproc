function vizualize_task_subject_coverage(sinfo, task_column)
% Vizualize task per subject

subjects = unique(sinfo.sbj_name);
subjects_unique = unique(subjects);
length(subjects_unique)

tasks = tabulate(sinfo.(task_column));
[~, idx] = sort(vertcat(tasks{:,2}), 'descend');
tasks = tasks(idx,1);

tasks = {'calc_simultaneous', 'calc_sequential', 'localizer'};

tasks_all = zeros(length(subjects_unique), length(tasks));
for i = 1:length(subjects_unique)
    s = subjects_unique{i};
    sinfo_tmp = sinfo(strcmp(sinfo.sbj_name, s),:);
    for it = 1:length(tasks)
        if sum(contains(sinfo_tmp.(task_column), tasks(it))) > 0
            tasks_all(i,it) = 1;
        else
        end
    end    
end

tasks_all = sortrows(tasks_all, 1:3, 'ascend');

colors = hsv(length(tasks));

back_colour = [.4 .4 .4];
back_colour_mark = [.7 .7 .7];

hold on
for i = 1:size(tasks_all,1)
    for ii = 1:size(tasks_all,2)
        if tasks_all(i, ii) == 1
            plot(ii, i, 'square', 'MarkerSize', 10, 'MarkerFaceColor', colors(ii,:), 'MarkerEdgeColor', back_colour)
        else
            plot(ii, i, 'square', 'MarkerSize', 10, 'MarkerFaceColor', 'w', 'MarkerEdgeColor', back_colour, 'LineWidth', 0.01)
        end
    end
end
xlim([1, size(tasks_all,2)])
ylim([0, size(tasks_all,1)+1])
axis off
set(gcf,'color', 'w')

tabulate(sinfo.(task_column))
end

