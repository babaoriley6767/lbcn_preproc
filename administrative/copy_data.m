%% Copy data
task = {'MMR'};
subjs_to_copy.MMR = {'S17_104_SW'}; % this is to initiate and copy from excel files
subjs_to_copy.UCLA = {}; % this is to initiate and copy from excel files

% Define origin dirs
[server_root, comp_root, code_root] = AddPaths('Pedro_iMAC');
dirs = InitializeDirs(' ', ' ', comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'
neuralData_folders = {'SpecData'}; %'originalData', 'CARData', 'BandData', %
origin_psych = dirs.psych_root;
origin_neural = dirs.data_root;
% Define destination dirs
destination_psych = '/Users/pinheirochagas/Pedro/drive/Stanford/projects/math_network/shared_data/Stanford/data/psychData';
destination_neural = '/Users/pinheirochagas/Pedro/drive/Stanford/projects/math_network/shared_data/Stanford/data/neuralData';


%% Make sure BlockbySubj is updated everywhere!

for ti = 1:length(task)
    project_name = task{ti};
    block_names_all = {};
    for i = 1:length(subjs_to_copy.(task{ti}))
        block_names_all{i} = BlockBySubj(subjs_to_copy.(task{ti}){i},project_name);
    end
    for i = 1:length(subjs_to_copy.(task{ti}))
        CopySubject(subjs_to_copy.(task{ti}){i}, origin_psych, destination_psych, origin_neural, destination_neural, neuralData_folders, project_name, block_names_all{i})
    end
end

% Run after having copied on the destination computer
comp_root = ''; % this is final destination
dirs = InitializeDirs(project_name, subjs_to_copy.VTCLoc{1}, comp_root, server_root, code_root); 
for ti = 1:length(task)
    project_name = task{ti};
    for i = 1:length(subjs_to_copy.(task{ti}))
        block_names = BlockBySubj(subjs_to_copy.(task{ti}){i},project_name); % 
        UpdateGlobalVarDirs(subjs_to_copy.(task{ti}){i}, project_name, block_names, dirs)% 
    end
end