function CompareBadEpochs(be, data_CAR, data, datatype, bn, el, globalVar)

%% Average across frequencies in case of Spec
if strcmp(datatype, 'Spec')
    data.wave = squeeze(nanmean(abs(data.wave),1));
else
end

fieldnames_be = fieldnames(be);

%% Define plot parameters
line_width = 0.5;
font_size = 8;

figureDim = [0 0 .5 .5];
figure('units', 'normalized', 'outerposition', figureDim)

order_subplots = [1 3 5 7 9 2 4 6 8 10];

for i = 1:length(fieldnames_be)
    subplot(length(fieldnames_be),2,order_subplots(i))
    
    if ismember(1, be.(fieldnames_be{i})) && ismember(0, be.(fieldnames_be{i}))
        plot(data_CAR.time, data_CAR.wave(be.(fieldnames_be{i}) == 1,:), 'Color', 'r', 'LineWidth', line_width)
        hold on
        plot(data_CAR.time, data_CAR.wave(be.(fieldnames_be{i}) == 0,:), 'Color', 'k', 'LineWidth', line_width)
    elseif ~ismember(1, be.(fieldnames_be{i}))
        plot(data_CAR.time, data_CAR.wave(be.(fieldnames_be{i}) == 0,:), 'Color', 'k', 'LineWidth', line_width)
    elseif ~ismember(0, be.(fieldnames_be{i}))
        plot(data_CAR.time, data_CAR.wave(be.(fieldnames_be{i}) == 1,:), 'Color', 'r', 'LineWidth', line_width)
    end
    
    title([fieldnames_be{i} ' Raw data'], 'Interpreter', 'none');
    xlim([data_CAR.time(1) data_CAR.time(end)])
    set(gca,'LineWidth',2,'FontSize',font_size);
end


for i = 1:length(fieldnames_be)
    subplot(length(fieldnames_be),2,order_subplots(i+length(fieldnames_be)))
    
    if ismember(1, be.(fieldnames_be{i})) && ismember(0, be.(fieldnames_be{i}))
        plot(data.time, data.wave(be.(fieldnames_be{i}) == 1,:), 'Color', 'r', 'LineWidth', line_width)
        hold on
        plot(data.time, data.wave(be.(fieldnames_be{i}) == 0,:), 'Color', 'k', 'LineWidth', line_width)
    elseif ~ismember(1, be.(fieldnames_be{i}))
        plot(data_CAR.time, data_CAR.wave(be.(fieldnames_be{i}) == 0,:), 'Color', 'k', 'LineWidth', line_width)
    elseif ~ismember(0, be.(fieldnames_be{i}))
        plot(data_CAR.time, data_CAR.wave(be.(fieldnames_be{i}) == 1,:), 'Color', 'r', 'LineWidth', line_width)
    end
    
    title([fieldnames_be{i} ' ' datatype], 'Interpreter', 'none');
    xlim([data.time(1) data.time(end)])
    set(gca,'LineWidth',2,'FontSize',font_size);
end
set(gcf,'color','w');


% Save figure
% savePNG(gcf, 200, sprintf('%s/EpochData/bad_epochs_%s_%i.png', dir_CAR, bn, el));

fdir = sprintf('%s/EpochData',globalVar.CARData);
if ~exist(fdir)
    mkdir(fdir)
end
fn = sprintf('%s/bad_epochs_%s_%s_%i.tiff',fdir,bn,datatype,el);
f = getframe(gcf);
imwrite(f.cdata,fn, 'Resolution', 36)

close all

end

