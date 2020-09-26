function data_all = ConcatenateAllMultisbj(sbj_names,project_name,concat_params,column,conds,norm_by_subj)
%% INPUTS
% column: column of trialinfo from which to select trials, based on conds
% conds: cond names (within column) to use to sort trials, e.g. {'math','autobio'}
% norm_by_subj: true or false (divide each subj/condition by its own max)

%% set paths
code_root = '/Users/amydaitch/Dropbox/Code/MATLAB/lbcn_preproc';
server_root = '/Volumes/neurology_jparvizi$/';
comp_root = '/Volumes/AmyData/ParviziLab';

%%
% concatenate data across subjs, elecs
data_all = [];
for ii = 1:length(conds)
    newname = strrep(conds{ii},'-','_');
    data_all.wave.(newname) = [];
end

data_all.elect_names = [];
data_all.elect_MNI = [];
data_all.sbj_name = {};
for i = 1:length(sbj_names)
    % Concatenate trials from all blocks
    dirs = InitializeDirs(project_name, sbj_names{i}, comp_root, server_root,code_root); 
    block_names = BlockBySubj(sbj_names{i},project_name);
    load([dirs.original_data,filesep,sbj_names{i},filesep,'global_',project_name,'_',sbj_names{i},'_',block_names{1},'.mat']) % load globalVar
    load([dirs.original_data,filesep,sbj_names{i},filesep,'subjVar_',sbj_names{i},'.mat']) % load subjVar (containing cortex, elecs)
    subjVar = reorderElecCoords(subjVar,globalVar);

    data_sbj = ConcatenateAll(sbj_names{i},project_name,block_names,dirs,[],'Band','HFB','stim', concat_params);
    % delete bad chans
    data_sbj.wave(:,data_sbj.badChan,:)=[];
    data_sbj.labels(data_sbj.badChan)=[];
    subjVar.elect_MNI(data_sbj.badChan,:)=[];
    subjVar.elect_names(data_sbj.badChan)=[];
    
    if (nanmedian(data_sbj.trialinfo.nstim)>1) % if more than one stim per trial, e.g. Memoria
        ISI = nanmedian(data_sbj.trialinfo.allonsets(:,2)-data_sbj.trialinfo.allonsets(:,1));
    end
    % Average across trials, normalize and concatenate across subjects
    for ii = 1:length(conds)
        newname = strrep(conds{ii},'-','_');
        tmp_trials = find(strcmp(data_sbj.trialinfo.(column),conds{ii}));
        nstim = nanmedian(data_sbj.trialinfo.nstim(tmp_trials));
%         data_tmp_avg = squeeze(nanmedian(data_sbj.wave(tmp_trials,:,:),1)); % avg. across trials (median more robust to spikes)
        data_tmp_avg = squeeze(trimmean(data_sbj.wave(tmp_trials,:,:),5,1)); 
        % normalize within subject
        if norm_by_subj
            data_tmp_avg = data_tmp_avg/nanmax(data_tmp_avg(:));
        end
        % divide up by stimuli
        bl_inds = find(data_sbj.time >= concat_params.t_bl(1) & data_sbj.time <= concat_params.t_bl(2));
        stim_inds_all = bl_inds;
        t_stim = data_sbj.time(bl_inds);
        t_all = t_stim;
        stim_num = zeros(1,length(bl_inds)); % zero indicates baseline
        data_sbj_stim.(newname) = data_tmp_avg(:,bl_inds);
        for sti = 1:nstim
            stim_inds = find(data_sbj.time >= (ISI*(sti-1) + concat_params.t_stim(1)) & data_sbj.time <= (ISI*(sti-1) + concat_params.t_stim(2)));
            stim_inds_all = [stim_inds_all stim_inds];
            t_stim = [t_stim data_sbj.time(stim_inds)-ISI*(sti-1)];
            t_all = [t_all data_sbj.time(stim_inds)];
            stim_num = [stim_num sti*ones(1,length(stim_inds))];
            data_sbj_stim.(newname) = [data_sbj_stim.(newname) data_tmp_avg(:,stim_inds)];
        end
%         data_sbj_stim.(conds{ii}) = data_sbj_stim.(conds{ii})/nanmax(data_sbj_stim.(conds{ii})(:));
        data_all.stim_num.(newname) = stim_num;
        data_all.stim_time.(newname) = t_stim; % relative to each indiv. stim
        data_all.time.(newname) = t_all; % relative to 1st stim
        data_all.wave.(newname) = [data_all.wave.(newname); data_sbj_stim.(newname)];
    end
    
    data_all.elect_names = [data_all.elect_names;data_sbj.labels'];
    data_all.sbj_name = [data_all.sbj_name; repmat(sbj_names(i),[length(data_sbj.labels),1])];
    data_all.elect_MNI = [data_all.elect_MNI;subjVar.elect_MNI];
end


