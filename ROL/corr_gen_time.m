function corr_els = corr_gen_time(sbj_name, project_name, dirs, electrodes, electrodes_labels, time_window, smooth_factor, cond_col, conds)
% Correlation generalizing across time


cfg.freq_band = 'HFB';
cfg.datatype = 'Band';
cfg.concatfield = {'wave'};
cfg.tag = ['stimlock','_bl_corr'];

block_names = BlockBySubj(sbj_name, project_name);

data_el = [];
for i = 1:length(electrodes)
    el = electrodes(i);
    data = concatBlocks(sbj_name, project_name, block_names,dirs,el,cfg.freq_band,cfg.datatype,cfg.concatfield,cfg.tag);
    time_win = [min(find(data.time >= time_window(1))):min(find(data.time >= time_window(2)))];
    trial_idx = contains(data.trialinfo.(cond_col), conds);

    data.wave = data.wave(trial_idx, time_win);
    data.trialinfo = data.trialinfo(trial_idx,:);
    data.time = data.time(time_win);
    % Smooth 
    data_s = [];
    for ii = 1:size(data.wave)
        data_s(ii,:) = smoothdata(data.wave(ii,:),'gaussian', smooth_factor);
    end
    data_el{i} = data_s;
end
    
figure('units', 'normalized', 'outerposition', [0 0 0.45 0.65])
corr_els = corr(data_el{1}, data_el{2});

% do permutation
% data_el_perm = data_el;
% corr_els_perm = [];
% for i = 1:1000
%     data_el_perm{1} = data_el_perm{1}(randsample(1:size(data_el{1},1), size(data_el{1},1)),:);
%     corr_els_perm{i} =  corr(data_el_perm{1}, data_el_perm{2});
% end
% corr_els_perm = cat(3,corr_els_perm{:});
% corr_els_perm_avg = squeeze(mean(corr_els_perm,3));
% corr_els_diff = corr_els - corr_els_perm_avg;



%% Calculate stats

%% Plot
corr_els(corr_els<0.1) = 0;
corr_lower = tril(corr_els(:));
corr_lower(corr_lower==0) = [];
corr_upper = triu(corr_els(:));
corr_upper(corr_upper==0) = [];


h = imagesc(corr_els);
ticks = find(data.time == 0):150:length(data.time);

set(gca,'ytick',ticks)
set(gca,'xtick',ticks)

set(gca,'YTickLabel',data.time(ticks)*1000)
set(gca,'XTickLabel',data.time(ticks)*1000)


% set(gca,'ytick',data.time(1:smooth_factor:end)*1000)
axis xy
xlabel(['Times (ms) electrode ' electrodes_labels{2}])
ylabel(['Times (ms) electrode ' electrodes_labels{1}])
set(gcf,'color', 'w')
set(gca,'FontSize', 16)
colormap([1 1 1; cbrewer2('Reds')])
ax = gca;
ax.CLim = [0 .5];
colorbar
h = colorbar;
ylabel(h, 'Pearson r')
h.Location = 'southoutside';
axis square
line([data.time(1) size(data_el{2},2)], [0 size(data_el{2},2)], 'Color', 'k', 'LineWidth', 2)
xline(find(data.time == 0), 'Color', 'k', 'LineWidth', 1)
yline(find(data.time == 0), 'Color', 'k', 'LineWidth', 1)

end

