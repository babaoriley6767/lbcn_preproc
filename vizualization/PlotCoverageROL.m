function PlotCoverageROL(dirs, project_name, elinfo, ROLs, cfg)



%% Load comon brain
% load([dirs.code_root filesep 'vizualization/Colin_cortex_left.mat']);
% cmcortex.left = cortex;
% load([dirs.code_root filesep 'vizualization/Colin_cortex_right.mat']);
% cmcortex.right = cortex;
fsaverage_dir = '/Applications/freesurfer/subjects/fsaverage/surf'; % correct that:'/Applications/freesurfer/freesurfer/subjects/fsaverage/surf/rh.pial'
if strcmp(cfg.Cortex, 'MNI')
    [cmcortex.right.vert cmcortex.right.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['rh.' 'pial']));
    [cmcortex.left.vert cmcortex.left.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['lh.' 'pial']));
elseif  strcmp(cfg.Cortex, 'native')
    cmcortex = subjVar.cortex;
else
    error('you must specify the cortical space to plot, either MNI or native.')
end

% basic parameters:
decimate = true;
final_fs = 50;

% Get color indices
[col_idx,colors_plot] = colorbarFromValues(ROLs, cfg.Colormap, [], false);


%% Plot electrodes as dots in native space
marker_size = cfg.MarkerSize;
figureDim = [0 0 1 1];
% figureDim = [0 0 1 .4];

f1 = figure('units', 'normalized', 'outerposition', figureDim);


views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right', 'left', 'right'};

views = {'lateral', 'dorsal', 'ventral'};
hemis = {'left', 'left', 'left'};

views = {'lateral', 'lateral', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right'};

for i = 1:length(views)
    subplot(2,2,i)
    coords_plot = CorrectElecLoc(elinfo.MNI_coord, views{i}, hemis{i}, cfg.CorrectFactor);
    ctmr_gauss_plot(cmcortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
    
    for ii = 1:length(coords_plot)
        % Only plot on the relevant hemisphere
        if ~isnan(col_idx(ii))
            if (strcmp(hemis{i}, 'left') == 1 && strcmp(elinfo.LvsR(ii), 'R') == 1) || (strcmp(hemis{i}, 'right') == 1 && strcmp(elinfo.LvsR(ii), 'L') == 1)
            else
                plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', colors_plot(col_idx(ii),:), 'MarkerEdgeColor', 'k');
            end
            %                 plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', colors_plot(col_idx(ii),:), 'MarkerEdgeColor', 'k');
        else
        end
    end
    alpha(cfg.alpha)
end
if cfg.save
    savePNG(gcf, 300, [dirs.result_root filesep 'selectivity' filesep 'group_selectivity4_' project_name '_' cortex_space '.png']); % ADD TASK AND CONDITION
    close all
else
end
end