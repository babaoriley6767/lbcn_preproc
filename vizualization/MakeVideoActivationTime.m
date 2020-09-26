function MakeVideoActivationTime(sbj_names,project_name, conds_avg_field, conds_avg_conds, cond_plot, colormap_plot, dirs)

%% Load template brain
load([dirs.code_root filesep 'vizualization/Colin_cortex_left.mat']);
cmcortex.left = cortex;
load([dirs.code_root filesep 'vizualization/Colin_cortex_right.mat']);
cmcortex.right = cortex;

%% Avg task
% conditions to average
data_all = [];
for ii = 1:length(conds_avg_conds)
    % Initialize data_all
    data_all.(conds_avg_conds{ii}) = [];
end

%% Group data
decimate = true;
final_fs = 200;
concat_params = genConcatParams(decimate, final_fs);
concat_params.noise_method = 'trials';

plot_params = genPlotParams(project_name,'timecourse');
chan_plot = [];
for i = 1:length(sbj_names)
    %% Concatenate trials from all blocks
    block_names = BlockBySubj(sbj_names{i},project_name);
    data_sbj = ConcatenateAll(sbj_names{i},project_name,block_names,dirs,[],'Band','HFB','stim', concat_params);
    % Average across trials, normalize and concatenate across subjects
    for ii = 1:length(conds_avg_conds)
        data_tmp_avg = squeeze(nanmean(data_sbj.wave(strcmp(data_sbj.trialinfo.(conds_avg_field), conds_avg_conds{ii}),:,:),1)); % average trials by electrode
        %         data_tmp_norm = (data_tmp_avg-min(data_tmp_avg(:)))/(max(data_tmp_avg(:))-min(data_tmp_avg(:))); % normalize
        data_tmp_norm = data_tmp_avg/max(data_tmp_avg(:));
        data_all.(conds_avg_conds{ii}) = [data_all.(conds_avg_conds{ii});data_tmp_norm]; % concatenate across subjects
    end
    
    %% Concatenate channel coordinates
    % Load subjVar
    if exist([dirs.original_data filesep sbj_names{i} filesep 'subjVar_' sbj_names{i} '.mat'], 'file')
        load([dirs.original_data filesep sbj_names{i} filesep 'subjVar_' sbj_names{i} '.mat']);
    else
        warning('no subjVar, trying to create it')
        center = 'Stanford';
        fsDir_local = '/Applications/freesurfer/subjects/fsaverage';
        [fs_iEEG, fs_Pdio, data_format] = GetFSdataFormat(sbj_names{i}, center);
        subjVar = CreateSubjVar(sbj_names{i}, dirs, data_format, fsDir_local);
    end
    chan_plot = [chan_plot;subjVar.MNI_coord]; % concatenate electrodes across subjects
    
    if size(subjVar.MNI_coord,1) ~= size(data_sbj.wave,2) 
        error('channel labels mismatch, double check ppt and freesurfer')
    else
    end
end

%% Check for nans 
for i = 1:size(data_all.math,1)
    nan_sum(i) = sum(isnan(data_all.math(i,:)));
end
data_all.math = data_all.math(nan_sum==0,:);
chan_plot = chan_plot(nan_sum==0,:);



%% Get indices for colloring
[col_idx,cols] = colorbarFromValues(data_all.(cond_plot)(:), 'RedsWhite');
col_idx = reshape(col_idx,size(data_all.(cond_plot),1), size(data_all.(cond_plot),2));
% Highlight most active channels
chan_plot(:,1) = chan_plot(:,1) - sum(data_all.(cond_plot),2);


%% Plot parameters
mark = 'o';
MarkSizeEffect = 35;
colRing = [0 0 0]/255;
time = data_sbj.time(find(data_sbj.time == -.2):max(find(data_sbj.time <= 5)));


%% Plot math
figureDim = [0 0 .4 1];
f1 = figure('units', 'normalized', 'outerposition', figureDim);
views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right', 'left', 'right'};

F = struct;
count = 0;
for e = 1:2:length(time)
    count = count+1;
    
    for i = 1:length(views)
        subplot(3,2,i)
        ctmr_gauss_plot(cmcortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
        % Sort to highlight larger channels
        for ii = 1:size(chan_plot)
            %         f = plot3(el_mniPlot_all(i,1)/(1-abs(math_memo_norm_all(i,e))),el_mniPlot_all(i,2),el_mniPlot_all(i,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx_math_memo(i,e),:), 'MarkerSize', MarkSizeEffect*abs(math_memo_norm_all(i,e))+0.01);
            if (strcmp(hemis{i}, 'left') == 1 && chan_plot(ii,1) > 0) || (strcmp(hemis{i}, 'right') == 1 && chan_plot(ii,1) < 0)
            else
                plot3(chan_plot(ii,1),chan_plot(ii,2),chan_plot(ii,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(i,e),:), 'MarkerSize', MarkSizeEffect*abs(data_all.(cond_plot)(i,e))+0.01);
            end
        end
    end
    
    time_tmp = num2str(time(e));
    
    if length(time_tmp) < 6
        time_tmp = [time_tmp '00'];
    end
    if strcmp(time_tmp(1), '-')
        time_tmp = time_tmp(1:6);
    else
        if strcmp(time_tmp, '000')
        else
            time_tmp = time_tmp(1:5);
        end
    end
    
    text(50, 15, -60, [time_tmp ' s'], 'FontSize', 40)
    cdata = getframe(gcf);
    F(count).cdata = cdata.cdata;
    F(count).colormap = [];
    close all
end

fig = figure;
movie(fig,F,1)

dir_out = [dirs.result_root filesep project_name filesep sbj_name filesep 'Videos' filesep project_name filesep];
videoRSA = VideoWriter([dir_out conds_plot '.avi']);
videoRSA.FrameRate = 30;  % Default 30
videoRSA.Quality = 100;    % Default 75
open(videoRSA);
writeVideo(videoRSA, F);
close(videoRSA);

end