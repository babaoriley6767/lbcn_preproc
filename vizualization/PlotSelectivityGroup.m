function PlotSelectivityGroup(dirs, project_name, coords, elect_select, cfg)


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

% sort electrodes based on selectivity
[elect_select,idx] = sort(elect_select);
elect_select = flip(elect_select);
coords = coords(idx,:);
coords = flip(coords);

fsaverage_dir = '/Applications/freesurfer/subjects/fsaverage/surf'; % correct that:'/Applications/freesurfer/freesurfer/subjects/fsaverage/surf/rh.pial'
if strcmp(cfg.Cortex, 'MNI')
    [cmcortex.right.vert cmcortex.right.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['rh.' 'pial']));
    [cmcortex.left.vert cmcortex.left.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['lh.' 'pial']));
elseif  strcmp(cfg.Cortex, 'native')
    cmcortex = subjVar.cortex;
else
    error('you must specify the cortical space to plot, either MNI or native.')
end


%% Define elect size and color
load('cdcol_2018.mat')

elect_size = repmat(cfg.MarkerSize, length(elect_select), 1);
elect_size(strcmp(elect_select, 'no selectivity')) = 1;

for i = 1:length(elect_select)
    if strcmp(elect_select{i}, 'math only')
        elect_col(i,:) = cdcol.indian_red;
        elect_col_edge(i,:) = [0 0 0];
    elseif strcmp(elect_select{i}, 'math selective and autobio act')
        elect_col(i,:) = cdcol.raspberry_red;
        elect_col_edge(i,:) = [0 0 0];
    elseif strcmp(elect_select{i}, 'math and autobio')
        elect_col(i,:) = cdcol.manganese_violet;
        elect_col_edge(i,:) = [0 0 0];
    elseif strcmp(elect_select{i}, 'autobio only')
        elect_col(i,:) = cdcol.marine_blue;
        elect_col_edge(i,:) = [0 0 0];
    elseif strcmp(elect_select{i}, 'autobio selective and math act')
        elect_col(i,:) = cdcol.azurite_blue;
        elect_col_edge(i,:) = [0 0 0];
    else
        elect_col(i,:) = [.5 .5 .5];
        elect_col_edge(i,:) = [.5 .5 .5];
    end
end


%% Plot electrodes as dots in native space
figureDim = [0 0 1 1];
f1 = figure('units', 'normalized', 'outerposition', figureDim);
views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right', 'left', 'right'};

views = {'lateral', 'lateral', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right'};


for i = 1:length(views)
    subplot(2,2,i)
    coords_plot = CorrectElecLoc(coords, views{i}, hemis{i}, cfg.CorrectFactor);
    ctmr_gauss_plot(cmcortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
    
    for ii = 1:length(coords_plot)
        % Only plot on the relevant hemisphere
        if (strcmp(hemis{i}, 'left') == 1 && coords_plot(ii,1) > 0) || (strcmp(hemis{i}, 'right') == 1 && coords_plot(ii,1) < 0)
        else
            plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', elect_size(ii), 'MarkerFaceColor', elect_col(ii,:), 'MarkerEdgeColor', elect_col(ii,:));
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