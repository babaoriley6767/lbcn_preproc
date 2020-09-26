function [sta_erp, sta_freq] = HFBNested(hfa, data, latency, timwin)
%%
% latency = where to look for peaks (e.g. cue target interval)
% timwin = window for locking each peak
%%
%
% for tr = 1:size(hfa.trial,1)
%     hfa.trial = hfa.trial(tr,:,:);
%     hfa.trialinfo = hfa.trialinfo(tr,:);
%     data.trial = data.trial(tr,:,:);
%     data.trialinfo = data.trialinfo(tr,:);

% detect the peak times during the delay

cfg = [];
cfg.latency = latency;
hfa = ft_selectdata(cfg, hfa);
trialinfo = hfa.trialinfo(:,1);

spike = [];
% bring data into spike format
for CH = 1:length(hfa.label)
    
    spike.time{CH} = [];
    spike.trial{CH} = [];
    
    for tr = 1:size(trialinfo,1)
        
        currentdat = squeeze(hfa.trial(tr,CH,:))';
        
        % detect peaks on that
        [val idx] = findpeaks(currentdat);
        
        % limit to before target presentation
        current_targ = nearest(hfa.time, trialinfo(tr)/1000);
        
        val = val(find(idx < current_targ));
        idx = idx(find(idx < current_targ));
        
        spike.time{CH} = [spike.time{CH}, hfa.time(idx)];
        spike.trial{CH} = [spike.trial{CH}, tr * ones(1,length(idx))];
        
    end
    spike.label{CH} = [hfa.label{CH}, '_sp'];
end

clear val idx

spike.trialtime = repmat([hfa.time(1) hfa.time(end)], size(trialinfo,1), 1);

% toggle spike presentation
spike = ft_checkdata(spike, 'datatype', 'raw', 'fsample', 500);

cfg = [];
cfg.latency = latency;
data = ft_selectdata(cfg, data);

% fuse spike and LFP events
cfg = [];
cfg.keeptrials = 'yes';
spike = ft_timelockanalysis(cfg, spike);
spike.time = data.time;

% spike = rmfield(spike, 'avg');
% spike = rmfield(spike, 'var');
% spike = rmfield(spike, 'dof');
% spike = rmfield(spike, 'sampleinfo');

% DIRTY FIX!
% spike.trial = spike.trial (:,:,1:350);

all = ft_appenddata([], data, spike);



for CH = 1:length(data.label)
    
    cfg              = [];
    cfg.timwin       = timwin; % take 400 ms
    cfg.spikechannel = spike.label{CH};
    cfg.channel      = data.label(CH);
    cfg.latency      = latency;
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

%% Single trials?
%     for CH = 1:length(data.label)
%
%         for TR = 1:size(spike.trial,1)
%             cfg              = [];
%             trials = zeros(size(spike.trial,1),1,1);
%             trials(TR)= 1;
%             cfg.trials = trials == 1;
%
%             cfg.timwin       = timwin; % take 400 ms
%             cfg.spikechannel = spike.label{CH};
%             cfg.channel      = data.label(CH);
%             cfg.latency      = latency;
%             sta_erp          = ft_spiketriggeredaverage(cfg, all);
%             GAERP(CH,TR,:) = sta_erp.avg;
%
%             % fft this result
%             cfg = [];
%             cfg.taper = 'hanning';
%             cfg.method = 'mtmfft';
%             cfg.foilim = [0 40];
%             sta_freq = ft_freqanalysis(cfg, sta_erp);
%
%             GA(CH,TR,:) = sta_freq.powspctrm;
%         end
%     end


end