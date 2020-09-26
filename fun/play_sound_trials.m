dir_code = '/Users/pinheirochagas/Pedro/Stanford/code/brain_music';
data_fn = [dir_code filesep 'data.mat'];
load(data_fn)

% Select 
electrodes = [105, 15, 61, 81, 70];
trials = data.trialinfo_all{1};     
trials_no = find(strcmp(trials.condNames, 'math') & trials.spike_hfb==false & trials.RT < 5 & trials.RT > 1);
trials_final = trials(trials_no,:);
[~,idx] = sort(trials_final.RT);
trials_final = trials_final(idx,:);

data_plot = squeeze(data.wave(trials_no,3,:));
data_plot = data_plot(idx,:);

% Preapare sound
amp = 10; 
fs = 20500;  % sampling frequency
duration = 0.05;
values = 0:1/fs:duration;

% sound_all = [];
% Transform data to sound
for i = 1:10%size(data_plot,1) % take first 10 trials
    RT_idx = (round(trials_final.RT(i)*data.fsample) + abs(min(data.time)*data.fsample));
    times = 1:RT_idx;
    data_plot_tmp = data_plot(i,:);
    data_plot_tmp(times(end):(abs(data.time(1))+data.time(end))*data.fsample+1) = 0;
    
    data_plot_tmp(data_plot_tmp<=0) = 0;
    peak_vals_trans = round(data_plot_tmp*100);
    peak_vals_trans(peak_vals_trans==0) = 0;
    peak_vals_trans = downsample(peak_vals_trans,10);
    
    b = [];
    for iss = 1:length(peak_vals_trans)
        peak_vals_trans(iss);
        freq = peak_vals_trans(iss);
        a = amp*sin(2*pi* freq*values);
        a_all(iss,:) = a;
        b = [b a]; %zeros(100,1)'
    end
%     audiowrite(sprintf('%s/mmr_audio/mmr_audio_%s.wav',dir_code, num2str(i)),b,10000);
end

figure('units', 'normalized', 'outerposition', [0 0 0.4 0.5])
subplot(3,1,1)
plot(data.time, data_plot(i,:), 'LineWidth',2, 'Color', 'k')
xlim([-0.2 5])
ylabel('zscore HFB')
xlabel('Time (sec.)')
title('HFB of one epoch')
subplot(3,1,2)
plot(peak_vals_trans, 'LineWidth',2, 'Color', 'k')
ylabel('zscore HFB')
xlabel('Time (sec.)')
title('Transformed and downsampled signal of one epoch only until RT')
subplot(3,1,3)
plot(b(1,1:end/3), 'LineWidth',1, 'Color', 'k')
title('Example of sine waves of one given epoch')
fname = [dir_code filesep 'example_signal.png'];
savePNG(gcf,300,fname)



for ie = 1:length(electrodes)
    
    figure('units', 'normalized', 'outerposition', [0 0 0.2 0.6])
    data_plot = squeeze(data.wave(trials_no,ie,:));
    data_plot = data_plot(idx,:);
    
    n_plot = size(data_plot,1);
    cols = viridis(size(data_plot,1));
    for i = 1:size(data_plot,1)
        hold on
        RT_idx = (round(trials_final.RT(i)*data.fsample) + abs(min(data.time)*data.fsample));
        times = 1:RT_idx;
        data_plot_tmp = data_plot(i,:);
        data_plot_tmp(times(end)+data.fsample/5:(abs(data.time(1))+data.time(end))*data.fsample) = nan;
        [~,peaks] = findpeaks(data_plot_tmp+10*i);
        [peak_vals,~] = findpeaks(data_plot_tmp);
        peak_vals_avg(i,ie) = mean(peak_vals(peak_vals>0));
%         plot(data.time(peaks), data_plot_tmp(peaks)+10*i, '.', 'Color', cols(i,:), 'MarkerSize', 6)
        plot(data.time, data_plot_tmp+10*i, 'k', 'LineWidth', 1.5, 'Color', cols(i,:))
        plot(data.time(RT_idx), data_plot_tmp(RT_idx)+10*i, '.', 'MarkerSize', 5, 'Color', 'k')

    end
    xlim([-0.250 5])
    xline(0, 'LineWidth', 2, 'Color', 'k')
    set(gcf,'color', 'w')
    set(gca,'color','w')
    axis on
    box on
    ylabel('Trials sorted by RT')
    xlabel('RT (s)')
    ylim([0 1500])
    set(gca,'fontsize',16)
    set(gca,'ytick',[])
    set(gca,'yticklabel',[])
    fname = sprintf('%s/erp_plot_%s.png',dir_code, num2str(ie));
    savePNG(gcf,300,fname)
    close all
end


