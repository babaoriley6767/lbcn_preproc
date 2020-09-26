function PlotElectDensityMap(elinfo_all,cfgl)


% define colormap correct for label Yeo 0
switch cfgl.atlas
    case 'DK_ind'
        cm_plot = 'YLGnBu';
    case 'Destr_ind'
        cm_plot = 'YLGnBu';        
    case 'Yeo_ind'
        cm_plot = 'YLOrRd';
        elinfo_all.Yeo_ind7(find(strcmp(elinfo_all.Yeo_ind7, '0'))) = {'1'};
end


hemis = {'L', 'R'};
for i = 1:length(hemis)
    elinfo_tmp = elinfo_all;
    elinfo_tmp = elinfo_tmp(strcmp(elinfo_tmp.WMvsGM, 'GM'),:);
    
    
    switch cfgl.atlas
        case 'DK_ind'
            elinfo_tmp = elinfo_tmp(~strcmp(elinfo_tmp.DK_ind, 'undefined'),:);
        case 'Destr_ind'
            elinfo_tmp = elinfo_tmp(~isnan(cellfun(@str2double, elinfo_tmp.Destr_ind)),:);
        otherwise
    end
    
    elinfo.(hemis{i}) = elinfo_tmp(strcmp(elinfo_tmp.LvsR, hemis{i}), :);
    freq_lab_tpm = tabulate(elinfo.(hemis{i}).(cfgl.atlas));
    freq_lab = cell2mat(freq_lab_tpm(:,2));
    lab = cellfun(@str2num, freq_lab_tpm(:,1));
    
    if strcmp(cfgl.atlas, 'DK_ind')
        nan_tmp = nan(length(freq_lab)+2,1);
        nan_tmp(3:end) = freq_lab;
        freq_lab = nan_tmp;
        freq_lab(1) = 0; freq_lab(2) = 0;
        
        nan_tmp = nan(length(lab)+2,1);
        nan_tmp(3:end) = lab;
        lab = nan_tmp;
        lab(1) = 0; lab(2) = 1;
    else
    end
    
    [~, idx] = sort(freq_lab);
    lab_final.(hemis{i}) = lab(idx);
    freq_lab_final.(hemis{i}) = freq_lab(idx);
    
    switch cfgl.atlas
        case 'Destr_ind'
            if length(lab_final.(hemis{i})) < 76
                missing_labs = setdiff(1:76, lab_final.(hemis{i}));
                lab_final.(hemis{i}) = [lab_final.(hemis{i}) ; missing_labs'];
                freq_lab_final.(hemis{i}) = [freq_lab_final.(hemis{i}) ; zeros(length(missing_labs),1,1)];
            else
            end
        otherwise
    end
    
    
    
end
% concat left and right labels and freqs
lab_final.R = lab_final.R + 100;
freq_lab = [freq_lab_final.L; freq_lab_final.R];
lab = [lab_final.L; lab_final.R];

[col_idx,cols] = colorbarFromValues(freq_lab, cm_plot, [], false);
cols = flip(cols);
[~, idx] = sort(lab);

cols_f = [];
for i = 1:size(col_idx,1)
    cols_f(i,:) = cols(col_idx(i),:);
end
freq_lab = freq_lab(idx);
cols = cols_f(idx,:);
lab = lab(idx);
colsh.L = cols(lab<100,:);
colsh.R = cols(lab>99,:);



cfg=[];
cfg.elecCoord = 'n';
cfg.view='l';
switch cfgl.atlas
    case 'DK_ind'
        cfg.overlayParcellation='DK';
    case 'Yeo_ind'
        cfg.overlayParcellation='Y7';
    case 'Destr_ind'
        cfg.overlayParcellation='D';        
end
cfg.surfType = 'pial'; % 'pial'

cfg.title= []; 
cfg.fsurfSubDir = '/Applications/freesurfer/subjects/';
cfg.ignoreDepthElec = 'n';

% plot parameters
figure('units', 'normalized', 'outerposition', [0 0 .4 1])
views = {'l', 'r', 'lm', 'rm', 'li', 'ri'};
marker_size = 3;


for hi = 1:2
    if hi == 1
        ip = 1:2:length(views);
    else
        ip = 2:2:length(views);
    end
    cfg.parcellationColors = colsh.(hemis{hi})*255; %cool(76)*255%[] %cdcol_reshape(randsample(length(cdcol_reshape),76),:)
    for i = ip
        cfg.view = views{i};
        subplot(3,2,i)
        cfgOut=plotPialSurfCustom('fsaverage',cfg);
        if cfgl.plot_elects
            alpha(0.3)
            for ii = 1:size(elinfo.(hemis{hi}),1)
                plot3(elinfo.(hemis{hi}).MNI_coord(ii,1),elinfo.(hemis{hi}).MNI_coord(ii,2),elinfo.(hemis{hi}).MNI_coord(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', colsh.(hemis{hi})(str2num(elinfo.(hemis{hi}).(cfgl.atlas){ii}),:), 'MarkerEdgeColor', colsh.(hemis{hi})(str2num(elinfo.(hemis{hi}).(cfgl.atlas){ii}),:), 'LineWidth', 0.1);
            end
        else
        end
    end
end


if cfgl.save_plot 
   
    if cfgl.plot_elects
        savePNG(gcf,400, [cfgl.dir_save_plot 'density_map_' cfgl.atlas 'plot_elects.png'])
    else
        savePNG(gcf,400, [cfgl.dir_save_plot 'density_map_' cfgl.atlas '.png'])
    end
    
    close all
    % plot correspondent colorbar
    cb = colorbar;
    colormap(cbrewer2(cm_plot));
    cb.Ticks = [0 1];
    cb.TickLabels = {num2str(min(freq_lab)), num2str(max(freq_lab))};
    cb.FontSize = 20;
    cb.Location = 'southoutside';
    cb.Label.String = 'number of electrodes';
    set(gcf,'units', 'normalized', 'outerposition', [0 0 .2 1]) % [0 0 .6 .3]
    savePNG(gcf,400, [cfgl.dir_save_plot 'density_map_' cfgl.atlas 'colorbar.png'])
    
else
end

end

