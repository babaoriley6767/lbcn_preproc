function PlotERSP(data,column,conds,plot_params)
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

% plot data
if ncategs == 1
    figureDim = [0 0 .3 .4];
    figure('units', 'normalized', 'outerposition', figureDim)
    ersp_tmp = squeeze(nanmean(plot_data{1},2)); % average across trials
    if ~isempty(ersp_tmp)
        ersp_all{ci} = convn(ersp_tmp,gusWin','same');
        imagesc(data.time,1:length(data.freqs),ersp_all{ci},plot_params.clim)
    else
        imagesc(data.time,1:length(data.freqs),nan(length(data.time),length(data.freqs)),[-1 1])
    end
    colorbar
    axis xy
    hold on
    colormap(plot_params.cmap);
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    if strcmp(plot_params.noise_method,'trials')
        title([cond_names{1},' (',num2str(length(grouped_trials{1})),' of ',num2str(length(grouped_trials_all{1})), ' trials)']);
    else
        title([cond_names{1}])
    end
    xlabel(plot_params.xlabel);
    ylabel(plot_params.ylabel)
    xlim(plot_params.xlim)
    set(gca,'fontsize',plot_params.textsize)
    box off
    y_lim = ylim;
%     plotLines(data, y_lim)


plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
plot([.5 .5],y_lim, 'Color', [0 0 0], 'LineWidth',1)
plot([1.2 1.2],y_lim, 'Color', [0 0 0], 'LineWidth',1)

plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
ylim(y_lim)
    
else
    figureDim = [0 0 1 .4];
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
            title([cond_names{ci},' (',num2str(length(grouped_trials{ci})),' of ',num2str(length(grouped_trials_all{ci})), ' trials)']);
        else
            title([cond_names{ci}])
        end
        xlabel(plot_params.xlabel);
        ylabel(plot_params.ylabel)
        xlim(plot_params.xlim)
        set(gca,'fontsize',plot_params.textsize)
        box off
        y_lim = ylim;
         plotLines(data, y_lim)

% 
% 
%         plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
%         plot([.5 .5],y_lim, 'Color', [0 0 0], 'LineWidth',1)
%         plot([1.2 1.2],y_lim, 'Color', [0 0 0], 'LineWidth',1)
% 
%         plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
        ylim(y_lim)

        
        
    end
    
    % Plot the difference
    subplot(1,ncategs+1,ci+1)
    if ~isempty(ersp_all{1}) && ~isempty(ersp_all{2})
        data_tmp_diff = ersp_all{1} - ersp_all{2};
        imagesc(data.time,1:length(data.freqs),data_tmp_diff,plot_params.clim/2)
    else
        imagesc(data.time,1:length(data.freqs),nan(length(data.time),length(data.freqs)),plot_params.clim/2)
    end
    colorbar
    axis xy
    hold on
    colormap(plot_params.cmap);
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    title('difference')
    xlabel(plot_params.xlabel);
    ylabel(plot_params.ylabel)
    xlim(plot_params.xlim)
    set(gca,'fontsize',plot_params.textsize)
    box off
    
end


%% Plot lines to mark events

% plotLines(data, y_lim)
y_lim = ylim;


% plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
% plot([.5 .5],y_lim, 'Color', [0 0 0], 'LineWidth',1)
% plot([1.2 1.2],y_lim, 'Color', [0 0 0], 'LineWidth',1)
% 
% plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
% ylim(y_lim)

% 
% plot([0 0],y_lim,'Color', [0 0 0], 'LineWidth',2)
% plot(xlim,[0 0],'Color', [0 0 0], 'LineWidth',2)
% ylim(y_lim)
% 
% set(gcf,'color','w')

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

