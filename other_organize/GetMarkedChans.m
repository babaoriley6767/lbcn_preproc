function [refChan, badChan, epiChan, emptyChan] = GetMarkedChans(sbj_name)

% Load table
T = readtable('/Users/pinheirochagas/Downloads/subject_info_chan_fs.xlsx');

% Convert string to numbers
markChans = {'refChan','badChan', 'epiChan', 'emptyChan'};
for i = 1:length(markChans)
    T.(markChans{i}) = cellfun(@str2num ,T.(markChans{i}),'UniformOutput',false);
end

% Select the subject rows
T = T(strcmp(T.sbj_name, sbj_name),:);

% Organize output
refChan = T.refChan{:};
badChan = T.badChan{:};
epiChan = T.epiChan{:};
emptyChan = T.emptyChan{:};

end