function PlotITPCAll(sbj_name,project_name,block_names,dirs,elecs,freq_band,locktype,column,conds,plot_params)

%% INPUTS
%       sbj_name: subject name
%       project_name: name of task
%       block_names: blocks to be analyed (cell of strings)
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       elecs: can select subset of electrodes to epoch (default: all)
%       locktype: 'stim' or 'resp' (which event epoched data is locked to)
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all of the conditions within column)
%       noise_params.method: 'trials','timepts', or 'none' (which baseline data to
%                       exclude before baseline correction)
%               .noise_fields_trials  (which trials to exclude- if method = 'trials')
%               .noise_fields_timepts (which timepts to exclude- if method = 'timepts')
%       plot_params:    .eb : plot errorbars ('ste','std',or 'none')
%                       .lw : line width of trial average
%                       .legend: 'true' or 'false'
%                       .label: 'name','number', or 'none'
%                       .sm: width of gaussian smoothing window (s)
%                       .textsize: text size of axis labels, etc
%                       .xlabel
%                       .ylabel
%                       .freq_range: frequency range to extract (only applies to spectral data)
%                       .xlim

if isempty(plot_params)
    plot_params = genPlotParams(project_name,'ITPC');
end

% keep track of bad chans (from any block) for labeling plots
bad_chans = [];
for bi = 1:length(block_names)
    load([dirs.data_root,filesep,'OriginalData',filesep,sbj_name,filesep,'global_',project_name,'_',sbj_name,'_',block_names{bi},'.mat'])
    bad_chans = union(bad_chans,globalVar.badChan);
end

if iscell(elecs)
    elecs = ChanNamesToNums(globalVar,elecs);
end

if isempty(elecs)
    elecs = setdiff(1:globalVar.nchan,globalVar.refChan);
end

tag = [locktype,'lock'];
if plot_params.blc
    tag = [tag,'_bl_corr'];
end
concatfield = {'phase'}; % concatenate amplitude across blocks

dir_out = [dirs.result_root,filesep,project_name,filesep,sbj_name,filesep,'Figures',filesep,'SpecData',filesep,freq_band,filesep,'ITPC',filesep,locktype,'lock'];

if ~exist(dir_out)
    mkdir(dir_out)
end

disp('>-8-<') % HUG
%%
for ei = 1
    el = elecs(ei);
    data_all = concatBlocks(sbj_name,block_names,dirs,el,freq_band,'Spec',concatfield,tag);
    if isempty(conds)
        tmp = find(~cellfun(@isempty,(data_all.trialinfo.(column))));
        conds = unique(data_all.trialinfo.(column)(tmp));
    end
    cond_names = groupCondNames(conds,false);
end
folder_name = cond_names{1};
for gi = 2:length(cond_names)
    folder_name = [folder_name,'_',cond_names{gi}];
end
dir_out = [dir_out,filesep,folder_name];
if ~exist(dir_out)
    mkdir(dir_out)
end

for ei = 1:length(elecs)
    el = elecs(ei);
    
    if ismember(el,bad_chans)
        tagchan = ' (bad)';
    else
        tagchan = ' (good)';
    end
    
    data_all = concatBlocks(sbj_name,block_names,dirs,el,freq_band,'Spec',concatfield,tag);
    if strcmp(plot_params.noise_method,'timepts')
        data_all = removeBadTimepts(data_all,plot_params.noise_fields_timepts);
    end

    if isempty(conds)
        tmp = find(~cellfun(@isempty,(data_all.trialinfo.(column))));
        conds = unique(data_all.trialinfo.(column)(tmp));
    end
    
    PlotITPC(data_all,column,conds,plot_params)
    if strcmp(plot_params.label,'name')
        suptitle([data_all.label,tagchan])
    elseif strcmp(plot_params.label,'number')
        suptitle(['Elec ',num2str(el),tagchan])
    end

    fn_out = sprintf('%s/%s_%s_%s_ITPC_%s_%slock.png',dir_out,sbj_name,data_all.label,project_name,freq_band,locktype);
    saveas(gcf,fn_out)
    close
end


