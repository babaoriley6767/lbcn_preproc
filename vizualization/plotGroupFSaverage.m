% This script requires patient list whose electrodes you want to plot on
% fsaverage brain and dirs (output of InitializeDirs).

%% Change here for your computer
server_root = '/Volumes/neurology_jparvizi$/';
comp_root = '/Volumes/LBCN2T/Data';
code_root = '/Users/parvizilab/Documents/Code/lbcn_preproc/';
project_name = 'UCLA';
center = 'Stanford';

%% Plotting
load('cdcol_2018.mat')
marker_size = 3;
figureDim = [0 0 .4 1];

figure('units', 'normalized', 'outerposition', figureDim)
views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right', 'left', 'right'};
subjVars=[];

for i = 1:length(sbj_list)
    sbj_name = sbj_list{i};
    fprintf('Now creating subjVar for %d: %s\n',i,sbj_name)
    data_format = GetFSdataFormat(sbj_name, 'Stanford');
    dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'
    [subjVars.(sbj_name),  ~] = CreateSubjVar(sbj_name, dirs, data_format);
end

[cortex.left.vert, cortex.left.tri] = read_surf(fullfile(dirs.fsDir_local,'surf', 'lh.PIAL'));
[cortex.right.vert, cortex.right.tri] = read_surf(fullfile(dirs.fsDir_local,'surf','rh.PIAL'));

for i = 1:length(views)
    subplot(3,2,i)
    ctmr_gauss_plot(cortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
    hold on
    for iii = 1:numel(fieldnames(subjVars))
        sbj_name = sbj_list{iii};
        coords_plot = subjVars.(sbj_name).elinfo.MNI_coord;
        
        for ii = 1:length(coords_plot)
            if (strcmp(hemis{i}, 'left') && strcmpi(subjVars.(sbj_name).elinfo.LvsR{ii},'L'))
                %             plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
                plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', cdcol.light_cadmium_red, 'MarkerEdgeColor', cdcol.light_cadmium_red);
            elseif (strcmp(hemis{i}, 'right') && strcmpi(subjVars.(sbj_name).elinfo.LvsR{ii},'R'))
                %             plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
                plot3(coords_plot(ii,1),coords_plot(ii,2),coords_plot(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', cdcol.light_cadmium_red, 'MarkerEdgeColor', cdcol.light_cadmium_red);
            end
        end
    end
    alpha(0.7)
end
