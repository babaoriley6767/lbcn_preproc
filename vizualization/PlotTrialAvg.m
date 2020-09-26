function h = PlotTrialAvg(data,column,conds,plot_params)

% plots average timecourse for each condition, separately for each electrode
% INPUTS:
%       data: can be either freq x trial x time  or trial x time
%       column: column of data.trialinfo by which to sort trials for plotting
%       conds:  cell containing specific conditions to plot within column (default: all of the conditions within column)
%               can group multiple conds together by having a cell of cells
%               (e.g. conds = {{'math'},{'autobio','self-internal'}})
%       col:    colors to use for plotting each condition (otherwise will
%               generate randomly)
%       plot_params:    controls plot features (see genPlotParams.m script)

if ndims(data.wave)==3 % if spectral data
    datatype = 'Spec';
else
    datatype = 'NonSpec';
end

if isempty(plot_params)
    plot_params = genPlotParams(project_name,'timecourse');
end

if ~plot_params.multielec
    ncategs = length(conds);
else
    ncategs = 1;
end

%%
winSize = floor(data.fsample*plot_params.sm);
gusWin= gausswin(winSize)/sum(gausswin(winSize));

plot_data = cell(1,ncategs);

if strcmp(datatype,'Spec')
    freq_inds = data.freqs >= plot_params.freq_range(1) & data.freqs <= plot_params.freq_range(2);
    data.wave = squeeze(nanmean(data.wave(freq_inds,:,:)));  % avg across freq. domain
end

data.wave = convn(data.wave,gusWin','same');

% group data by conditions
if plot_params.multielec
    groupall = true;
else
    groupall = false;
end

% if plotting single trials, include noisy trials so can plot in different color
[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],groupall);

[grouped_trials,cond_names] = groupConds(conds,data.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,groupall);
% if eliminating noisy trials, keep track of how many clean trials remain for
% each condition (and include in figure legend)
if (strcmp(plot_params.noise_method,'trials'))
    for gi = 1:length(cond_names)
        cond_names{gi} = [cond_names{gi},' (',num2str(length(grouped_trials{gi})),' of ',num2str(length(grouped_trials_all{gi})), ' trials)'];
    end
end

plot_data = cell(1,ncategs); % with noisy epochs excluded
plot_data_all = cell(1,ncategs); %including noisy epochs
for ci = 1:ncategs
    plot_data{ci} = data.wave(grouped_trials{ci},:);
    plot_data_all{ci} = data.wave(grouped_trials_all{ci},:);
end

% smooth and plot data
if plot_params.single_trial
    figureDim = [0 0 .5 1];
else
    figureDim = [0 0 .4 .5];
end
figure('units', 'normalized', 'outerposition', figureDim)


hold on
for ci = 1:ncategs
    %     plot_data{ci} = convn(plot_data{ci},gusWin','same');
    lineprops.col{1} = plot_params.col(ci,:);
    if plot_params.single_trial
        %         subplot(ncategs,1,ci)
        subplot(ncategs/2,2,ci)
        plot(data.time,plot_data_all{ci}', 'r')
        hold on
        plot(data.time,plot_data{ci}', 'Color', [.5 .5 .5]) % plot over non-noisy trials in grey
        %         plot(data.time,plot_data{ci}', 'Color', [.5 .5 .5]) % plot over non-noisy trials in grey
        title(cond_names{ci}, 'Interpreter', 'none')
        y_lim = [-1 15];
        %         y_lim = [max(-5,min(plot_data_all{ci}(:))),min(plot_params.ylim_min,max(plot_data_all{ci}(:)))];
        
        xlim(plot_params.xlim)
        ylim(y_lim)
        xlabel(plot_params.xlabel)
        ylabel(plot_params.ylabel)
        set(gca,'fontsize',plot_params.textsize)
        box off
        %         if ci < ncategs -2
        %             set(gca,'xtick',[])
        %             xlabel([])
        %
        %         else
        %         end
        
        if size(data.trialinfo.allonsets,2) > 1
            time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
            for i = 1:length(time_events)
                plot([time_events(i) time_events(i)],ylim,'Color', [.5 .5 .5], 'LineWidth',1)
            end
        else
            
        end
        plot([0 0],ylim, 'Color', [0 0 0], 'LineWidth',2)
        plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
        
        box on
    else
        if ~strcmp(plot_params.eb,'none')
            if isfield(plot_params, 'ylim')
                ylim(plot_params.ylim);
            else
            end
            
            lineprops.style= '-';
            lineprops.width = plot_params.lw;
            lineprops.edgestyle = '-';
            if strcmp(plot_params.eb,'ste')
                if size(plot_data{ci},1) == 1
                    plot_data{ci} = [plot_data{ci}; plot_data{ci}]; % plot_data has to have at least 2 trials for sd
                else
                end
                hold on
                %                 plot(data.time,nanmean(plot_data{ci}) + nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)), 'Color', plot_params.col(ci,:), 'LineWidth', 1)
                %                 plot(data.time,nanmean(plot_data{ci}) - nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)), 'Color', plot_params.col(ci,:), 'LineWidth', 1)
                if ~isempty(plot_data{ci})
                    mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
                else
                    plot(data.time,zeros(size(data.time,2),1)');
                end
                %                mseb(data.time,nanmedian(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
                hold on
            else %'std'
                mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);
                %                 mseb(data.time,nanmedian(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);i
                hold on
            end
            %             y_lim = ylim;
            %             ylim([-1 y_lim(2)])
        end
    end
    if ~isempty(plot_data{ci})
        h(ci)=plot(data.time,nanmean(plot_data{ci}),'LineWidth',plot_params.lw,'Color',plot_params.col(ci,:));
    else
        h(ci) = plot(data.time,zeros(size(data.time,2),1)');
    end
    %     h(ci)=plot(data.time,nanmedian(plot_data{ci}),'LineWidth',plot_params.lw,'Color',plot_params.col(ci,:));
    hold on
end

if ~plot_params.single_trial
    xlim(plot_params.xlim)
    
    xlabel(plot_params.xlabel);
    ylabel(plot_params.ylabel)
    
    set(gca,'fontsize',plot_params.textsize)
    box off
    
    %% Plot lines to mark events
    y_lim = ylim;
    
    if isempty(plot_params.xlines)
        if size(data.trialinfo.allonsets,2) > 1
            time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
        else
            time_events = [0 0];
        end
    else
        time_events = plot_params.xlines;
    end
    
    time_events = time_events/10;
    
    if ~isempty(time_events)
        for i = 1:length(time_events)
            plot([time_events(i) time_events(i)],y_lim,'Color', [.5 .5 .5], 'LineWidth',1)
        end
    else
    end
    
    
    %         time_events = [mean(data.trialinfo.int_cue_targ_time(strcmp(data.trialinfo.condNames_interval, '1'))), ...
    %                        mean(data.trialinfo.int_cue_targ_time(strcmp(data.trialinfo.condNames_interval, '2'))), ...
    %                        mean(data.trialinfo.int_cue_targ_time(strcmp(data.trialinfo.condNames_interval, '3'))), ...
    %                        mean(data.trialinfo.int_cue_targ_time(strcmp(data.trialinfo.condNames_interval, '4'))), ...
    %                        mean(data.trialinfo.int_cue_targ_time(strcmp(data.trialinfo.condNames_interval, '5')))]/1000
    %
    %         for i = 1:length(time_events)
    %             plot([time_events(i) time_events(i)],y_lim,'Color', [.5 .5 .5], 'LineWidth',1)
    %         end
    
    
    
    
    
    % %
    % %     end
    plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
    %     plot([.5 .5],y_lim, 'Color', [0 0 0], 'LineWidth',1)
    %     plot([1.2 1.2],y_lim, 'Color', [0 0 0], 'LineWidth',1)
    %
    plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
    ylim(y_lim)
    
    box on % Pedro concluded
end

set(gcf,'color','w')

if plot_params.legend && ~plot_params.single_trial
    leg = legend(h,cond_names,'Location','Northeast', 'AutoUpdate','off', 'Interpreter', 'none');
    legend boxoff
    set(leg,'fontsize',14, 'Interpreter', 'none')
end

