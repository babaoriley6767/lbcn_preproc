function PlotCoverageGroup(coords, cfg)


%% Load comon brain (replace by fsaverage)
% load([dirs.code_root filesep 'vizualization/Colin_cortex_left.mat']);
% cmcortex.left = cortex;
% load([dirs.code_root filesep 'vizualization/Colin_cortex_right.mat']);
% cmcortex.right = cortex;
%
%
% [DOCID,GID] = getGoogleSheetInfo('math_network', project_name);
% googleSheet = GetGoogleSpreadsheet(DOCID, GID);
% implant = googleSheet.implant{strcmp(googleSheet.subject_name, sbj_name)};

if ~isempty(cfg.chan_highlight)
    coords_hi = coords(cfg.chan_highlight,:);
else
end


if isfield(cfg, 'MarkerFaceColor')
else
    cfg.MarkerFaceColor = repmat([0 0 0], size(coords.MNI_coord, 1),1);
    cfg.MarkerEdgeColor = cfg.MarkerFaceColor;
end



[cmcortex.right.vert cmcortex.right.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['rh.' 'pial']));
[cmcortex.left.vert cmcortex.left.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['lh.' 'pial']));


%% Plot electrodes as dots in native space
% views = {'lateral', 'lateral', 'ventral', 'ventral'};
% hemis = {'left', 'right', 'left', 'right'};

views = {cfg.lobe, cfg.lobe};
hemis = {'left', 'right'};
figure('units', 'normalized', 'outerposition', [0 0 1 1]); %[0 0 .5 .5]

for i = 1:length(views)
    subplot(1,2,i)
    coords_plot = CorrectElecLoc(coords.MNI_coord, views{i}, hemis{i}, cfg.correction_factor);
    if ~isempty(cfg.chan_highlight)
        coords_plot_hi = coords_plot(cfg.chan_highlight,:);
    end
    ctmr_gauss_plot(cmcortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
    
    for ii = 1:length(coords_plot)
        % Only plot on the relevant hemisphere
        if sum(ii == cfg.chan_highlight) == 0
            if (strcmp(hemis{i}, 'left') == 1 && strcmp(coords.LvsR{ii}, 'L')) || (strcmp(hemis{i}, 'right') == 1 && strcmp(coords.LvsR{ii}, 'R'))
                plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', cfg.MarkerSize, 'MarkerFaceColor', cfg.MarkerFaceColor(ii,:), 'MarkerEdgeColor', cfg.MarkerEdgeColor(ii,:));
            end
        end
    end
    % plot the highlight
    if ~isempty(cfg.chan_highlight)
        for hi = 1:length(coords_plot_hi)
            % Only plot on the relevant hemisphere
            if (strcmp(hemis{i}, 'left') == 1 && strcmp(coords_hi.LvsR{hi}, 'L')) || (strcmp(hemis{i}, 'right') == 1 && strcmp(coords_hi.LvsR{hi}, 'R'))
                plot3(coords_plot_hi(hi,1),coords_plot_hi(hi,2),coords_plot_hi(hi,3), 'o', 'MarkerSize', cfg.chan_highlight_size, 'MarkerFaceColor', cfg.chan_highlight_facecolor(hi,:), 'MarkerEdgeColor', cfg.chan_highlight_edgecolor(hi,:), 'LineWidth', cfg.chan_highlight_edge_thick);
            end
        end
    end
        alpha(cfg.alpha)
end

end

