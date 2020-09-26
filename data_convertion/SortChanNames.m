function channame = SortChanNames(files)
% e.g. channame = dir(fullfile('/Volumes/LBCN8T/Stanford/data/neuralData/originalData/S18_124/E18-309_0004/', '*.mat'))


for i = 1:length(all)
    names{i} = strsplit(files(i).name, {'_', '.'});
    channame(i) = str2num(names{i}{3});
end