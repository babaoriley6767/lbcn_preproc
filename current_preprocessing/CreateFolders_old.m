function CreateFolders(sbj_name, project_name, block_name, center, dirs, data_format,import_server)
% Create folders LBCN
folder_names = {'originalData', 'CARData', 'CompData', 'FiltData', ...
    'SpecData', 'HFBData'};

% Subject folder name
if import_server
    all_folders = dir(fullfile('/Volumes/neurology_jparvizi$/'));
    for i = 1:length(all_folders)
        tpm(i) = contains(all_folders(i).name, sbj_name);
    end
    sbj_folder_name = all_folders(find(tpm == 1)).name;
end


%% Per subject
for i = 1:length(folder_names)
    folders.(folder_names{i}) = sprintf('%s/%s/%s',dirs.data_root,folder_names{i},sbj_name);
end
folders.psych_dir = sprintf('%s/%s',dirs.psych_root,sbj_name);
folders.result_dir = sprintf('%s/%s/%s',dirs.result_root,project_name,sbj_name);

fieldname_folders = fieldnames(folders);

for i = 1:length(fieldname_folders)
    if ~exist(folders.(fieldname_folders{i}))
        mkdir(folders.(fieldname_folders{i}));
    end
end

%% Per block - create folders and globalVar
globalVar.sbj_name = sbj_name;
globalVar.project_name = project_name;
globalVar.center = center;


for bn = 1:length(block_name)
    globalVar.block_name = block_name{bn};
    for i = 1:length(fieldname_folders)
        globalVar.(fieldname_folders{i}) = [folders.(fieldname_folders{i}) '/' block_name{bn}];
        if ~exist(globalVar.(fieldname_folders{i}))
            mkdir(globalVar.(fieldname_folders{i}));
        end
        if strcmp(fieldname_folders{i}, 'psych_dir') || strcmp(fieldname_folders{i}, 'result_dir') || strcmp(fieldname_folders{i}, 'originalData') 
        else
            if ~exist([globalVar.(fieldname_folders{i}) '/EpochData'])
                mkdir([globalVar.(fieldname_folders{i}) '/EpochData']);
            end
        end
    end
    %% Original folders from the server
    % iEEG data
    if import_server
        if strcmp(data_format, 'TDT')
            waitfor(msgbox(['Choose server folder for iEEG data of block ' block_name{bn}]));
            globalVar.iEEG_data_server_path = [uigetdir(['/Volumes/neurology_jparvizi$/' sbj_folder_name]) '/'];
        elseif strcmp(data_format, 'edf')
            waitfor(msgbox(['Choose server file for iEEG data of block ' block_name{bn}]));
            [FILENAME, PATHNAME] = uigetfile(['/Volumes/neurology_jparvizi$/' sbj_folder_name,'.edf'],'All Files (*.*)','MultiSelect','on');
            globalVar.iEEG_data_server_path = [PATHNAME, FILENAME];
        else
        end
        % Behavioral data
        waitfor(msgbox(['Choose file of the behavioral data on the server for block ' block_name{bn}]));
        [FILENAME, PATHNAME] = uigetfile(['/Volumes/neurology_jparvizi$/' sbj_folder_name]);
        globalVar.behavioral_data_server_path = [PATHNAME, FILENAME];
    end

    % Save globalVariable
    fn = [folders.originalData '/' sprintf('global_%s_%s_%s.mat',project_name,sbj_name,block_name{bn})];
    save(fn,'globalVar');
end



end




