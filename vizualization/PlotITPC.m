function PlotITPC(data,column,conds,plot_params)
% Plots inter-trial phase coherence for each condition
% INPUTS:
%       data: spectral data(freq x trials x time)
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all)
%       plot_params:    .label: 'name','number', or 'none'
%                       .textsize: text size of axis labels, etc
%                       .xlabel
%                       .ylabel
%                       .bl_win: baseline correction window
%                       .xlim
%                       .cmap
%                       .clim

if isempty(plot_params)
    plot_params = genPlotParams(project_name,'ITPC');
end

if isempty(conds)
    conds = unique(data.trialinfo.(column));
end
ncategs = length(conds);

% organize trials by categories
[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],false);
[grouped_trials,cond_names] = groupConds(conds,data.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,false);

plot_data = cell(1,ncategs);
for ci = 1:ncategs
    plot_data{ci} = data.phase(:,grouped_trials{ci},:);
end

freq_inds = [find(data.freqs >= plot_params.freq_range(1),1) find(data.freqs >= plot_params.freq_range(2),1)];

freq_ticks = 1:4:length(data.freqs);
freq_labels = cell(1,length(freq_ticks));
for i = 1:length(freq_ticks)
    freq_labels{i}=num2str(round(data.freqs(freq_ticks(i))));
end
%%
% plot data
figure('Position',[200 200 800 400])
for ci = 1:ncategs
%     itc_tmp = squeeze(nanmean(exp(1i*(angle(plot_data{ci}))),2));
    itc_tmp = squeeze(abs(nanmean(exp(1i*(plot_data{ci})),2))); % average across trial dimension
    subplot(1,ncategs,ci)
    imagesc(data.time,1:length(data.freqs),itc_tmp,plot_params.clim)
    axis xy
    hold on
    colormap(plot_params.cmap)
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    if strcmp(plot_params.noise_method,'trials')
        title([cond_names{1},' (',num2str(length(grouped_trials{1})),' of ',num2str(length(grouped_trials_all{1})), ' trials)']);
    else
        title([cond_names{1}])
    end
    xlabel(plot_params.xlabel)
    ylabel(plot_params.ylabel)
    xlim(plot_params.xlim)
    ylim(freq_inds)
    box off
    
    set(gca,'fontsize',plot_params.textsize)
    y_lim = ylim;
    plotLines(data, y_lim)
end
hcb=colorbar;
title(hcb,'ITPC')

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