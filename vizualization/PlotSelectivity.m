function PlotSelectivity(dirs, subjVar, elinfo, cfg)

coords = elinfo.LEPTO_coord;

%% Load comon brain (replace by fsaverage)
% [cmcortex.right.vert cmcortex.right.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['rh.' 'pial']));
% [cmcortex.left.vert cmcortex.left.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['lh.' 'pial']));

subDir = dirs.freesurfer;
subj = dir(subDir);
subj=subj(~ismember({subj.name},{'.','..', '.DS_Store'}) & horzcat(subj.isdir) == 1);
subj = subj.name;

%% Define elect size and color
load('cdcol_2018.mat')



elect_select = elinfo.elect_select;
marker_size = repmat(10,length(elinfo.elect_select), 1);
marker_size(strcmp(elinfo.elect_select, 'no selectivity')) = 5;
marker_size(strcmp(elinfo.elect_select, 'math and autobio')) = 7.5;

for i = 1:length(elect_select)
    if strcmp(elect_select{i}, 'math only')
        elect_col(i,:) = cdcol.indian_red;
        elect_col_edge(i,:) = [0 0 0];
    elseif (strcmp(elect_select{i}, 'math selective and autobio act')) || (strcmp(elect_select{i}, 'math selective and autobio deact'))
        elect_col(i,:) = cdcol.raspberry_red;
        elect_col_edge(i,:) = [0 0 0];
    elseif strcmp(elect_select{i}, 'math and autobio')
        elect_col(i,:) = cdcol.manganese_violet;
        elect_col_edge(i,:) = [0 0 0];
    elseif strcmp(elect_select{i}, 'autobio only')
        elect_col(i,:) = cdcol.marine_blue;
        elect_col_edge(i,:) = [0 0 0];
    elseif (strcmp(elect_select{i}, 'autobio selective and math act')) || (strcmp(elect_select{i}, 'autobio selective and math deact'))
        elect_col(i,:) = cdcol.azurite_blue;
        elect_col_edge(i,:) = [0 0 0];
    else
        elect_col(i,:) = [0 0 0];
        elect_col_edge(i,:) = [0 0 0];
    end
end


%% Plot electrodes as dots in native space
figureDim = [0 0 .4 1];
f1 = figure('units', 'normalized', 'outerposition', figureDim);
hemis = {'left', 'right', 'left', 'right', 'left', 'right'};
if cfg.overlay == false
    views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral'};
else
    cfg.elecCoord = 'n';
    cfg.view='l';
    cfg.cfg.overlayParcellation='Y7';
    cfg.surfType = 'pial';
    cfg.fsurfSubDir = dirs.freesurfer;
    cfg.ignoreDepthElec = 'n';
    cfg.title = [];
    views = {'l', 'r', 'lm', 'rm', 'li', 'ri'};
end


for i = 1:length(views)
    subplot(3,2,i)
    if strcmp(cfg.cortex_space, 'MNI')
        coords_plot = CorrectElecLoc(coords, views{i}, hemis{i}, cfg.correction_factor);
        ctmr_gauss_plot(cmcortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
    elseif strcmp(cfg.cortex_space, 'native')
        coords_plot = CorrectElecLoc(coords, views{i}, hemis{i}, cfg.correction_factor);
        if cfg.overlay == false
            ctmr_gauss_plot(subjVar.cortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
        else
            cfg.view = views{i};
            plotPialSurfCustom(subj,cfg)
        end
    else
        error('you must specify the cortical space to plot, either MNI or native.')
    end
    
    
    for ii = 1:length(coords_plot)
        % Only plot on the relevant hemisphere
        if (strcmp(hemis{i}, 'left') == 1 && coords_plot(ii,1) > 0) || (strcmp(hemis{i}, 'right') == 1 && coords_plot(ii,1) < 0)
        else
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size(ii), 'MarkerFaceColor', elect_col(ii,:), 'MarkerEdgeColor', 'k');
        end
    end
    alpha(0.7)   
end

savePNG(gcf, 300, [dirs.result_root filesep cfg.project_name filesep 'selectivity/individual' filesep subjVar.sbj_name '_selectivity_' cfg.project_name '_' cfg.cortex_space '.png']); % ADD TASK AND CONDITION

% savePNG(gcf, 300, [dirs.result_root filesep '57_yeo7_ventral.png']); % ADD TASK AND CONDITION


% close all

end

%% Function to optimize electrode location for plotting
function coords_plot = CorrectElecLoc(coords, views, hemisphere, correction_factor)
coords_plot = coords;
% cfg.correction_factor = 0;
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