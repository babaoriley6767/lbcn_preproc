function PlotCoverageElect(subjVar, cfg)
% This function plots the electrodes on native brain, requiring only
% subjVar (which should have elinfo table), correction factor (default: 0)
% and ifsave (true/false) to save the plots to savefold 
% (savefold/Individual_Coverage/[subj_name]).


load('cdcol_2018.mat')
marker_size = cfg.MarkerSize;
marker_size_high = cfg.MarkerSize_chan_highlight;



MarkerFaceColor = cdcol.light_cadmium_red;
MarkerFaceColor_high = MarkerFaceColor;


% % [0.1 0.1 0.1];
% if isempty(cfg.highlight_col)
%     MarkerFaceColor_high = cfg.highlight_col;
% else
%     MarkerFaceColor_high = repmat([1 0 0],length(cfg.chan_highlight),1);
% end
% 





for i = 1:size(subjVar.elinfo,1)
    elec_init{i} =  subjVar.elinfo.FS_label{i}(1:2);
end
elec_init = unique(elec_init);
cols = hsv(length(elec_init));

for i = 1:size(subjVar.elinfo,1)
    init = subjVar.elinfo.FS_label{i}(1:2);
    MarkerFaceColor(i,:) = cols(find(strcmp(init, elec_init)),:);
    MarkerFaceColor(i,:) = [0 0 0];

    
end


figure('units', 'normalized', 'outerposition', cfg.figureDim)

% figure('units', 'normalized', 'outerposition', figureDim)
% cfg.views = {'lateral', 'anterior', 'posterior'};
% cfg.views = {'lateral', 'ventral', 'temporal', 'lateral', 'ventral', 'temporal'};
% cfg.views = {'lateral', 'ventral', 'medial'};

% if ~isempty(cfg.chan_highlight)
%     if strcmp(subjVar.elinfo.LvsR{cfg.chan_highlight}, 'L')
%         cfg.hemis = {'left','left','left'};
%     else
%         cfg.hemis = {'right', 'right', 'right'};
%     end
% else
% end

 
% 
% if strcmp(subjVar.elinfo.LvsR{cfg.chan_highlight}, 'L')
%     cfg.hemis = {'left','left','left'};
% else
%     cfg.hemis = {'right', 'right', 'right'};
% end
% 
% cfg.views = {'lateral', 'lateral', 'posterior', 'posterior'};
% cfg.hemis = {'left', 'right', 'left', 'right'};

% cfg.views = {'lateral', 'ventral'}
% cfg.hemis = {'left', 'left'};

% 
% if nargin == 1
%     correction_factor = 0;
%     ifsave = false;
% elseif nargin == 2
%     ifsave = false;
% elseif nargin == 3 && ifsave == true
%     savefold = uigetdir('/Volumes/');
% end

for i = 1:length(cfg.views)
       subplot(cfg.subplots(1),cfg.subplots(2),i)
%     subplot(1,2,i)    
    
    coords_plot = CorrectElecLoc(subjVar.elinfo.LEPTO_coord, cfg.views{i}, cfg.hemis{i}, cfg.correction_factor);
    ctmr_gauss_plot(subjVar.cortex.(cfg.hemis{i}),[0 0 0], 0, cfg.hemis{i}, cfg.views{i})
    
    for ii = 1:length(coords_plot)
        if (strcmp(cfg.hemis{i}, 'left') && strcmpi(subjVar.elinfo.LvsR{ii},'L'))
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), '.', 'MarkerSize', marker_size, 'MarkerFaceColor', MarkerFaceColor(ii,:), 'MarkerEdgeColor', MarkerFaceColor(ii,:));
        elseif (strcmp(cfg.hemis{i}, 'right') && strcmpi(subjVar.elinfo.LvsR{ii},'R'))
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), '.', 'MarkerSize', marker_size, 'MarkerFaceColor', MarkerFaceColor(ii,:), 'MarkerEdgeColor', MarkerFaceColor(ii,:));
        end
    end
    
    if ~isempty(cfg.chan_highlight)
        for hi = 1:length(cfg.chan_highlight)
            if (strcmp(cfg.hemis{i}, 'left') && strcmpi(subjVar.elinfo.LvsR{cfg.chan_highlight(hi)},'L'))
                plot3(coords_plot(cfg.chan_highlight(hi),1),coords_plot(cfg.chan_highlight(hi),2),coords_plot(cfg.chan_highlight(hi),3), 'o', 'MarkerSize', marker_size_high, 'MarkerFaceColor', cfg.highlight_col(hi,:), 'MarkerEdgeColor',  cfg.highlight_col(hi,:));
            elseif (strcmp(cfg.hemis{i}, 'right') && strcmpi(subjVar.elinfo.LvsR{cfg.chan_highlight(hi)},'R'))
                plot3(coords_plot(cfg.chan_highlight(hi),1),coords_plot(cfg.chan_highlight(hi),2),coords_plot(cfg.chan_highlight(hi),3), 'o', 'MarkerSize', marker_size_high, 'MarkerFaceColor', cfg.highlight_col(hi,:), 'MarkerEdgeColor', cfg.highlight_col(hi,:));
            else
            end
        end
    end
        
    alpha(cfg.alpha)
end

% if ifsave
%     if ~exist([savefold filesep 'Individual_Coverage'],'dir')
%         mkdir([savefold filesep 'Individual_Coverage'])
%     end
%     savePNG(gcf, 300, [savefold filesep 'Individual_Coverage' filesep subjVar.sbj_name '_coverage.png']);
%     close all
% end
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


%
%
%
%
%
% if plot_label
%         for it = 1:length(coords_plot)
%             hold on
%             if (strcmp(cfg.hemis{i}, 'left') == 1 && coords_plot(ii,1) > 0) || (strcmp(cfg.hemis{i}, 'right') == 1 && coords_plot(ii,1) < 0)
%             else
%                 text(coords_plot(it,1),coords_plot(it,2),coords_plot(it,3), subjVar.labels(it), 'FontSize', 7);
%             end
%         end
%     else
%     end