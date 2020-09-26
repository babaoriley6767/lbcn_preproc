%% Decoding pipeline
server_root = '/Volumes/neurology_jparvizi$/';
comp_root = '/Volumes/LBCN8T/Stanford/data';
code_root = '/Users/pinheirochagas/Pedro/Stanford/code/lbcn_preproc/';

sbj_name = 'S19_137_AF';
block_names = BlockBySubj(sbj_name,project_name);

dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'


%% Export data to MNE
% Load subjVar

% Load single channel with Spec
chan = find(strcmp(subjVar.labels_EDF, 'LK10'));
chan = 61
data_all = concatBlocks(sbj_name, project_name, block_names,dirs,chan,'SpecDense','Spec',{'wave'},'stimlock_bl_corr')

data_all.wave = permute(data_all.wave,[2,1,3]);

trialinfo = removevars(data_all.trialinfo, {'bad_epochs_raw_LFspike', 'bad_epochs_raw_HFspike' 'bad_epochs_raw_jump', 'bad_epochs_spec_HFspike', 'bad_epochs','bad_epochs_HFO', 'bad_inds_raw_LFspike', 'bad_inds_raw_HFspike', 'bad_inds_raw_jump', 'bad_inds_spec_HFspike', 'bad_inds_HFO', 'bad_inds', 'block', 'allonsets', 'StimulusOnsetTime'});
if strcmp(project_name, 'MMR')
    trialinfo = removevars(data_all.trialinfo, {'wlist'});
%     trialinfo = trialinfo(~strcmp(trialinfo.condNames, 'rest'),:);
else
end

trialinfo.cross_decade = zeros(size(trialinfo,1),1)
for i = 1:size(trialinfo,1)
    if trialinfo.isCalc(i) ~= 1
        trialinfo.cross_decade(i) = nan;
    else
        opmax_tmp = num2str(trialinfo.OperandMax(i));
        res_tmp = num2str(trialinfo.CorrectResult(i));
        if str2num(opma_tmp(1)) ==  str2num(res_tmp(1))
            trialinfo.cross_decade(i) = 0;
        else
            trialinfo.cross_decade(i) = 1;
        end
    end
end

data_all.label = cellstr(num2str(data_all.freqs'));
data_all.project_name = project_name;

dirs.MVPAData = '/Volumes/LBCN8T_2/Stanford/data/MVPAData';
save([dirs.MVPAData '/data_all_' sbj_name '_' project_name '.mat'], 'data_all');

% save([dirs.MVPAData '/data_specdense_' sbj_name '_' project_name '_' '.mat'], 'data');

% Export trialinfo to csv
% data_all.wave = data_all.wave(~contains(trialinfo.wlist, 'Ê'),:,:); % correct that for MMR
% trialinfo = trialinfo(~contains(trialinfo.wlist, 'Ê'),:); % correct that for MMR
writetable(trialinfo,[dirs.MVPAData '/trialinfo_' sbj_name '_' project_name '.csv'])


%% All chans time domain data
sbj_name = 'S19_137_AF';

cfg.decimate = 1;
cfg.final_fs = 500;
concat_params = genConcatParams(project_name, cfg);
concat_params.fieldtrip = false; 
concat_params.exclude_nan_chan = false;
concat_params.noise_method = 'none';


data_all = ConcatenateAll(sbj_name,project_name,block_names,dirs,[], 'CAR', 'CAR','stim', concat_params);
trialinfo = removevars(data.trialinfo, {'bad_epochs_raw_LFspike', 'bad_epochs_raw_HFspike' 'bad_epochs_raw_jump', 'bad_epochs_spec_HFspike', 'bad_epochs','bad_epochs_HFO', 'bad_inds_raw_LFspike', 'bad_inds_raw_HFspike', 'bad_inds_raw_jump', 'bad_inds_spec_HFspike', 'bad_inds_HFO', 'bad_inds', 'block', 'allonsets', 'StimulusOnsetTime'});

% select some channels
chans = find(contains(subjVar.elinfo.FS_label, 'VAG')| contains(subjVar.elinfo.FS_label, 'VPG'));
data_all.wave = data_all.wave(:,chans,:);
data_all.label = data_all.label(chans);


dirs.MVPAData = '/Volumes/LBCN8T_2/Stanford/data/MVPAData';
save([dirs.MVPAData '/data_all_' sbj_name '_' project_name '.mat'], 'data_all');
writetable(trialinfo,[dirs.MVPAData '/trialinfo_' sbj_name '_' project_name '.csv'])


trialinfo = removevars(data.trialinfo{1}, {'bad_epochs_raw_LFspike', 'bad_epochs_raw_HFspike' 'bad_epochs_raw_jump', 'bad_epochs_spec_HFspike', 'bad_epochs','bad_epochs_HFO', 'bad_inds_raw_LFspike', 'bad_inds_raw_HFspike', 'bad_inds_raw_jump', 'bad_inds_spec_HFspike', 'bad_inds_HFO', 'bad_inds', 'block', 'allonsets', 'StimulusOnsetTime'});
data =  rmfield(data, 'trialinfo');
ti_names = (trialinfo.Properties.VariableNames);
for i = 1:length(ti_names)
    data.trialinfo.(ti_names{i}) = trialinfo.(ti_names{i});
end






for i = 1:200
    hold on
    plot(data_all.trial{i}(108,:))
end







cols = viridis(size(data_all.wave,2))

time = data.time

for i = 1:size(data_all.wave,2)
    hold on
    plot(squeeze(mean(data_all.wave(:,i,50:end-200))), 'Color', cols(i,:), 'LineWidth', 2)
end
set(gca,'color',[.7 .7 .7])
set(gcf,'color',[.7 .7 .7])
set(gca, 'FontSize', 20)
cb = colorbar('north')
colormap(viridis)
freqs = data.freqs;
freqs = freqs(1:floor(length(freqs)/10):length(freqs));
freqs_norm = freqs/max(freqs);

cb.Ticks = freqs_norm;
cb.TickLabels = cellstr(num2str(floor(freqs)'));
cb.FontSize = 16

save



% % excluse bad channels
% data_all.wave(:,data_all.badChan,:) = [];
% data_all.labels(data_all.badChan) = [];
% data_all.trialinfo(data_all.badChan) = [];

% check for channels with nan
nan_channel = [];
for i = 1:size(data_all.wave,2)
    nan_channel(i) = sum(sum(isnan(data_all.wave(:,i,:))));
end

% Interpolate nans channels witgh nan
% loop across dimensions
nanx = isnan(x);
t    = 1:numel(x);
x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx));


%% Select some channels 
chan_indices = find(contains(data_all.labels, 'LPG'));
data_all.wave = data_all.wave(:,chan_indices,:);
data_all.labels = data_all.labels(chan_indices);
bad_chan_HFO = [17:23, 25:31, 37:39];
data_all.wave(:,bad_chan_HFO,:) = [];
data_all.labels(bad_chan_HFO) = [];


data_all.wave(:,data_all.badChan,:) = [];
data_all.labels(data_all.badChan) = [];


%Randomly select the same number of conditions

% Save
dirs.MVPAData = '/Volumes/LBCN8T_2/Stanford/data/MVPAData';
% save([dirs.MVPAData '/data_all_' sbj_name '_' project_name '_' 'HFB' '.mat'], 'data_all', '-v7.3');
save([dirs.MVPAData '/data_all_' sbj_name '_' project_name '_' '.mat'], 'data_all');

% Export trialinfo to csv
% data_all.wave = data_all.wave(~contains(trialinfo.wlist, 'Ê'),:,:); % correct that for MMR
% trialinfo = trialinfo(~contains(trialinfo.wlist, 'Ê'),:); % correct that for MMR
writetable(trialinfo,[dirs.MVPAData '/trialinfo_' sbj_name '_' project_name '.csv'])