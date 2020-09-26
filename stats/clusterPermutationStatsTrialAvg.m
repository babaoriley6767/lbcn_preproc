function [pval, t_orig, clust_info] = clusterPermutationStatsTrialAvg(data,column,conds,plot_params,stats_params)

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

if isempty(stats_params)
    stats_params = genStatsParams(project_name);
end

ncategs = length(conds);


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

groupall = false;


% if plotting single trials, include noisy trials so can plot in different color
[grouped_trials_all,~] = groupConds(conds,data.trialinfo,column,'none',[],groupall);

[grouped_trials,cond_names] = groupConds(conds,data.trialinfo,column,plot_params.noise_method,plot_params.noise_fields_trials,groupall);
% if eliminating noisy trials, keep track of how many clean trials remain for
% each condition (and include in figure legend)

plot_data = cell(1,ncategs); % with noisy epochs excluded
plot_data_all = cell(1,ncategs); %including noisy epochs
for ci = 1:ncategs
    plot_data{ci} = data.wave(grouped_trials{ci},:);
    plot_data_all{ci} = data.wave(grouped_trials_all{ci},:);
end

% smooth and plot data

figureDim = [0 0 .5 .5];
figure('units', 'normalized', 'outerposition', figureDim)


hold on
chan_hood=[];
if ncategs == 1
    % statics
    data1 = plot_data{1};
    tm=size(data1,2);   % trial number
    data1=permute(data1,[1,3,2]);
    data1=permute(data1,[2,3,1]);
    % Example stats for one sample t-test
    [pval, t_orig, clust_info, seed_state, est_alpha] = clust_perm1(data1,chan_hood,stats_params.nreps,stats_params.fwer,stats_params.tail,stats_params.alpha,1);
    
    % creat mask
    
    pvalsig = find(pval<=0.05);
    mask = pval;
    mask (mask>est_alpha)=2;
    mask (mask<=est_alpha)=1; %???use est_alpha or not?
    mask (mask ==2) =0;
    
else
    data1 = plot_data{1};
    data2 = plot_data{2};
    tn1 = size (data1,1);
    tn2 = size (data2,1);
    tm  = min(tn1,tn2);
    clear plot_data
    % if the first condition has more trials, randomly selected the trials (the number of trials is same as the second condition)
    if tn1>= tn2
        tnn = randperm(tn1);
        plot_data{1}=data1(tnn(1:tn2),:);
        plot_data{2}=data2;
        
        
    elseif tn1<tn2
        tnn = randperm(tn2);
        plot_data{1}=data1;
        plot_data{2}=data2(tnn(1:tn1),:);
        
    end
    
    data1 = permute( plot_data{1},[1,3,2]);
    data2 = permute( plot_data{2},[1,3,2]);
    
    data1= permute(data1,[2,3,1]);
    data2= permute(data2,[2,3,1]);
    % two conditions should have the same trials
    [pval, t_orig, clust_info, seed_state, est_alpha] = clust_perm2(data1, data2,chan_hood,stats_params.nreps,stats_params.fwer,stats_params.tail,stats_params.alpha,1);
    
    pvalsig = find(pval<=0.05);
    mask = pval;
    mask (mask>est_alpha)=2;
    mask (mask<=est_alpha)=1; %???use est_alpha or not?
    mask (mask ==2) =0;
end

if (strcmp(plot_params.noise_method,'trials'))
    for gi = 1:length(cond_names)
        cond_names{gi} = [cond_names{gi},' (',num2str(tm),' of ',num2str(length(grouped_trials_all{gi})), ' trials)'];
    end
end


for ci = 1:ncategs
    %     plot_data{ci} = convn(plot_data{ci},gusWin','same');
    lineprops.col{1} = plot_params.col(ci,:);
    
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
            %   plot(data.time,nanmean(plot_data{ci}) + nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)), 'Color', plot_params.col(ci,:), 'LineWidth', 1)
            % plot(data.time,nanmean(plot_data{ci}) - nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)), 'Color', plot_params.col(ci,:), 'LineWidth', 1)
            mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
            %mseb(data.time,nanmedian(plot_data{ci}),nanstd(plot_data{ci})/sqrt(size(plot_data{ci},1)),lineprops,1);
            hold on
        else %'std'
            mseb(data.time,nanmean(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);
            %                 mseb(data.time,nanmedian(plot_data{ci}),nanstd(plot_data{ci}),lineprops,1);
            hold on
        end
        %             y_lim = ylim;
        %             ylim([-1 y_lim(2)])
    end
    
    h(ci)=plot(data.time,nanmean(plot_data{ci}),'LineWidth',plot_params.lw,'Color',plot_params.col(ci,:));
    %     h(ci)=plot(data.time,nanmedian(plot_data{ci}),'LineWidth',plot_params.lw,'Color',plot_params.col(ci,:));
    hold on
end

hold on
if ~isempty(find(mask>0, 1))
    plot (data.time(find(mask>0)),-0.5*ones(numel(find(mask>0))), '*','Color','b','LineWidth',0.5)
end


xlim(plot_params.xlim)

xlabel(plot_params.xlabel);
ylabel(plot_params.ylabel)

set(gca,'fontsize',plot_params.textsize)
box off

%% Plot lines to mark events
y_lim = ylim;

if size(data.trialinfo.allonsets,2) > 1
    time_events = cumsum(nanmean(diff(data.trialinfo.allonsets,1,2)));
    for i = 1:length(time_events)
        plot([time_events(i) time_events(i)],y_lim,'Color', [.5 .5 .5], 'LineWidth',1)
    end
else
    
end
plot([0 0],y_lim, 'Color', [0 0 0], 'LineWidth',2)
plot(xlim,[0 0], 'Color', [.5 .5 .5], 'LineWidth',1)
ylim(y_lim)

box off % Pedro concluded


set(gcf,'color','w')

if plot_params.legend && ~plot_params.single_trial
    leg = legend(h,cond_names,'Location','Northeast', 'AutoUpdate','off');
    legend boxoff
    set(leg,'fontsize',14, 'Interpreter', 'none')
end
end

