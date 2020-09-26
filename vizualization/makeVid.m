function makeVid(data_all,project_name,vid_params)
%% INPUTS
% column: column of trialinfo from which to select trials, based on conds
% conds: cond names (within column) to use to sort trials, e.g. {'math','autobio'}
% norm_by_subj: true or false (divide each subj/condition by its own max)

%% set paths
code_root = '/Users/amydaitch/Dropbox/Code/MATLAB/lbcn_preproc';
server_root = '/Volumes/neurology_jparvizi$/';
comp_root = '/Volumes/AmyData/ParviziLab';

if isempty(vid_params)
    vid_params = genVidParams(project_name);
end

%% Load template brain 
load([code_root filesep 'vizualization',filesep,'Colin_cortex_left.mat']);
cmcortex.left = cortex;
load([code_root filesep 'vizualization',filesep,'Colin_cortex_left.mat']);
cmcortex.right = cortex;

%% Make video
% cond = 'math';
% colmap = 'PiYG'; %'RedsWhite','RedBlue'
% center_zero = true; % symmetric (i.e. colormap centered at 0)
% scale_neg = true; % if want to exaggerate the negative values (so easier to visualize)
% scale_neg_factor = 2; % factor by which to multiply negative values
% 
% clim = [-0.15 0.15];
if scale_neg
    data_all_scale.wave.(cond) = data_all.wave.(cond);
    data_all_scale.wave.(cond)(data_all.wave.(cond)<0)=data_all.wave.(cond)(data_all.wave.(cond)<0)*vid_params.scale_neg_factor;
    [col_idx,cols] = colorbarFromValues(data_all_scale.wave.(cond)(:), vid_params.colmap,vid_params.clim,vid_params.center_zero); % range = 1-100;
else
    [col_idx,cols] = colorbarFromValues(data_all.wave.(cond)(:), vid_params.colmap,vid_params.clim,vid_params.center_zero); % range = 1-100;
end

col_idx = reshape(col_idx,size(data_all.wave.(cond),1), size(data_all.wave.(cond),2));

if center_zero
    sizes = (abs(col_idx-50)+1)*vid_params.MarkSizeEffect/100;
else
    sizes = col_idx*vid_params.MarkSizeEffect/100;
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
    alpha(vid_params.brain_alpha)
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
    alpha(vid_params.brain_alpha)
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

