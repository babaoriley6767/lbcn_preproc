function data_all = GroupBrainPlot(sbj_names,project_name,concat_params,column,conds,norm_by_subj)
%% INPUTS
% column: column of trialinfo from which to select trials, based on conds
% conds: cond names (within column) to use to sort trials, e.g. {'math','autobio'}
% norm_by_subj: true or false (divide each subj/condition by its own max)

%% set paths
code_root = '/Users/amydaitch/Dropbox/Code/MATLAB/lbcn_preproc';
server_root = '/Volumes/neurology_jparvizi$/';
comp_root = '/Volumes/AmyData/ParviziLab';

vid_params = genVidParams(project_name);
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
    load([dirs.original_data,filesep,sbj_names{i},filesep,'subjVar_',sbj_names{i},'.mat'])
%     subjVar = reorderElecCoords(subjVar,globalVar);

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
        bl_inds = find(data_sbj.time >= vid_params.t_bl(1) & data_sbj.time <= vid_params.t_bl(2));
        stim_inds_all = bl_inds;
        t_stim = data_sbj.time(bl_inds);
        t_all = t_stim;
        stim_num = zeros(1,length(bl_inds)); % zero indicates baseline
        data_sbj_stim.(newname) = data_tmp_avg(:,bl_inds);
        for sti = 1:nstim
            stim_inds = find(data_sbj.time >= (ISI*(sti-1) + vid_params.t_stim(1)) & data_sbj.time <= (ISI*(sti-1) + vid_params.t_stim(2)));
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
%     data_all.time = data_sbj.time;
end

%% Load template brain 
load([code_root filesep 'vizualization',filesep,'Colin_cortex_left.mat']);
cmcortex.left = cortex;
load([code_root filesep 'vizualization',filesep,'Colin_cortex_left.mat']);
cmcortex.right = cortex;

%% Make video
cond = 'math';
colmap = 'PiYG'; %'RedsWhite','RedBlue'
center_zero = true; % symmetric (i.e. colormap centered at 0)
scale_neg = true; % if want to exaggerate the negative values (so easier to visualize)
scale_neg_factor = 2; % factor by which to multiply negative values

clim = [-0.15 0.15];
if scale_neg
    data_all_scale.wave.(cond) = data_all.wave.(cond);
    data_all_scale.wave.(cond)(data_all.wave.(cond)<0)=data_all.wave.(cond)(data_all.wave.(cond)<0)*scale_neg_factor;
    [col_idx,cols] = colorbarFromValues(data_all_scale.wave.(cond)(:), colmap,clim,center_zero); % range = 1-100;
else
    [col_idx,cols] = colorbarFromValues(data_all.wave.(cond)(:), colmap,clim,center_zero); % range = 1-100;
end

col_idx = reshape(col_idx,size(data_all.wave.(cond),1), size(data_all.wave.(cond),2));
MarkSizeEffect = 35;
if center_zero
    sizes = (abs(col_idx-50)+1)*MarkSizeEffect/100;
else
    sizes = col_idx*MarkSizeEffect/100;
end

% Plot Colorbar
figureDim = [0 0 .2 .2];
figure('units','normalized','outerposition',figureDim)
for i = 5:10:length(cols)
    plot(i, 1, '.', 'MarkerSize', (abs(i-50)+1)*100/100, 'Color', cols(i,:))
    hold on
end
axis off
dir_out = '/Users/amydaitch/Desktop/';
savePNG(gcf,400, [dir_out 'Reds.png'])

% shift all electrode positions to LH
data_all.elect_MNI(:,1) = -abs(data_all.elect_MNI(:,1));
data_all.elect_MNI2 = data_all.elect_MNI;
% medial_inds = find(data_all.elect_MNI(:,1)>-30);
% lateral_inds = find(data_all.elect_MNI(:,1)<-40);
% data_all.elect_MNI2(medial_inds,1)=data_all.elect_MNI(medial_inds,1)+20;
% data_all.elect_MNI2(lateral_inds,1)=data_all.elect_MNI(lateral_inds,1)-20;
% data_all.elect_MNI(:,1) = data_all.elect_MNI(:,1) - sum(data_all.(cond),2);

% Plot parameters
% mark = 'o';

%%
% colRing = [0 0 0]/255;
% time = data_all.time(find(data_all.time == -.2):max(find(data_sbj.time <= 5)));

F = struct;
count = 0;
% for e = 1:2:length(time)
for e = 1:length(data_all.stim_time.(cond))
    count = count+1;
    figure('Position',[200 200 1000 500])
    subplot(1,2,1)
    ctmr_gauss_plot(cmcortex.left,[0 0 0], 0, 'l', 1)
    alpha(0.7)
    % Sort to highlight larger channels
    for i = 1:size(data_all.elect_MNI,1)
%         f = plot3(el_mniPlot_all(i,1)/(1-abs(math_memo_norm_all(i,e))),el_mniPlot_all(i,2),el_mniPlot_all(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx_math_memo(i,e),:), 'MarkerSize', MarkSizeEffect*abs(math_memo_norm_all(i,e))+0.01);
%         f = plot3(data_all.elect_MNI(i,1),data_all.elect_MNI(i,2),data_all.elect_MNI(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(i,e),:), 'MarkerSize', MarkSizeEffect*abs(data_all.wave.(cond)(i,e))+0.01);     
        f = plot3(data_all.elect_MNI2(i,1),data_all.elect_MNI(i,2),data_all.elect_MNI(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(i,e),:), 'MarkerSize', sizes(i,e));    
    end
    if data_all.stim_num.(cond)(e) == 0 % baseline
        title(['Baseline:',newline,num2str(round(data_all.stim_time.(cond)(e)*100)/100),' s'],'FontSize',30)
    else
        title(['Stim ',num2str(data_all.stim_num.(cond)(e)),':',newline,num2str(round(data_all.stim_time.(cond)(e)*100)/100),' s'],'FontSize',30)
    end
    
    subplot(1,2,2)
    ctmr_gauss_plot(cmcortex.left,[0 0 0], 0, 'l', 2)
    alpha(0.7)
    % Sort to highlight larger channels
    for i = 1:size(data_all.elect_MNI,1)
%         f = plot3(el_mniPlot_all(i,1)/(1-abs(math_memo_norm_all(i,e))),el_mniPlot_all(i,2),el_mniPlot_all(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx_math_memo(i,e),:), 'MarkerSize', MarkSizeEffect*abs(math_memo_norm_all(i,e))+0.01);
%         f = plot3(data_all.elect_MNI(i,1),data_all.elect_MNI(i,2),data_all.elect_MNI(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(i,e),:), 'MarkerSize', MarkSizeEffect*abs(data_all.wave.(cond)(i,e))+0.01);     
        f = plot3(data_all.elect_MNI2(i,1),data_all.elect_MNI(i,2),data_all.elect_MNI(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(i,e),:), 'MarkerSize', sizes(i,e));    
    end

    if data_all.stim_num.(cond)(e) == 0 % baseline
        title(['Baseline:',newline,num2str(round(data_all.stim_time.(cond)(e)*100)/100),' s'],'FontSize',30)
    else
        title(['Stim ',num2str(data_all.stim_num.(cond)(e)),':',newline,num2str(round(data_all.stim_time.(cond)(e)*100)/100),' s'],'FontSize',30)
    end
%     title([time_tmp ' s'],'FontSize',30)
%     xlabel([time_tmp ' s'],'FontSize',30)
%     text(50, 15, -60, [time_tmp ' s'], 'FontSize', 40)
    cdata = getframe(gcf);
    F(count).cdata = cdata.cdata;
    F(count).colormap = [];
    close all
end

fig = figure;
movie(fig,F,1)

videoRSA = VideoWriter([dir_out 'Memoria_',cond,'_',sbj_names{1},'.avi']);
videoRSA.FrameRate = 10;  % Default 30
videoRSA.Quality = 100;    % Default 75
open(videoRSA);
writeVideo(videoRSA, F);
close(videoRSA);

