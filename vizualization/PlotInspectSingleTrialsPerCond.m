function PlotInspectSingleTrialsPerCond(data, task, task_version, sbj_name, save_dir)


trials_cat = {'goodtrials', 'badtrials_rt', 'badtrials_badepochs_hfo', 'badtrials_spike'};


for i = 1:size(data.wave,2)
    figure('units', 'normalized', 'outerposition', [0 0 1 1])
    trialinfo = data.trialinfo_all{i};
    
    if strcmp(task_version, 'active')
        trialinfo.goodtrials =  trialinfo.bad_epochs_HFO == 0 & trialinfo.spike_hfb == 0 & (trialinfo.RT > 0.1 | trialinfo.RT < 10); % trialinfo.bad_epochs_raw_HFspike == 0
        trialinfo.badtrials_rt =  trialinfo.RT < 0.1 | trialinfo.RT > 10;
    else
        trialinfo.goodtrials =  trialinfo.bad_epochs_HFO == 0  & trialinfo.spike_hfb == 0; % trialinfo.bad_epochs_raw_HFspike == 0
        trialinfo.badtrials_rt =  zeros(size(trialinfo,1),1,1);
    end
    trialinfo.badtrials_badepochs_hfo = trialinfo.bad_epochs_HFO == 1;
    trialinfo.badtrials_spike = trialinfo.spike_hfb == 1;
    
    % list conditions
    conds = unique(trialinfo.condNames(trialinfo.goodtrials == 1));
    
    counter = 1;
    for ip = 1:length(trials_cat)
        ti = trialinfo(trialinfo.(trials_cat{ip}) == 1,:);
        wave = squeeze(data.wave(trialinfo.(trials_cat{ip}) == 1, i, :));
        cols = hsv(length(trials_cat));
        
        for ic = 1:length(conds)
            subplot(length(trials_cat),length(conds), counter)
            trialinfo_cond = ti(strcmp(ti.condNames, conds{ic}),:);
            wave_cond = squeeze(wave(strcmp(ti.condNames, conds{ic}), :));
            if size(trialinfo_cond, 1) > 1
                for it = 1:size(wave_cond,1)
                    
                    if strcmp(task_version, 'active')
                        if trialinfo_cond.RT(it) >= data.time
                            times = 1:length(data.time);
                        else
                            times = 1:(round(trialinfo_cond.RT(it)*data.fsample) - min(data.time)*data.fsample);
                        end
                        % Plot
                        hold on
                        plot(data.time(times), wave_cond(it,times), 'color', [.6 .6 .6])
                        wave_cond(it,data.time>trialinfo_cond.RT(it)) = nan;
                    else
                        times = 1:length(data.time);
                        hold on
                        plot(data.time(times), wave_cond(it,times), 'color', [.6 .6 .6])
                    end
                    
                end
                % plot average
                plot(data.time, nanmean(wave_cond(trialinfo_cond.goodtrials == 1,:)), 'color', [0 1 0], 'LineWidth', 2)
                xlim([min(data.time) max(data.time)])
                xline(0, 'LineWidth', 2)
                yline(0, 'LineWidth', 2)
                xlabel('Time sec.')
                ylabel('HFB')
                title([conds{ic} '  ' trials_cat{ip}], 'interpreter', 'none')
                %                 ylim([-2 20])
                alpha(0.5)
            else
            end
            counter = counter + 1;
        end
    end
    % Save
    dir_out = sprintf('%s%s/',save_dir,sbj_name);
    if ~exist(dir_out)
        mkdir(dir_out)
    end
    fn_out = sprintf('%s%s_single_trial_per_cond_%s_%s_%s.png',dir_out,sbj_name, num2str(data.chan_num(i)), data.label{i},task);
    savePNG(gcf,300,fn_out)
    close all
    
    if i == 5
        a = 1;
    else
    end
end


end

