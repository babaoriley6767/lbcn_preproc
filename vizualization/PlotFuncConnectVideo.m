function F = PlotFuncConnectVideo(subjVar,corr_plot, coords_plot, cfg)
marker_size = 10;

MarkerFaceColor = 'k';
MarkerEdgeColor = 'w';

figureDim = [0 0 1 .5];

corr_vals = corr_plot(find(triu(corr_plot,1)));
[col_idx,cols] = colorbarFromValues(corr_vals, 'RedBlue',[-0.1 .4],true);

% figure('units', 'normalized', 'outerposition', figureDim)

hemis = {'left', 'left', 'left'};

hemi = hemis{1};
for e = 1:length(cfg.loc_views)
    ctmr_gauss_plot(subjVar.cortex.(hemi),[0 0 0], 0, hemi, 'lateral')
    loc_view(0+cfg.loc_views(e),0)
    set(gcf,'Color',[0.1 0.1 0.1])
%     hold on
    for ii = 1:length(coords_plot)
        if (strcmp(hemi, 'left') && strcmpi(subjVar.elinfo.LvsR{ii},'L'))
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', MarkerFaceColor, 'MarkerEdgeColor', MarkerEdgeColor);
        elseif (strcmp(hemi, 'right') && strcmpi(subjVar.elinfo.LvsR{ii},'R'))
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', MarkerFaceColor, 'MarkerEdgeColor', MarkerEdgeColor);
        end
    end
     alpha(cfg.alpha)
    
    %% Connect dots
    count = 0;
    for ii = 1:length(coords_plot)%length(coords_plot)
        for iii = 1:length(coords_plot)%length(coords_plot)
            if ii < iii
                count = count + 1;
                a_ii(count) = ii;
                a_iii(count) = iii;
                plot3([coords_plot(ii,1) coords_plot(iii,1)], [coords_plot(ii,2) coords_plot(iii,2)], [coords_plot(ii,3) coords_plot(iii,3)],  'Color', cols(col_idx(count),:), 'LineWidth', col_idx(count)/10)
            else
            end
        end
    end
    F(e) = getframe(gcf);
    close all
end

end

