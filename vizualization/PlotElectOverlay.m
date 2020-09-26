function PlotElectOverlay(subjVar,cfgl)

% Get coords
elinfo = subjVar.elinfo;

% define colormap correct for label Yeo 0
switch cfgl.atlas
    case 'DK_ind'
        cm_plot = 'YLGnBu';
    case 'Destr_ind'
        cm_plot = 'YLGnBu';        
    case 'Yeo7_ind'
        cm_plot = 'YLOrRd';
        elinfo.Yeo7_ind(find(strcmp(elinfo.Yeo7_ind, '0'))) = {'1'};
        len_cols = length(unique(elinfo.Yeo7_ind));
        cols = hsv(len_cols+1);
end

colsh.L = cols;
colsh.R = cols;

cfg=[];
cfg.elecCoord = 'n';
cfg.view='l';
switch cfgl.atlas
    case 'DK_ind'
        cfg.overlayParcellation='DK';
    case 'Yeo7_ind'
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
marker_size = 6;

hemis = {'L', 'R'};

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
            alpha(0.5)
            for ii = 1:size(elinfo,1)
                plot3(elinfo.MNI_coord(ii,1),elinfo.MNI_coord(ii,2),elinfo.MNI_coord(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k', 'LineWidth', 0.1);
            end
        else
        end
    end
end


if cfgl.save_plot 
   
    if cfgl.plot_elects
        savePNG(gcf,400, [cfgl.dir_save_plot 'overlay_' cfgl.atlas 'plot_elects.png'])
    else
        savePNG(gcf,400, [cfgl.dir_save_plot 'overlay_' cfgl.atlas '.png'])
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

