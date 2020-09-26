function plot_frequency(data, column, order, orientation)

data = sort_tabulate(data.(column), order);
if strcmp(orientation, 'horizontal') == 1
    barh(data.count, 'FaceColor','w','EdgeColor', 'k','LineWidth',2)
elseif strcmp(orientation, 'vertical') == 1
    bar(data.count, 'FaceColor','w','EdgeColor', 'k','LineWidth',2)
else
end
set(gca,'fontsize',16)
xlabel('Number of electrodes')
yticks(1:length(data.value))
ylim([0, length(data.value)+1])
yticklabels(data.value)
set(gca,'TickLabelInterpreter','none')
for i = 1:size(data,1)
    txt = text(data.count(i)-1,i, num2str(data.count(i)), 'FontSize', 16, 'HorizontalAlignment', 'right');
end
axis square


end

