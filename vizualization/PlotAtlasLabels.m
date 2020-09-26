function PlotAtlasLabels(subjVar,cfg)
% This function plots any information from subjVar.elinfo onto native
% brain. An example to plot channel numbers on native brain:
% cfg can be arranged like this: 
%   cfg=[];
%   cfg.views = {'lateral', 'medial', 'ventral', 'dorsal','posterior','lateral', 'medial', 'ventral', 'dorsal','posterior'};
%   cfg.hemis = {'left', 'left', 'left', 'left', 'left', 'right', 'right', 'right', 'right', 'right'};
%   % cfg.views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral', 'dorsal','dorsal'};
%   % cfg.hemis = {'left', 'right', 'left', 'right', 'left', 'right','left', 'right'};
%   cfg.label_fontsize = 10;
%   cfg.plot_label = 'chan_num';
%   cfg.correction_factor = 0;
% subjVar should contain elinfo table. Any column from elinfo can be used
% to plot on brain as text.


load('cdcol_2018.mat');
marker_size = 2;
figureDim = [0 0 1 1];

figure('units', 'normalized', 'outerposition', figureDim)

if strcmp(cfg.plot_label,'numbers')
    for i = 1:size(subjVar.elinfo,1)
        subjVar.elinfo.numbers{i} = num2str(i);
    end
else
end


% Define subplot dims
if isprime(length(cfg.views)) && length(cfg.views) < 7
    subplot_dim = [ceil(sqrt(length(cfg.views))), 1];
elseif length(cfg.views) == 6
    subplot_dim = [3 2];
elseif length(cfg.views) == 8
    subplot_dim = [2 4];
elseif length(cfg.views) == 10
    subplot_dim = [2 5];
else
    subplot_dim = [ceil(sqrt(length(cfg.views))), ceil(sqrt(length(cfg.views)))];
end


for i = 1:length(cfg.views)
    subplot(subplot_dim(1), subplot_dim(2),i)
    coords_plot = CorrectElecLoc(subjVar.elinfo.LEPTO_coord, cfg.views{i}, cfg.hemis{i}, cfg.correction_factor);
    ctmr_gauss_plot(subjVar.cortex.(cfg.hemis{i}),[0 0 0], 0, cfg.hemis{i}, cfg.views{i})
    for ii = 1:length(coords_plot)
        % Only plot on the relevant cfg.hemisphere
        if (strcmp(cfg.hemis{i}, 'left') && strcmpi(subjVar.elinfo.LvsR{ii},'L'))
            %plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', cdcol.light_cadmium_red, 'MarkerEdgeColor', cdcol.light_cadmium_red);
            if ~contains(subjVar.elinfo.FS_label(ii),'empty') && ~strcmp(subjVar.elinfo.Destr_ind(ii),'Depth')
                if ~isnumeric(subjVar.elinfo.(cfg.plot_label)(ii))  % Because chan_num is numeric, I needed to add this in order not to get an error
                    txt=subjVar.elinfo.(cfg.plot_label)(ii);
                else
                    txt=num2str(subjVar.elinfo.(cfg.plot_label)(ii));
                end
                text(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), txt, 'FontSize', cfg.label_fontsize, 'FontWeight', 'bold', 'Color', 'r', 'HorizontalAlignment', 'center');
            else
            end
        elseif (strcmp(cfg.hemis{i}, 'right') && strcmpi(subjVar.elinfo.LvsR{ii},'R'))
            %plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', cdcol.light_cadmium_red, 'MarkerEdgeColor', cdcol.light_cadmium_red);
            if ~contains(subjVar.elinfo.FS_label(ii),'empty') && ~strcmp(subjVar.elinfo.Destr_ind(ii),'Depth')
                if ~isnumeric(subjVar.elinfo.(cfg.plot_label)(ii))  % Because chan_num is numeric, I needed to add this in order not to get an error
                    txt=subjVar.elinfo.(cfg.plot_label)(ii);
                else
                    txt=num2str(subjVar.elinfo.(cfg.plot_label)(ii));
                end
                text(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), txt, 'FontSize', cfg.label_fontsize, 'FontWeight', 'bold', 'Color', 'r', 'HorizontalAlignment', 'center');
            else
            end
        end
        
    end
    alpha(0.7)
end


end
%% Function to optimize electrode location for plotting
function coords_plot = CorrectElecLoc(coords, views, hemisphere, correction_factor)
coords_plot = coords;
switch views
    case 'lateral'
        if strcmp(hemisphere, 'right')
            coords_plot(:,1) = coords_plot(:,1) + correction_factor;
        elseif strcmp(hemisphere, 'left')
            coords_plot(:,1) = coords_plot(:,1) - correction_factor;
        end
    case 'medial'
        if strcmp(hemisphere, 'right')
            coords_plot(:,1) = coords_plot(:,1) - correction_factor;
        elseif strcmp(hemisphere, 'left')
            coords_plot(:,1) = coords_plot(:,1) + correction_factor;
        end
    case 'ventral'
        coords_plot(:,3) = coords_plot(:,3) - correction_factor;
end
end