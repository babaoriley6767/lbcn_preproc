%% Example pre-made lines of code to run couple of important commonly used functions

% Here is for starting: similar to beginning of pipeline_basic (FYI if you want to run)
% each variable should be defined to run the sections below
server_root = '/Volumes/neurology_jparvizi$/';
comp_root = '/Volumes/LBCN2T/Data';
code_root = '/Users/parvizilab/Documents/Code/lbcn_preproc/';
project_name = 'MMR'; % generally this doesn't need to be specific
center = 'Stanford';
% please define sbj_name
sbj_name = 'PUT HERE';

%% To create subjVar individually
fprintf('Running createSubjVar for subject: %s\n',sbj_name)
dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'
data_format = GetFSdataFormat(sbj_name, center);
[subjVar,  subjVar_created] = CreateSubjVar(sbj_name, dirs, data_format);

%% In order to create and save multiple subjVar's.
sbj_list = {'',''}; % put as many as you want

for i=8:length(sbj_list)
    sbj_name = sbj_list{i};
    fprintf('Now running for %d: %s\n',i,sbj_name)
    dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T' - needs to be run for each subject separately
    data_format = GetFSdataFormat(sbj_name, center);
    [subjVar,  subjVar_created] = CreateSubjVar(sbj_name, dirs, data_format);
    spl_sbj=regexp(sbj_name,'_','split');
    
    % please check if the location is correct
%     save(['/Users/parvizilab/Desktop/' spl_sbj{1} '_' spl_sbj{2} '_subjVar.mat'], 'subjVar');
end

%% Here is to plot atlas labels of interest of each electrode.
% Any of the column can be plotted from subjVar.elinfo. Play and find what
% you want :)
cfg.plot_label = 'Yeo7_ind'; % or 'FS_label', 'DK_index', 'Destr_index' etc
cfg.views = {'lateral', 'ventral'}; % views and hemis can be changed, check the example in PlotAtlasLabel.m
cfg.hemis = {'left', 'left'};
cfg.label_fontsize = 14;
cfg.correction_factor = 0;
PlotAtlasLabels(subjVar, cfg)

%% example specific job: 
% 1) define cfg to be able to plot channel numbers of electrodes on native
% brain
% 2) create SubjVar for each subject (since we need subjVar.elinfo)
% 3) PlotAtlasLabels and save the plot
cfg=[];
cfg.views = {'lateral', 'medial', 'ventral', 'dorsal','posterior','lateral', 'medial', 'ventral', 'dorsal','posterior'};
cfg.hemis = {'left', 'left', 'left', 'left', 'left', 'right', 'right', 'right', 'right', 'right'};
% cfg.views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral', 'dorsal','dorsal'};
% cfg.hemis = {'left', 'right', 'left', 'right', 'left', 'right','left', 'right'};
cfg.label_fontsize = 10;
cfg.plot_label = 'chan_num';
cfg.correction_factor = 0;
save_dir = '/Users/parvizilab/Desktop/chan_nums';
sbj_list2 = {'',''}; % put as many as you want

for i=1:length(sbj_list2)
    sbj_name = sbj_list2{i};
    fprintf('Now running for %d: %s\n',i,sbj_name)
    dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'
    data_format = GetFSdataFormat(sbj_name, center);
    [subjVar,  subjVar_created] = CreateSubjVar(sbj_name, dirs, data_format);
    PlotAtlasLabels(subjVar,cfg)
    saveas(gcf,[save_dir filesep sbj_name '_chan_num.png'])
    close all
end
