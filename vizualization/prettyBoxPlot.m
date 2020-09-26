function prettyBoxPlot(expdata, expdata_colors, expdata_labels, expdata_title, varargin)
%% Pretty boxplot


%% Get arguments varargin
[pvalues, positions, connect_lines] = parseArgs(varargin);

% Plot
if isempty(positions)
    positions_boxplot = [1 1.2 1.5 1.7 2 2.2];
else
    positions_boxplot = positions; 
end


boxplot(expdata, 'Labels', expdata_labels, 'Positions', positions_boxplot)
title(expdata_title)
% axis square
set(gca, 'FontSize', 20)
line_width = 2;
set(gca, 'XTickLabelRotation', 45)

% Trim
set(findobj(gcf, 'Type', 'Line'), 'LineStyle', '-');
set(findobj(gcf, 'Type', 'Line', 'Tag', 'Outliers'), 'LineStyle', 'none');
set(findobj(gcf, 'Type', 'Line', 'Tag', 'Upper Adjacent Value'), 'LineStyle', 'none');
set(findobj(gcf, 'Type', 'Line', 'Tag', 'Lower Adjacent Value'), 'LineStyle', 'none');
set(findobj(gcf, 'Tag', 'Outliers'), 'Marker', 'none');

% Correct line widthplor
set(findobj(gcf, 'Type', 'Line'), 'LineWidth', line_width);

% Get objects
boxes = findobj(gca,'Tag','Box');
upper_line = findobj(gcf, 'Type', 'Line', 'Tag', 'Upper Whisker');
lower_line = findobj(gcf, 'Type', 'Line', 'Tag', 'Lower Whisker');
median_lines = findobj(gcf, 'Type', 'Line', 'Tag', 'Median');

% Patch boxes
for i=1:length(boxes)
    patch(get(boxes(i),'XData'),get(boxes(i),'YData'),'y','FaceAlpha',.5, 'FaceColor', expdata_colors(i,:));
    boxes(i).Color = expdata_colors(i,:);
    upper_line(i).Color = expdata_colors(i,:);
    lower_line(i).Color = expdata_colors(i,:);
end

% Plot back the median lines
for i=1:length(median_lines)
    hold on
    plot(median_lines(i).XData, median_lines(i).YData, 'LineWidth', 2, 'Color', [1 1 1])
end

% Plot actual data points
xticks_plot = get(gca,'Xtick');
for i=1:length(xticks_plot)
    plt = scatter(repmat(xticks_plot(i), length(expdata(:,1)),1), expdata(:,i), 'Filled','SizeData',60, 'MarkerFaceColor', expdata_colors(end+1-i,:), 'MarkerEdgeColor', 'none');
    alpha(plt, .3)
end

% Plot connect lines
if connect_lines == 't';
    for i = 1:length(expdata) 
        line([positions(1) positions(2)], [expdata(i,1) expdata(i,2)], 'Color', [.5 .5 .5])
    end
else
end


%% Pvalues
count = 1;
if ~isempty(pvalues)
    % Plot actual points
    for i=1:length(pvalues)
        if pvalues(i) < 0.05/size(expdata,2) && pvalues(i) > 0.01/size(expdata,2)/(length(positions_boxplot)/2);
           ptext = '*';
        elseif pvalues(i) < 0.01/size(expdata,2)/2 && pvalues(i) > 0.001/size(expdata,2)/(length(positions_boxplot)/2);
           ptext = '**';
        elseif pvalues(i) < 0.001/size(expdata,2)/(length(positions_boxplot)/2);
           ptext = '***';   
        else
           ptext = ''; 
        end
        text(mean([xticks_plot(count), xticks_plot(count+1)]), max(max(expdata(:,count:count+1)))*1.1,ptext, 'FontSize', 20, 'HorizontalAlignment', 'center') 
        count = count + 2;
    end
end


%% Parse args
    function [pvalues, positions, connect_lines] = parseArgs(args)
        % Prelocate args
        pvalues = [];
        positions = [];
        connect_lines = [];
        args = stripArgs(args);
        while ~isempty(args)
            switch(lower(args{1}))
                case 'pvalues'
                    pvalues = args{2};
                    args = args(2:end);
                case 'positions'
                    positions = args{2};
                    args = args(2:end);  
                case 'connect_lines'
                    connect_lines = args{2};
                    args = args(2:end); 
                otherwise
                    error('Unsupported argument "%s"!', args{1});
            end
            args = stripArgs(args(2:end));
        end 
    end

end

