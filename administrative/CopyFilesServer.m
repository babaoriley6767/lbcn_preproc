function CopyFilesServer(sbj_name,project_name, block_name,data_format,dirs)

% Load globalVar
sbj_name_split = strsplit(sbj_name, '_');
sbj_name_anno = [sbj_name_split{1} '_' sbj_name_split{2}];

    
fn = sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_name);
load(fn,'globalVar');

% Data path server

if strcmp(data_format, 'TDT')
    
%     data_ieeg_path = sprintf('%sSHICEP_%s/%s(Data ECoG)/TDT Data/%s/%s',dirs.server_root,sbj_name, sbj_name, sbj_name, block_name);
%     data_behavior_path = sprintf('%sSHICEP_%s/Analyzed Data/%s/Beh/',dirs.server_root,sbj_name, project_name);
    
    % List all iEEG files
    iEEG_names = dir(fullfile(globalVar.iEEG_data_server_path, '*.mat')); % actually take all channels, including pdio
    % Copy iEEG files to corresponding folder
    for i = 1:length(iEEG_names)
        fn = [iEEG_names(i).folder '/' iEEG_names(i).name];
        copyfile(fn, globalVar.originalData)
        fprintf('Copied iEEG file %s to %s', fn, globalVar.originalData)
    end
    
elseif strcmp(data_format, 'edf')
    copyfile(globalVar.iEEG_data_server_path, globalVar.originalData)
    fprintf('Copied iEEG file %s to %s', fn, globalVar.originalData)
else
end

if ~strcmp(project_name, 'Rest')
    %%Copy behavioral file
    copyfile(globalVar.behavioral_data_server_path, globalVar.psych_dir)
    fprintf('Copied behavioral file %s to %s', fn, globalVar.psych_dir)
else
end
end

