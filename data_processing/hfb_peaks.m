

hfa = ft_selectdata(cfg, hfa) - this is hfb epoched
data - this is the cardata epoched

cfg = [];
cfg.latency = [0.5 1.2];
data = ft_selectdata(cfg, data);
hfa = ft_selectdata(cfg, hfa);

trialinfo = hfa.trialinfo

 
% bring data into spike format
for CH = 1:length(hfa.label)
    
    spike.time{CH} = [];
    spike.trial{CH} = [];
    
    for tr = 1:size(trialinfo,2)
        
        currentdat = squeeze(hfa.trial{tr}(CH,:));
        
        % detect peaks on that
        [val idx] = findpeaks(currentdat);
        
        % limit to before target presentation
                current_targ = nearest(hfa.time{1}, trialinfo{1}(tr,1)/1000);
        
        
%         dist    = hfa.time{1} - trialinfo{1}(tr,1)/1000;
%         dist(dist<0) = [];
%         minDist = min(dist);
%         current_targ = find(dist == minDist);
        
        
        val = val(find(idx < current_targ));
        idx = idx(find(idx < current_targ));
        
        spike.time{CH} = [spike.time{CH}, hfa.time{1}(idx)];
        spike.trial{CH} = [spike.trial{CH}, tr * ones(1,length(idx))];
        
    end
    
    spike.label{CH} = [hfa.label{CH}, '_sp'];
    
end

clear val idx

spike.trialtime = repmat([hfa.time{1}(1) hfa.time{1}(end)], size(trialinfo,2), 1);

% toggle spike presentation
spike = ft_checkdata(spike, 'datatype', 'raw', 'fsample', 500);
% 
% cfg = [];
% cfg.latency = [0.5 1.2];
% data = ft_selectdata(cfg, data);


% fuse spike and LFP events
cfg = [];
cfg.keeptrials = 'yes';
spike = ft_timelockanalysis(cfg, spike)
% spike.time = data.time;

spike = rmfield(spike, 'avg')
spike = rmfield(spike, 'var')
spike = rmfield(spike, 'dof')

for i = 1:200
    spike3.trial{i} = squeeze(spike.trial(i,:,:))
end

data_all = ft_appenddata([], data, spike)




for CH = 1:length(data.label)
    
    cfg              = [];
    cfg.timwin       = [-0.5 0.5]; % take 400 ms
    cfg.spikechannel = spike.label{CH};
    cfg.channel      = data.label(CH);
    cfg.latency      = [0.3 1.7];
    sta_erp          = ft_spiketriggeredaverage(cfg, data_all);
    
    GAERP(CH,:) = sta_erp.avg;
    
    % fft this result
    cfg = [];
    cfg.taper = 'hanning';
    cfg.method = 'mtmfft';
    cfg.foilim = [0 40];
    sta_freq = ft_freqanalysis(cfg, sta_erp);
    
    GA(CH,:) = sta_freq.powspctrm;
    
end


% fuse
sta_erp.avg = GAERP; clear GAERP
sta_erp.label = data.label;

sta_freq.powspctrm = GA; clear GA
sta_freq.label = data.label;

% save out
save([pathname, subj{s}, '/', subj{s}, '_sta'], 'sta*')

clear sta* spike data hfa all



%%

load([pathname, subj{s}, '/', subj{s}, '_hfa_cue'])
load([pathname, subj{s}, '/', subj{s}, '_data_cue_clean'])

% detect the peak times during the delay
cfg = [];
cfg.latency = [0.5 1.2];
hfa = ft_selectdata(cfg, hfa)
trialinfo = hfa.trialinfo


cfg = [];
cfg.latency = [0.5 1.2];
data = ft_selectdata(cfg, data)



% bring data into spike format
for CH = 1:length(hfa.label)
    
    spike.time{CH} = [];
    spike.trial{CH} = [];
    
    for tr = 1:size(trialinfo,2)
        
        currentdat = squeeze(hfa.trial{tr}(CH,:))';
        
        % detect peaks on that
        [val idx] = findpeaks(currentdat);
        
        % limit to before target presentation
        current_targ = nearest(hfa.time{1}, trialinfo{1}(tr)/1000);
        
        val = val(find(idx < current_targ));
        idx = idx(find(idx < current_targ));
        
        spike.time{CH} = [spike.time{CH}, hfa.time{1}(idx)];
        spike.trial{CH} = [spike.trial{CH}, tr * ones(1,length(idx))];
        
    end
    
    spike.label{CH} = [hfa.label{CH}, '_sp'];
    
end

clear val idx

spike.trialtime = repmat([hfa.time{1}(1) hfa.time{1}(end)], size(trialinfo,2), 1);

% toggle spike presentation
spike = ft_checkdata(spike, 'datatype', 'raw', 'fsample', 500);

% fuse spike and LFP events
cfg = [];
cfg.keeptrials = 'yes';
spike = ft_timelockanalysis(cfg, spike)
spike.time = data.time{1};

spike = rmfield(spike, 'avg')
spike = rmfield(spike, 'var')
spike = rmfield(spike, 'dof')

%% Correct data format
for ti = 1:length(data.trial)
    for ci = 1:size(data.trial{ti},1)
        trial_reo(ti,ci,:) = data.trial{ti}(ci,:);
    end
end
data.trial = trial_reo;
data.time = data.time{1};

all = ft_appenddata([], data, spike)



for CH = 1:length(data.label)
    
    cfg              = [];
    cfg.timwin       = [-0.350 0.350]; % take 400 ms
    cfg.spikechannel = spike.label{CH};
    cfg.channel      = data.label{CH};
    cfg.latency      = [0.5 1.2];
    cfg.method       = 'linear'
    sta_erp          = ft_spiketriggeredaverage(cfg, all);
    
    GAERP(CH,:) = sta_erp.avg;
    
    % fft this result
    cfg = [];
    cfg.taper = 'hanning';
    cfg.method = 'mtmfft';
    cfg.foilim = [0 40];
    sta_freq = ft_freqanalysis(cfg, sta_erp);
    
    GA(CH,:) = sta_freq.powspctrm;
    
end


% fuse
sta_erp.avg = GAERP; clear GAERP
sta_erp.label = data.label;

sta_freq.powspctrm = GA; clear GA
sta_freq.label = data.label;

% save out
save([dirs.result_root, filesep, sbj_name, '_sta.mat'], 'sta*')

clear sta* spike data hfa all


chan= find(strcmp(sta_erp.label, 'LM10'));

plot(sta_erp.avg(chan,:))


for i = 1:length(sta_freq.label)
    hold on    
    plot(sta_freq.freq, sta_freq.powspctrm(i,:))
    [y,x] =  max(sta_freq.powspctrm(i,:));
    x = sta_freq.freq(x);
    text(x,y, sta_freq.label{i})
end


for i = 1:length(sta_freq.label)
    hold on    
    plot(sta_erp.avg(i,:))
end



chan_name = 'LM8'
chan= find(strcmp(sta_erp.label, chan_name));



figure('units', 'normalized', 'outerposition', [0 0 .6 .4]) % [0 0 .6 .3]
set(gcf,'color','w')
subplot(1,2,1)
plot(sta_erp.time, sta_erp.avg(chan,:), 'k', 'LineWidth', 2.5)
xlim([-.350 .350])
xlabel('Time (s)')
ylabel('Amplitude (?V)')
set(gca,'fontsize',16)

subplot(1,2,2)
plot(sta_freq.freq(2:11), sta_freq.powspctrm(chan,2:11), 'k', 'LineWidth', 2.5)

hold on
plot(sta_freq.freq(2:11), nanmean(sta_freq.powspctrm(1:100,2:11)), 'k', 'LineWidth', 2.5)
lineprops.col{1} = [1 0 0]
lineprops.style= '-';
lineprops.width = plot_params.lw;
lineprops.edgestyle = '-';
mseb(sta_freq.freq(2:11),nanmean(sta_freq.powspctrm(1:100,2:11)),nanstd(sta_freq.powspctrm(1:100,2:11)/sqrt(100)),lineprops,1);


xlim([sta_freq.freq(2) sta_freq.freq(11)])
xlabel('Frequency')
ylabel('Power (?V2)')
set(gca,'fontsize',16)
save([dirs.result_root, filesep, sbj_name, '_sta.mat'], 'sta*')

savePNG(gcf, 300, [dirs.result_root, filesep, sbj_name, '_sta_pw_' chan_name '.png'])




plot(sta_freq.freq(2:11), nanmean(sta_freq.powspctrm(1:100,2:11)), 'k', 'LineWidth', 2.5)







