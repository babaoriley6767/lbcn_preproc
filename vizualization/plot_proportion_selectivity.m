function plot_proportion_selectivity(el_selectivity, task, cond_names, brain_group, brain_group_list)
%%
%cond_names = {'math', 'memory'};
%brain_group_list = {'Frontoparietal', 'Dorsal Attention', 'Default', 'Limbic',  'Ventral Attention','Visual', 'Somatomotor'};
%brain_group = 'Yeo7'
load('cdcol_2018.mat')
el_selectivity = simplify_selectivity(el_selectivity, task);


frequencies = [];
for i = 1:length(cond_names)
    tmp = el_selectivity(contains(el_selectivity.elect_select, cond_names{i}),:);
    tmp = sort_tabulate(tmp.(brain_group), 'descend');
    for in = 1:length(brain_group_list)
        frequencies(i,in) = tmp{strcmp(tmp.value, brain_group_list{in}), 2};
    end
end
frequencies = frequencies'

% frequencies = flip(frequencies');
[frequencies, idx] = sortrows(frequencies, 1, 'descend')
frequencies = flip(frequencies);
brain_group_list = brain_group_list(idx)
brain_group_list = flip(brain_group_list)

ba = barh(frequencies, 'stacked' ,'EdgeColor', 'k','LineWidth',2)
ba(1).FaceColor = cdcol.light_cadmium_red;
ba(2).FaceColor = cdcol.sapphire_blue

set(gca,'fontsize',16)
xlabel('Number of electrodes')
yticks(1:length(brain_group_list))
ylim([0, length(brain_group_list)+1])
yticklabels(brain_group_list)
set(gca,'TickLabelInterpreter','none')

for i = 1:length(cond_names)
    for in = 1:length(brain_group_list)
        if i == 1
            txt = text(frequencies(in,i)-1,in, num2str(frequencies(in,i)), 'FontSize', 20, 'HorizontalAlignment', 'right', 'Color', 'w');
        elseif i > 1
            txt = text(frequencies(in,i)+sum(frequencies(in,1:i-1))-1,in, num2str(frequencies(in,i)), 'FontSize', 20, 'HorizontalAlignment', 'right', 'Color', 'w');
        end
    end
end
title('Frequency of math vs. memory only sites per intrinsic network')


end

