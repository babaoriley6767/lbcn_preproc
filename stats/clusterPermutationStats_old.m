function [pval, t_orig, clust_info, seed_state, est_alpha,timing,issig,time_events] = clusterPermutationStats(data,column,conds,stats_params,isplot,plot_params,datatype)

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

%load('cdcol.mat')

if ndims(data.wave)==3 % if spectral data
    datatype = 'Spec';
else
    datatype = 'Band';
end

if isempty(stats_params)
    stats_params = genStatsParams(project_name);
end

if isempty(plot_params)
    
    if strcmp(datatype,'Band')
        plot_params = genPlotParams(project_name,'timecourse');
    elseif strcmp(datatype, 'Spec')
        plot_params = genPlotParams(project_name,'ERSP');
    end
end

ncategs = length(conds);
%%
if stats_params.smooth
    winSize = floor(data.fsample*stats_params.sm);
    gusWin= gausswin(winSize)/sum(gausswin(winSize));
    
end

%% time window
time_inds = find(data.time >= plot_params.xlim(1) & data.time <= plot_params.xlim(2));
%bl_inds = find(data.time >= stats_params.bl_win(1) & data.time < stats_params.bl_win(2));

if strcmp(datatype,'Band')
    data.wave=data.wave(:,time_inds,:);  
elseif strcmp(datatype,'Spec')
    data.wave=data.wave(:,:,time_inds);  
end

data.time=data.time(time_inds);

if strcmp(datatype,'Band') && stats_params.smooth
    data.wave = convn(data.wave,gusWin','same');
end

% if plotting single trials, include noisy trials so can plot in different color
[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],false);

[grouped_trials,cond_names] = groupConds(conds,data.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,false);
% if eliminating noisy trials, keep track of how many clean trials remain for

plot_data = cell(1,ncategs); % with noisy epochs excluded
plot_data_all = cell(1,ncategs); %including noisy epochs

for ci = 1:ncategs
    
    if strcmp (datatype,'Band')
        plot_data{ci}(1,:,:) = data.wave(grouped_trials{ci},:);
        plot_data_all{ci}(1,:,:) = data.wave(grouped_trials_all{ci},:);
    elseif strcmp (datatype,'Spec')
        plot_data{ci} = data.wave(:,grouped_trials{ci},:);
        plot_data_all{ci} = data.wave(:,grouped_trials_all{ci},:);
    end
    
end

if strcmp (datatype,'Band')
    chan_hood=[];
elseif strcmp (datatype,'Spec')
    fnn=eye(size(data.wave,1));
    fnn_indx=find(fnn==1);
    fnn_indx1=fnn_indx-1;
    fnn_indx2=fnn_indx+1;
    fnn(fnn==1)=nan;
    chan_hood=fnn;
    chan_hood(fnn_indx1(2:end))=1;
    chan_hood(fnn_indx2(1:end-1))=1;
end
clear data1 data2;
if ncategs==1
    
    data1 = plot_data{1};
    tm=size(data1,2);
    data1=permute(data1,[1,3,2]);
    % Example stats for one sample t-test
    [pval, t_orig, clust_info, seed_state, est_alpha] = clust_perm1(data1,chan_hood,stats_params.nreps,stats_params.fwer,stats_params.tail,stats_params.alpha,1);
    plot_data{1}=squeeze(plot_data{1});
else
    
    data1 = plot_data{1};
    data2 = plot_data{2};
    tn1 = size (data1,2);
    tn2 = size (data2,2);
    tm  = min(tn1,tn2);
    clear plot_data
    %% if the first condition has more trials, randomly selected the trials (the number of trials is same as the second condition)
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
    tnn=[];tnn(1)=size(data1,3); tnn(2)=size(data2,3);
end
snp=[];
snn=[];
pvalsig=[];


pvalsig = find(pval<=0.05);
mask = pval;
mask (mask>est_alpha)=2;
mask (mask<=est_alpha)=1; %???use est_alpha or not?
%mask (mask>0.05)=2;
%mask (mask<=0.05)=1;
mask (mask ==2) =0;


%t0=find(data.time>=0);
% Plot
timing.start=nan;
timing.stop=nan;
timing.duration=nan;
issig=0;
  time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
if isplot && ~isempty(pvalsig)
    issig=1;
    if strcmp (datatype,'Band')
        snp=intersect(pvalsig,find(t_orig>=0));
        snn=intersect(pvalsig,find(t_orig<0));
        
   
        if ~isempty(snp)     
            diff_snp=find(diff(snp)>=5);   % if 5 time bin non-significant, cluster stop
            diff_snp=diff_snp(find(diff_snp>snp(1),1));
            timing.start=data.time(snp(1));
            if ~isempty(diff_snp)
                timing.stop = data.time(diff_snp);
            else
                timing.stop = data.time(snp(end));
            end    
            timing.duration =timing.stop-timing.start;
 
        end
        
        
        if (strcmp(stats_params.noise_method,'trials'))
            for gi = 1:length(cond_names)
                cond_names{gi} = [cond_names{gi},' (',num2str(tm),' of ',num2str(length(grouped_trials_all{gi})), ' trials)'];
            end
        end
        
        
        %  plot data
%         figureDim = [0 0 .3 .4];
%         figure('units', 'normalized', 'outerposition', figureDim)
        
        
        for ci = 1:ncategs
            %     plot_data{ci} = convn(plot_data{ci},gusWin','same');
            lineprops.col{1} = plot_params.col(ci,:);
            
            if ~strcmp(plot_params.eb,'none')
                lineprops.style= '-';
                lineprops.width = plot_params.lw;
                lineprops.edgestyle = '-';
                if strcmp(plot_params.eb,'ste')
                    if size(plot_data{ci},1) == 1
                        plot_data{ci} = [plot_data{ci}; plot_data{ci}]; % plot_data has to have at least 2 trials for sd
                    else
                    end
                    mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
                    hold on
                else %'std'
                    mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);
                    hold on
                end
            end
            
            h(ci)=plot(data.time,nanmean(plot_data{ci}),'LineWidth',plot_params.lw,'Color',plot_params.col(ci,:));
            hold on
        end
        plot(data.time(snp), zeros(length(snp),1)', '*','Color','b')
        hold on
        plot(data.time(snn), zeros(length(snn),1)', 'o','Color','g')
        
        xlim([data.time(1),data.time(end)])
        
        xlabel(plot_params.xlabel);
        ylabel(plot_params.ylabel)
        
        set(gca,'fontsize',plot_params.textsize)
        box off
        
        %% Plot lines to mark events
        y_lim = ylim;
        
        if size(data.trialinfo.allonsets,2) > 1
          
            for i = 1:length(time_events)
                plot([time_events(i) time_events(i)],y_lim,'Color', [.5 .5 .5], 'LineWidth',1)
            end
        else
            
        end
        plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
        plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
        ylim(y_lim)
        
        box on % Pedro concluded
        
        set(gcf,'color','w')
        
        if plot_params.legend
            leg = legend(h,cond_names,'Location','Northeast', 'AutoUpdate','off');
            legend boxoff
            set(leg,'fontsize',14, 'Interpreter', 'none')
        end
        
    elseif strcmp (datatype, 'Spec')
        
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
                title([cond_names{1},' (',num2str(tnn(1)),' of ',num2str(length(grouped_trials_all{1})), ' trials)']);
            else
                title([cond_names{1}])
            end
            xlabel(plot_params.xlabel);
            ylabel(plot_params.ylabel)
            xlim(plot_params.xlim)
            set(gca,'fontsize',plot_params.textsize)
            box off
            y_lim = ylim;
            plotLines(data, y_lim)
            
        else
            figureDim = [0 0 .8 .4];
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
                    title([cond_names{ci},' (',num2str(tnn(ci)),' of ',num2str(length(grouped_trials_all{ci})), ' trials)']);
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
            end
            
            % Plot the difference
            subplot(1,ncategs+1,ci+1)
            if ~isempty(ersp_all{1}) && ~isempty(ersp_all{2})
                data_tmp_diff = t_orig; %ersp_all{1} - ersp_all{2};
                imagesc(data.time,1:length(data.freqs),data_tmp_diff,plot_params.clim*4)
                
            else
                imagesc(data.time,1:length(data.freqs),nan(length(data.time),length(data.freqs)),plot_params.clim/2)
            end
            
            hold on
            contour(data.time,1:length(data.freqs),mask, 1,':', 'LineWidth', 1.5, 'Color', 'k');
            hc=colorbar;
            title (hc,'t value')
            axis xy
            hold on
            colormap(plot_params.cmap);
            set(gca,'YTick',freq_ticks)
            set(gca,'YTickLabel',freq_labels)
            %             set(gca, 'XTick', x_ticks)
            %             set(gca, 'XTickLabel', x_labels)
            plot([0 0],ylim,'k-','LineWidth',3)
            title('Difference')
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
end
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




