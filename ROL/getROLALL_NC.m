function ROL = getROLAll_NC(sbj_name,project_name,block_names,dirs,elecs,datatype,ROL_params,column,conds)
%'Condnames',[]
%% INPUTS
%       sbj_name: subject name
%       project_name: name of task
%       block_names: blocks to be analyed (cell of strings)
%       dirs: directories pointing to files of interest (generated by InitializeDirs)
%       elecs: can select subset of electrodes to epoch (default: all)
%       datatype: 'CAR','HFB',or 'Spec'
%       locktype: 'stim' or 'resp' (which event epoched data is locked to)
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all of the conditions within column)
%               can group multiple conds together by having a cell of cells
%               (e.g. conds = {{'math'},{'autobio','self-internal'}})            
%       col:    colors to use for plotting each condition (otherwise will
%               generate randomly)
%       noise_method:   how to exclude data (default: 'trial'):
%                       'none':     no epoch rejection
%                       'trial':    exclude noisy trials (set to NaN)
%                       'timepts':  set noisy timepoints to NaN but don't exclude entire trials
%       ROLparams:    (see genROLParams.m script)

if isempty(block_names)
    block_names = BlockBySubj(sbj_name,project_name);
else
end
% load subjVar

load([dirs.original_data filesep  sbj_name filesep 'subjVar_'  sbj_name '.mat']);

%load elecs info.
if isempty(elecs)
    % load globalVar (just to get ref electrode, # electrodes)
    load([dirs.data_root,'/OriginalData/',sbj_name,'/global_',project_name,'_',sbj_name,'_',block_names{1},'.mat'])
    elecs = setdiff(1:globalVar.nchan,globalVar.refChan);
end

%set the datatype
if isempty(datatype)
    datatype = 'HFB';
end

%set the ROL_params
if isempty(ROL_params)
    ROL_params = genROLParams_NC(project_name);
end

%load the globalVar
load([dirs.data_root,'/OriginalData/',sbj_name,'/global_',project_name,'_',sbj_name,'_',block_names{1},'.mat'])

%load basic info. from one of the epoch data
dir_in = [dirs.data_root,'/','BandData',filesep,datatype,filesep,sbj_name,'/',block_names{1},'/EpochData/'];%chao
if strcmp(project_name, 'GradCPT')
    load(sprintf('%s/%siEEG_stimlock_%s_%.2d.mat',dir_in,datatype,block_names{1},elecs(1)));%chao
else
    load(sprintf('%s/%siEEG_stimlock_bl_corr_%s_%.2d.mat',dir_in,datatype,block_names{1},elecs(1)));%chao
end


locktype = 'stim';%????????

%chao set noise_method
noise_method = 'trials';%????????

%get the sampling info.
fs = data.fsample;

%chao set the conds based on the trialinfo
if isempty(conds)    
    conds = unique(data.trialinfo.(column));
end

nstim = 1;
stimtime = 0;%%%%%%
stiminds = find(data.time>stimtime,1);; %%%%%%%
    
befInd = round(ROL_params.pre_event * fs);%%%%%%
aftInd = round(ROL_params.dur * fs);%%%%%%
time = (befInd:aftInd)/fs;%%%%%%%.


for ci = 1:length(conds)
    cond = conds{ci};
    ROL.(cond).peaks = cell(globalVar.nchan,nstim);
    ROL.(cond).onsets = cell(globalVar.nchan,nstim);
%     HFB_trace_bc.(cond) = cell(globalVar.nchan,nstim);
   %%% ROL.(cond).HFB_trace_bc = cell(globalVar.nchan,nstim);
%     HFB_trace_bs.(cond) = cell(globalVar.nchan,nstim);
    sig.(cond) = cell(globalVar.nchan,nstim); % this will be the data
end


concatfield = {'wave'};
tag = [locktype,'lock'];
if ROL_params.blc
    tag = [tag,'_bl_corr'];
end

disp('Concatenating data across blocks...')
for ei = 1:length(elecs)
    el = elecs(ei);
    data_all = concatBlocks(sbj_name, project_name, block_names,dirs,el,'HFB','Band',concatfield,tag);

    if ROL_params.power
        data_all.wave = data_all.wave.^2;
    end

    if ROL_params.smooth
        data_all.wave = convn(data_all.wave,gusWin','same');
    end
    %[grouped_trials,grouped_condnames] = groupConds(conds,data_all.trialinfo,column,noise_method,false);
    %chao
    [grouped_trials,grouped_condnames] = groupConds(conds,data_all.trialinfo,column,'none',{''},false);
    nconds = length(grouped_trials);
    for ci = 1:nconds
        cond = grouped_condnames{ci};
        for ii = 1:nstim
            sig.(cond){el,ii} = [sig.(cond){el,ii}; data_all.wave(grouped_trials{ci},stiminds(ii)+befInd:stiminds(ii)+aftInd)];
        end
    end  
end
disp('DONE')


for ei = 1:length(elecs)%chao
    el = elecs(ei);
    for ci = 1:length(conds)
        cond = grouped_condnames{ci};
        for ii = 1:nstim
            data.wave = sig.(cond){el,ii};
            data.time = time;
            if ~isempty(data.wave)
                [Resp_data]= ROLbootstrap_NC(data, ROL_params);
                ROL.(cond).peaks{el,ii} = Resp_data.peaks;
                ROL.(cond).onsets{el,ii} = Resp_data.onsets;
            end
            %             ROL.(cond).HFB_trace_bc{el,ii}=Resp_data.trace_bc;
        end
    end
    disp(['Computing ROL for elec: ',num2str(el)])
end

dir_out = [dirs.result_dir 'ROL' filesep];

if ~exist(dir_out)
    mkdir(dir_out)
end
    
fn_out = sprintf('%s%s_%s_ROL.mat',dir_out,sbj_name,project_name);
save(fn_out,'ROL');
end
