function prop_sig = SignalProperties(data)
% Calculate signal properties

for i = 1:size(data.wave,2)
    trialinfo = data.trialinfo_all{i};
    % check massive spikes
%     max_hfb = max(squeeze(data.wave(:,i,:)),[],2);
%     goodtrials =  trialinfo.bad_epochs == 1 &  trialinfo.RT > 0.1 &  trialinfo.RT < 10 & max_hfb < 100;
    trialinfo.goodtrials = trialinfo.bad_epochs_HFO == 0 & trialinfo.spike_hfb == 0 & (trialinfo.RT > 0.1 | trialinfo.RT < 10) & trialinfo.spike_hfb == 0;
    conds = unique(trialinfo.condNames(trialinfo.goodtrials == 1));
    for ic = 1:length(conds)
        trialinfo_cond = trialinfo(strcmp(trialinfo.condNames, conds{ic}) & trialinfo.goodtrials == 1,:);
        trials_final = strcmp(trialinfo.condNames, conds{ic}) & trialinfo.goodtrials == 1;
        wave_cond = squeeze(data.wave(trials_final, i, :));
        energy_sig = [];
        power_sig = [];
        norm_sig = [];
        fft_sig = [];
        
        for it = 1:size(wave_cond,1)
            if sum(trials_final) >= 10
                if trialinfo_cond.RT(it) >= data.time
                    times = 1:length(data.time);
                else
                    times = 1:(round(trialinfo_cond.RT(it)*data.fsample) - min(data.time)*data.fsample);
                end
                % signal metrics
                wave_final = wave_cond(it,min(find(data.time>0)):max(times));
                energy_sig(it) = sum(abs(wave_final).^2);
                energy_neg_sig(it) = abs(sum(wave_final(wave_final<0)).^2);
                power_sig(it) = energy_sig(it)/size(wave_final,2);
                norm_sig(it) = sqrt(energy_sig(it));
                fft_sig(it,:) = abs(fft(wave_final,4096));
            else
                energy_sig(it) = 0;
                energy_neg_sig(it) = 0;
                power_sig(it) = 0;
                norm_sig(it) = 0;
                fft_sig(it,:) = 0;
            end
        end
        prop_sig.(['conds', num2str(ic)]).cond_name = conds{ic};
        prop_sig.(['conds', num2str(ic)]).energy_sig{i} = energy_sig;
        prop_sig.(['conds', num2str(ic)]).energy_neg_sig{i} = energy_neg_sig;
        prop_sig.(['conds', num2str(ic)]).power_sig{i} = power_sig;
        prop_sig.(['conds', num2str(ic)]).fft_sig{i} = fft_sig;
    end
end

end

