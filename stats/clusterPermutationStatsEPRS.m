function [pval, t_orig, clust_info] = clusterPermutationStatsEPRS(data,column,conds,plot_params,stats_params)
% plots spectrogram for each condition, separately for each electrode
%% INPUTS:
%       data: spectral data(freq x trials x time)
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all)
%       plot_params:    controls plot features (see genPlotParams.m script)

%%

if isempty(plot_params)
    plot_params = genPlotParams(project_name,'ERSP');
end

if isempty(stats_params)
    stats_params = genStatsParams(project_name,'ERSP');
end

if isempty(conds)
    conds = unique(data.trialinfo.(column));
end
ncategs = length(conds);

winSize = floor(data.fsample*plot_params.sm);
gusWin= gausswin(winSize)/sum(gausswin(winSize));

%%

% organize trials by categories
[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],false);
[grouped_trials,cond_names] = groupConds(conds,data.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,false);

plot_data = cell(1,ncategs);
for ci = 1:ncategs
    plot_data{ci} = data.wave(:,grouped_trials{ci},:);
end

% Set the range of the plot
clim_hi = prctile(data.wave(:), 90);
if isnan(clim_hi)
    plot_params.clim = [-1 1];
elseif (clim_hi>0)
    plot_params.clim = [-clim_hi clim_hi];
else
    plot_params.clim = [clim_hi -clim_hi];
end

freq_ticks = 1:4:length(data.freqs);
freq_labels = cell(1,length(freq_ticks));
for i = 1:length(freq_ticks)
    freq_labels{i}=num2str(round(data.freqs(freq_ticks(i))));
end
fnn=eye(size(plot_data{1},1));
fnn_indx=find(fnn==1);
fnn_indx1=fnn_indx-1;
fnn_indx2=fnn_indx+1;
fnn(fnn==1)=nan;
chan_hood=fnn;
chan_hood(fnn_indx1(2:end))=1;
chan_hood(fnn_indx2(1:end-1))=1;

%% one condition and plot data
if ncategs == 1
    % define the adjacency
    
    % statics
    data1 = plot_data{1};
    tm=size(data1,2);   % trial number
    data1=permute(data1,[1,3,2]);
    % Example stats for one sample t-test
    [pval, t_orig, clust_info, seed_state, est_alpha] = clust_perm1(data1,chan_hood,stats_params.nreps,stats_params.fwer,stats_params.tail,stats_params.alpha,1);
    
    % creat mask
    
    pvalsig = find(pval<=0.05);
    mask = pval;
    mask (mask>est_alpha)=2;
    mask (mask<=est_alpha)=1; %???use est_alpha or not?
    mask (mask ==2) =0;
    
    % plot
    figureDim = [0 0 .3 .4];
    figure('units', 'normalized', 'outerposition', figureDim)
    
    ersp_tmp = squeeze(nanmean(plot_data{1},2)); % average across trials
    if ~isempty(ersp_tmp)
        %ersp_all{ci} = convn(ersp_tmp,gusWin','same');
        ersp_all{ci}=ersp_tmp;
        imagesc(data.time,1:length(data.freqs),ersp_all{ci},plot_params.clim)
    else
        imagesc(data.time,1:length(data.freqs),nan(length(data.time),length(data.freqs)),[-1 1])
    end
    hold on
    contour(data.time,1:length(data.freqs),mask, 1,':', 'LineWidth', 1.5, 'Color', 'k');
    hc=colorbar;
    title (hc,'ERSP')
    colorbar
    axis xy
    hold on
    colormap(plot_params.cmap);
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    if strcmp(plot_params.noise_method,'trials')
        title([strrep(cond_names{1},'_','-'),' (',num2str(length(grouped_trials{1})),' of ',num2str(length(grouped_trials_all{1})), ' trials)']);
    else
        title(strrep(cond_names{1},'_','-'))
    end
    xlabel(plot_params.xlabel);
    ylabel(plot_params.ylabel)
    xlim(plot_params.xlim)
    set(gca,'fontsize',plot_params.textsize)
    box off
    y_lim = ylim;
    plotLines(data, y_lim)
    
else
    %% two conditions statics
    data1 = plot_data{1};
    data2 = plot_data{2};
    tn1 = size (data1,2);
    tn2 = size (data2,2);
    tm  = min(tn1,tn2);
    clear plot_data
    % if the first condition has more trials, randomly selected the trials (the number of trials is same as the second condition)
    if tn1>= tn2
        tnn = randperm(tn1);
        plot_data{1}=squeeze(data1(:,tnn(1:tn2),:));
        plot_data{2}=squeeze(data2);
        
        data1 = permute(data1(:,tnn(1:tn2),:),[1,3,2]);
        data2 = permute(data2,[1,3,2]);
    elseif tn1<tn2
        tnn = randperm(tn2);
        plot_data{1}=squeeze(data1);
        plot_data{2}=squeeze(data2(:,tnn(1:tn1),:));
        
        data2 = permute(data2(:,tnn(1:tn1),:),[1,3,2]);
        data1 = permute(data1,[1,3,2]);
    end
    
    % two conditions should have the same trials
    [pval, t_orig, clust_info, seed_state, est_alpha] = clust_perm2(data1, data2,chan_hood,stats_params.nreps,stats_params.fwer,stats_params.tail,stats_params.alpha,1);
   
    
    pvalsig = find(pval<=0.05);
    mask = pval;
    mask (mask>est_alpha)=2;
    mask (mask<=est_alpha)=1; %???use est_alpha or not?
    mask (mask ==2) =0;
    
    
    
    figureDim = [0 0 1 .6];
    figure('units', 'normalized', 'outerposition', figureDim)
    
    for ci = 1:ncategs
        subplot(1,ncategs+1,ci)
        ersp_tmp = squeeze(nanmean(plot_data{ci},2)); % average across trials
        if ~isempty(ersp_tmp)
            ersp_all{ci} = convn(ersp_tmp,gusWin','same');
            imagesc(data.time,1:length(data.freqs),ersp_all{ci},plot_params.clim)
        else
            imagesc(data.time,1:length(data.freqs),nan(length(data.time),length(data.freqs)),[-1 1])
        end
        hcb=colorbar;
        title(hcb,'ERSP')
        axis xy
        hold on
        colormap(plot_params.cmap);
        set(gca,'YTick',freq_ticks)
        set(gca,'YTickLabel',freq_labels)
        plot([0 0],ylim,'k-','LineWidth',3)
        if strcmp(plot_params.noise_method,'trials')
            title([strrep(cond_names{ci},'_','-'),' (',num2str(tm),' of ',num2str(length(grouped_trials_all{ci})), ' trials)']);
        else
            title(strrep(cond_names{ci},'_','-'))
        end
        xlabel(plot_params.xlabel);
        ylabel(plot_params.ylabel)
        xlim(plot_params.xlim)
        set(gca,'fontsize',plot_params.textsize)
        box off
        y_lim = ylim;
        plotLines(data, y_lim)
    end
    
    % Plot the difference
    subplot(1,ncategs+1,ci+1)
    if ~isempty(ersp_all{1}) && ~isempty(ersp_all{2})
        % data_tmp_diff = ersp_all{1} - ersp_all{2};
        imagesc(data.time,1:length(data.freqs),t_orig,plot_params.clim*2.5)
    else
        imagesc(data.time,1:length(data.freqs),nan(length(data.time),length(data.freqs)),plot_params.clim*2.5)
    end
    
    hold on
    contour(data.time,1:length(data.freqs),mask, 1,':', 'LineWidth', 1.5, 'Color', 'k');
    hc=colorbar;
    title (hc,'t-value')
    
    %colorbar
    axis xy
    hold on
    colormap(plot_params.cmap);
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    % title('difference')
    xlabel(plot_params.xlabel);
    ylabel(plot_params.ylabel)
    xlim(plot_params.xlim)
    set(gca,'fontsize',plot_params.textsize)
    box off
    
end


%% Plot lines to mark events

plotLines(data, y_lim)

set(gcf,'color','w')

end


function plotLines(data, y_lim)

if size(data.trialinfo.allonsets,2) > 1
    time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
    for i = 1:length(time_events)
        plot([time_events(i) time_events(i)],y_lim,'Color', [0 0 0], 'LineWidth',2)
    end
else
    
end
plot([0 0],y_lim,'Color', [0 0 0], 'LineWidth',2)
plot(xlim,[0 0],'Color', [0 0 0], 'LineWidth',2)
ylim(y_lim)

end

