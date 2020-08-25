
%% |PIPELINE FOR THE MATH PAPER| 

%% Define paths to directories
[server_root, comp_root, code_root] = AddPaths('Pedro_iMAC');
dirs = InitializeDirs(' ', ' ', comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'


%% Tasks:
% * *Localizers:* VTC, Scrambled, AllCateg, Logo, 7Heaven
% * *Calculation Simultaneous:* MMR, UCLA, MFA
% * *Calculation Sequential:* Calculia, Memoria

%% Paper folder
result_dir = '/Users/pinheirochagas/Pedro/Stanford/papers/spatiotempoal_dynamics_math/results/';
figure_dir = '/Users/pinheirochagas/Pedro/Stanford/papers/spatiotempoal_dynamics_math/figures/';
dirs = InitializeDirs(' ', ' ', comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'
dirs.result_dir = result_dir;
%% Define final cohorts
% Read the google sheets
[DOCID,GID] = getGoogleSheetInfo('math_network','cohort');
sinfo = GetGoogleSpreadsheet(DOCID, GID);
subject_names = sinfo.sbj_name;

%% Plot coverage
outdir = '/Volumes/LBCN8T/Stanford/data/Results/coverage/';
% Filer for subjVar data
sinfo = sinfo(strcmp(sinfo.subjVar, '1'),:);
% Filer for usable data
sinfo = sinfo(strcmp(sinfo.behavior, '1'),:);
subjects = unique(sinfo.sbj_name);
subjects_unique = unique(subjects);

% Vizualize task per subject
vizualize_task_subject_coverage(sinfo, 'task_group')
savePNG(gcf, 600, [figure_dir, 'tasks_break_group_down_subjects.png'])
 
% Plot full coverage
vars = {'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef'};
subjVar_all_all = ConcatSubjVars(subjects, dirs, vars);
subjVar_all = subjVar_all_all(strcmp(subjVar_all_all.WMvsGM, 'GM') | strcmp(subjVar_all_all.WMvsGM, 'WM'), :);
sort_tabulate(subjVar_all.WMvsGM)
sort_tabulate(subjVar_all.sEEG_ECoG)
sort_tabulate(subjVar_all.DK_lobe_generic)
sort_tabulate(subjVar_all.Yeo7)
sort_tabulate(subjVar_all.Yeo17)

data_ecog = subjVar_all(strcmp(subjVar_all.sEEG_ECoG, 'ECoG'), :);
data_seeg = subjVar_all(strcmp(subjVar_all.sEEG_ECoG, 'sEEG'), :);
sort_tabulate(data_ecog.WMvsGM)
sort_tabulate(data_ecog.LvsR)
sort_tabulate(data_seeg.WMvsGM)
sort_tabulate(data_seeg.LvsR)


cfg = getPlotCoverageCFG('full');
PlotModulation(dirs, subjVar_all, cfg)

% Plot coverage by task group
col_group = 'task_group'; % or task_group
task_group = unique(sinfo.(col_group));
cols = hsv(length(task_group));
for i = 1:length(task_group)
    disp(task_group{i})
    sinfo_tmp = sinfo(strcmp(sinfo.(col_group), task_group{i}),:);
    subjects = unique(sinfo_tmp.sbj_name);
    subjVar_all = ConcatSubjVars(subjects, dirs);
    cfg = getPlotCoverageCFG('tasks_group'); 
    cfg.MarkerColor = cols(i,:);
    PlotModulation(dirs, subjVar_all, cfg)
end





%% Univariate Selectivity
tag = 'stim';
tasks = unique(sinfo.task);
tasks = {'MMR', 'UCLA', 'Memoria', 'Calculia'};
dirs = InitializeDirs(tasks{1}, sinfo.sbj_name{1}, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'
dirs.result_dir = result_dir;
for it = 1:length(tasks)
    task = tasks{it};
    sinfo_tmp = sinfo(strcmp(sinfo.task, task),:);
    parfor i = 1:size(sinfo_tmp,1)
        ElecSelectivityAll(sinfo_tmp.sbj_name{i}, dirs, task, 'stim', 'Band', 'HFB')
    end
end

%% Proportion selectivity Calc simultaneous


vars = {'chan_num', 'FS_label', 'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef', ...
        'elect_select', 'act_deact_cond1', 'act_deact_cond2', 'sc1c2_FDR', 'sc1b1_FDR' , 'sc2b2_FDR', ...
        'sc1c2_Pperm', 'sc1b1_Pperm', 'sc2b2_Pperm', 'sc1c2_tstat', 'sc1b1_tstat', 'sc2b2_tstat'};

task = 'MMR';    
sinfo_MMR = sinfo(strcmp(sinfo.task, task),:);    
el_selectivity_MMR = concat_elect_select(sinfo_MMR.sbj_name, task, dirs, vars);
task = 'UCLA';    
sinfo_UCLA = sinfo(strcmp(sinfo.task, task),:);    
el_selectivity_UCLA = concat_elect_select(sinfo_UCLA.sbj_name, task, dirs, vars);

el_selectivity_calc_sim = [el_selectivity_MMR;el_selectivity_UCLA]
el_selectivity_calc_sim = el_selectivity_calc_sim(strcmp(el_selectivity_calc_sim.WMvsGM, 'GM') | strcmp(el_selectivity_calc_sim.WMvsGM, 'WM'), :);
el_selectivity_calc_sim = el_selectivity_calc_sim(~strcmp(el_selectivity_calc_sim.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:)



selectivities = {{'math only'}, {'math selective'}, {'math deact'}, {'no selectivity'}, {'episodic only', 'autobio only'}, {'episodic selective', 'autobio selective'}, {'autobio deact',  'episodic deact'}, {'math and episodic', 'math and autobio'}};
columns = {'Yeo7', 'DK_lobe'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(2,4,i)
        if strcmp(selectivity, 'math deact') == 1
            el_tmp = el_selectivity_calc_sim(el_selectivity_calc_sim.act_deact_cond1 == -1,:);
        elseif contains(selectivity, {'autobio deact',  'episodic deact'}) == 2
            el_tmp = el_selectivity_calc_sim(el_selectivity_calc_sim.act_deact_cond2 == -1,:);
        else
            el_tmp = el_selectivity_calc_sim(contains(el_selectivity_calc_sim.elect_select, selectivity),:);
        end
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['selectivity ', column, '.png']])
end


selectivities = {{'math only'},{'episodic only', 'autobio only'}};
columns = {'DK_long_josef'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(1,2,i)
        if strcmp(selectivity, 'math deact') == 1
            el_tmp = el_selectivity_calc_sim(el_selectivity_calc_sim.act_deact_cond1 == -1,:);
        elseif contains(selectivity, {'autobio deact',  'episodic deact'}) == 2
            el_tmp = el_selectivity_calc_sim(el_selectivity_calc_sim.act_deact_cond2 == -1,:);
        else
            el_tmp = el_selectivity_calc_sim(contains(el_selectivity_calc_sim.elect_select, selectivity),:);
        end
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['selectivity ', column, '.png']])
end

%% Plot coverage selectivity

% Plot coverage by task group
el_selectivity_only = el_selectivity_calc_sim(contains(el_selectivity_calc_sim.elect_select, 'only'),:);


cfg = getPlotCoverageCFG('tasks_group'); 
cfg.MarkerSize = 10;
cfg.alpha = 0.5;
cfg.views = {'lateral', 'lateral', 'ventral', 'ventral'};
cfg.hemis = {'left', 'right', 'right', 'left'};
cfg.subplots = [2,2];
cfg.figureDim = [0 0 1 1];
            
load('cdcol_2018.mat')
for i = 1:size(el_selectivity_only,1)
    if contains(el_selectivity_only.elect_select{i}, 'math') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_only, cfg)
savePNG(gcf, 600, [figure_dir, 'MMR_selectivity_brain_only.png'])



el_selectivity_selective = el_selectivity_calc_sim(contains(el_selectivity_calc_sim.elect_select, 'selective'),:);
load('cdcol_2018.mat')
for i = 1:size(el_selectivity_selective,1)
    if contains(el_selectivity_selective.elect_select{i}, 'math selective') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_selective, cfg)
savePNG(gcf, 300, [figure_dir, 'MMR_selectivity_brain_selective.png'])



el_selectivity_math_deact = el_selectivity_calc_sim(el_selectivity_calc_sim.act_deact_cond1 == -1,:);
el_selectivity_math_deact(~strcmp(el_selectivity_math_deact.Yeo7, 'Somatomotor'),:)
load('cdcol_2018.mat')
for i = 1:size(el_selectivity_math_deact,1)
    if contains(el_selectivity_math_deact.elect_select{i}, 'math selective') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_math_deact, cfg)
savePNG(gcf, 300, [figure_dir, 'MMR_el_selectivity_math_deact.png'])





%% MEMORIA

task = 'Memoria';    
sinfo_Memoria = sinfo(strcmp(sinfo.task, task),:);    
el_selectivity_Memoria = concat_elect_select(sinfo_Memoria.sbj_name, task, dirs, vars);
el_selectivity_Memoria = el_selectivity_Memoria(strcmp(el_selectivity_Memoria.WMvsGM, 'GM') | strcmp(el_selectivity_Memoria.WMvsGM, 'WM'), :);
el_selectivity_Memoria = el_selectivity_Memoria(~strcmp(el_selectivity_Memoria.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:)

selectivities = {{'math only'}, {'math selective'}, {'math deact'}, {'no selectivity'}, {'autobio only'}, {'autobio selective'}, {'autobio deact'}, {'math and autobio'}};
columns = {'Yeo7', 'DK_lobe'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(2,4,i)
        if strcmp(selectivity, 'math deact') == 1
            el_tmp = el_selectivity_Memoria(el_selectivity_Memoria.act_deact_cond1 == -1,:);
        elseif contains(selectivity, {'autobio deact',  'episodic deact'}) == 2
            el_tmp = el_selectivity_Memoria(el_selectivity_Memoria.act_deact_cond2 == -1,:);
        else
            el_tmp = el_selectivity_Memoria(contains(el_selectivity_Memoria.elect_select, selectivity),:);
        end
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['Memoria_selectivity ', column, '.png']])
end


selectivities = {{'math only'},{'episodic only', 'autobio only'}};
columns = {'DK_long_josef'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(1,2,i)
        if strcmp(selectivity, 'math deact') == 1
            el_tmp = el_selectivity_Memoria(el_selectivity_Memoria.act_deact_cond1 == -1,:);
        elseif contains(selectivity, {'autobio deact',  'episodic deact'}) == 2
            el_tmp = el_selectivity_Memoria(el_selectivity_Memoria.act_deact_cond2 == -1,:);
        else
            el_tmp = el_selectivity_Memoria(contains(el_selectivity_Memoria.elect_select, selectivity),:);
        end
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['Memoria_selectivity ', column, '.png']])
end



el_selectivity_only = el_selectivity_Memoria(contains(el_selectivity_Memoria.elect_select, 'only'),:);


cfg = getPlotCoverageCFG('tasks_group'); 
cfg.MarkerSize = 10;
cfg.alpha = 0.5;
cfg.views = {'lateral', 'lateral', 'ventral', 'ventral'};
cfg.hemis = {'left', 'right', 'right', 'left'};
cfg.subplots = [2,2];
cfg.figureDim = [0 0 1 1];
            
load('cdcol_2018.mat')
for i = 1:size(el_selectivity_only,1)
    if contains(el_selectivity_only.elect_select{i}, 'math') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_only, cfg)
savePNG(gcf, 600, [figure_dir, 'Memoria_selectivity_brain_only.png'])


el_selectivity_selective = el_selectivity_Memoria(contains(el_selectivity_Memoria.elect_select, 'selective'),:);


load('cdcol_2018.mat')
for i = 1:size(el_selectivity_selective,1)
    if contains(el_selectivity_selective.elect_select{i}, 'math selective') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_selective, cfg)
savePNG(gcf, 300, [figure_dir, 'Memoria_selectivity_brain_selective.png'])



%% ALL MATH
el_selectivity_all_calc = [el_selectivity_Memoria; el_selectivity_calc_sim];


selectivities = {{'math only'}, {'math selective'}, {'math deact'}, {'no selectivity'}, {'episodic only', 'autobio only'}, {'episodic selective', 'autobio selective'}, {'autobio deact',  'episodic deact'}, {'math and episodic', 'math and autobio'}};
columns = {'Yeo7', 'DK_lobe'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(2,4,i)
        if strcmp(selectivity, 'math deact') == 1
            el_tmp = el_selectivity_all_calc(el_selectivity_all_calc.act_deact_cond1 == -1,:);
        elseif contains(selectivity, {'autobio deact',  'episodic deact'}) == 2
            el_tmp = el_selectivity_all_calc(el_selectivity_all_calc.act_deact_cond2 == -1,:);
        else
            el_tmp = el_selectivity_all_calc(contains(el_selectivity_all_calc.elect_select, selectivity),:);
        end
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['Calc_all_selectivity ', column, '.png']])
end
close all


selectivities = {{'math only'},{'episodic only', 'autobio only'}};
columns = {'DK_long_josef'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(1,2,i)
        if strcmp(selectivity, 'math deact') == 1
            el_tmp = el_selectivity_all_calc(el_selectivity_all_calc.act_deact_cond1 == -1,:);
        elseif contains(selectivity, {'autobio deact',  'episodic deact'}) == 2
            el_tmp = el_selectivity_all_calc(el_selectivity_all_calc.act_deact_cond2 == -1,:);
        else
            el_tmp = el_selectivity_all_calc(contains(el_selectivity_all_calc.elect_select, selectivity),:);
        end
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['Calc_all_selectivity ', column, '.png']])
end
close all




el_selectivity_only = el_selectivity_all_calc(contains(el_selectivity_all_calc.elect_select, 'only'),:);
sort_tabulate(el_selectivity_only.elect_select, 'descend')

cfg = getPlotCoverageCFG('tasks_group'); 
cfg.MarkerSize = 10;
cfg.alpha = 0.8;
cfg.views = {'lateral', 'lateral', 'ventral', 'medial', 'medial', 'ventral',};
cfg.hemis = {'left', 'right', 'left', 'left', 'right', 'right', };
cfg.subplots = [2,3];
cfg.figureDim = [0 0 1 1];
            
load('cdcol_2018.mat')
for i = 1:size(el_selectivity_only,1)
    if contains(el_selectivity_only.elect_select{i}, 'math') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_only, cfg)
savePNG(gcf, 600, [figure_dir, 'All_calc_selectivity_brain_only.png'])


el_selectivity_selective = el_selectivity_all_calc(contains(el_selectivity_all_calc.elect_select, 'selective'),:);


load('cdcol_2018.mat')
for i = 1:size(el_selectivity_selective,1)
    if contains(el_selectivity_selective.elect_select{i}, 'math selective') == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    else
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    end
end
PlotModulation(dirs, el_selectivity_selective, cfg)
savePNG(gcf, 300, [figure_dir, 'All_calc_selectivity_brain_selective.png'])


%% Calculia

task = 'Calculia';    
sinfo_Calculia = sinfo(strcmp(sinfo.task, task),:);    
sinfo_Calculia(contains(sinfo_Calculia.sbj_name, {'S14_74_OD', 'S15_87_RL', 'S16_95_JOB', 'S15_83_RR', 'S16_96_LF'}),:) = [];
el_selectivity_Calculia = concat_elect_select(sinfo_Calculia.sbj_name, task, dirs, vars);
el_selectivity_Calculia = el_selectivity_Calculia(strcmp(el_selectivity_Calculia.WMvsGM, 'GM') | strcmp(el_selectivity_Calculia.WMvsGM, 'WM'), :);
el_selectivity_Calculia = el_selectivity_Calculia(~strcmp(el_selectivity_Calculia.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:)

selectivities = {{'math only'}, {'math selective'}, {'math deact'}, {'no selectivity'}, {'autobio only'}, {'autobio selective'}, {'autobio deact'}, {'math and autobio'}};
columns = {'Yeo7', 'DK_lobe'};
figure('units', 'normalized', 'outerposition', [0 0 1 1])
for ic = 1:length(columns)
    for i = 1:length(selectivities)
        selectivity = selectivities{i};
        column = columns{ic};
        subplot(2,4,i)
        el_tmp = el_selectivity_Memoria(contains(el_selectivity_Memoria.elect_select, selectivity),:);
        plot_frequency(el_tmp, column, 'ascend', 'horizontal')
        title(selectivity)
    end
    savePNG(gcf, 300, [figure_dir, ['Memoria_selectivity ', column, '.png']])
end


el_selectivity_only = el_selectivity_Calculia(~contains(el_selectivity_Calculia.elect_select, {'no selectivity', 'digit_active and letter_active'}),:);

el_selectivity_only = el_selectivity_Calculia(contains(el_selectivity_Calculia.elect_select, {'only'}),:);
sort_tabulate(el_selectivity_only.elect_select, 'descend')

cfg = getPlotCoverageCFG('tasks_group'); 
cfg.MarkerSize = 10;
cfg.alpha = 0.5;
cfg.views = {'lateral', 'lateral', 'ventral', 'medial', 'medial', 'ventral',};
cfg.hemis = {'left', 'right', 'left', 'left', 'right', 'right', };
cfg.subplots = [2,3];
cfg.figureDim = [0 0 1 1];
            
load('cdcol_2018.mat')
for i = 1:size(el_selectivity_only,1)
    if contains(el_selectivity_only.elect_select{i}, {'digit_active selective', 'digit_active only'}) == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    elseif contains(el_selectivity_only.elect_select{i}, {'letter_active selective', 'letter_active only'}) == 1
        cfg.MarkerColor(i,:) = cdcol.sapphire_blue;
    else
        cfg.MarkerColor(i,:) = [0 0 0];
    end
end
PlotModulation(dirs, el_selectivity_only, cfg)
savePNG(gcf, 300, [figure_dir, 'Calculia_only_brain_selective.png'])


%% Viz proportions
el_selectivity = simplify_selectivity(el_selectivity_all_calc, 'MMR');
sort_tabulate(el_selectivity.elect_select, 'descend')

el_selectivity_only = el_selectivity(contains(el_selectivity.elect_select, 'only'), :)
el_selectivity_only = el_selectivity_only(~contains(el_selectivity_only.Yeo7, 'Depth'),:)


conditions = {'math', 'memory'};
Yeo7_networks = {'Frontoparietal', 'Dorsal Attention', 'Default', 'Limbic',  'Ventral Attention','Visual', 'Somatomotor'};

frequencies = [];
for i = 1:length(conditions)
    tmp_Yeo7 = el_selectivity_only(contains(el_selectivity_only.elect_select, conditions{i}),:);
    tmp_Yeo7 = sort_tabulate(tmp_Yeo7.Yeo7, 'descend');
    for in = 1:length(Yeo7_networks)
        frequencies(i,in) = tmp_Yeo7{strcmp(tmp_Yeo7.value, Yeo7_networks{in}), 2};
    end
end
frequencies = frequencies'

% frequencies = flip(frequencies');
[frequencies, idx] = sortrows(frequencies, 1, 'descend')
frequencies = flip(frequencies);
Yeo7_networks = Yeo7_networks(idx)
Yeo7_networks = flip(Yeo7_networks)

ba = barh(frequencies, 'stacked' ,'EdgeColor', 'k','LineWidth',2)
ba(1).FaceColor = cdcol.light_cadmium_red;
ba(2).FaceColor = cdcol.sapphire_blue

set(gca,'fontsize',16)
xlabel('Number of electrodes')
yticks(1:length(Yeo7_networks))
ylim([0, length(Yeo7_networks)+1])
yticklabels(Yeo7_networks)
set(gca,'TickLabelInterpreter','none')

for i = 1:length(conditions)
    for in = 1:length(Yeo7_networks)
        if i == 1
            txt = text(frequencies(in,i)-1,in, num2str(frequencies(in,i)), 'FontSize', 20, 'HorizontalAlignment', 'right', 'Color', 'w');
        elseif i > 1
            txt = text(frequencies(in,i)+sum(frequencies(in,1:i-1))-1,in, num2str(frequencies(in,i)), 'FontSize', 20, 'HorizontalAlignment', 'right', 'Color', 'w');
        end
    end
end
title('Frequency of math vs. memory only sites per intrinsic network')
savePNG(gcf, 300, [figure_dir, 'math_all_frequencies_Yeo7_stacked.png'])






conditions = {'math', 'memory'};
hemis = {'L', 'R'};

frequencies = [];
for i = 1:length(conditions)
    LvsR = el_selectivity_only(contains(el_selectivity_only.elect_select, conditions{i}),:);
    LvsR = sort_tabulate(LvsR.LvsR, 'descend');
    for in = 1:length(hemis)
        frequencies(i,in) = LvsR{strcmp(LvsR.value, hemis{in}), 2};
    end
end
frequencies = frequencies'

% frequencies = flip(frequencies');
[frequencies, idx] = sortrows(frequencies, 1, 'descend')
frequencies = frequencies;
hemis = hemis(idx)
hemis = flip(hemis)

ba = bar(frequencies, 'stacked' ,'EdgeColor', 'k','LineWidth',2)
ba(1).FaceColor = cdcol.light_cadmium_red;
ba(2).FaceColor = cdcol.sapphire_blue

set(gca,'fontsize',16)
ylabel('Number of electrodes')
xlim([0, length(hemis)+1])
xlabel('Hemispheres')
xticklabels({'Left', 'Right'})
set(gca,'TickLabelInterpreter','none')

for i = 1:length(conditions)
    for in = 1:length(Yeo7_networks)
        if i == 1
            txt = text(in, frequencies(in,i)-1, num2str(frequencies(in,i)), 'FontSize', 20, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'Color', 'w');
        elseif i > 1
            txt = text(in, frequencies(in,i)+sum(frequencies(in,1:i-1))-1, num2str(frequencies(in,i)), 'FontSize', 20, 'HorizontalAlignment', 'center',  'VerticalAlignment', 'top', 'Color', 'w');
        end
    end
end
title('Frequency of math vs. memory only sites per hemi network')
savePNG(gcf, 300, [figure_dir, 'math_all_frequencies_hemi_stacked.png'])


%%
[DOCID,GID] = getGoogleSheetInfo('math_network','cohort');
sinfo = GetGoogleSpreadsheet(DOCID, GID);
subject_names = sinfo.sbj_name;
sinfo = sinfo(strcmp(sinfo.subjVar, '1'),:);
% Filer for usable dat
subjects = unique(sinfo.sbj_name);


for i = 1:length(subjects)
    try
        CreateSubjVar(subjects{i}, comp_root, server_root, code_root)
    catch
        fname = sprintf('%s/%s_subjVar_error.csv',dirs.comp_root, subjects{i});
        csvwrite(fname, 's')
    end
end


parfor i = 1:length(subjects)
    CreateSubjVar(subjects{i}, comp_root, server_root, code_root)
end



CreateSubjVar('S16_100_AF', comp_root, server_root, code_root)



%% VTCLoc
%% Univariate Selectivity
vars = {'chan_num', 'FS_label', 'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef', ...
        'elect_select', 'act_deact_cond1', 'act_deact_cond2', 'sc1c2_FDR', 'sc1b1_FDR' , 'sc2b2_FDR', ...
        'sc1c2_Pperm', 'sc1b1_Pperm', 'sc2b2_Pperm', 'sc1c2_tstat', 'sc1b1_tstat', 'sc2b2_tstat'};
    
    
task = 'VTCLoc';    
sinfo_VTCLoc = sinfo(strcmp(sinfo.task, task),:);   
sinfo_VTCLoc(strcmp(sinfo_VTCLoc.sbj_name,'S17_118_TW'),:) = [];
sinfo_VTCLoc(strcmp(sinfo_VTCLoc.sbj_name,'S15_91_RP'),:) = [];




el_selectivity_VTCloc_faces = concat_elect_select(sinfo_VTCLoc.sbj_name, task, dirs, vars);
el_selectivity_VTCloc_numbers = concat_elect_select(sinfo_VTCLoc.sbj_name, task, dirs, vars);
el_selectivity_VTCloc_words = concat_elect_select(sinfo_VTCLoc.sbj_name, task, dirs, vars);

el_selectivity_VTC = el_selectivity_VTCloc_faces
el_selectivity_VTC.elect_select_faces = el_selectivity_VTC.elect_select
el_selectivity_VTC.elect_select_words = el_selectivity_VTCloc_words.elect_select
el_selectivity_VTC.elect_select_numbers = el_selectivity_VTCloc_numbers.elect_select


VTC_selective = el_selectivity_VTC(contains(el_selectivity_VTC.elect_select_faces, {'faces only', 'faces selective'}) | contains(el_selectivity_VTC.elect_select_numbers, {'numbers only', 'numbers selective'}) | contains(el_selectivity_VTC.elect_select_words, {'words only', 'words selective'}),:);
sort_tabulate(VTC_selective.elect_select, 'descend')

cfg = getPlotCoverageCFG('tasks_group'); 
cfg.MarkerSize = 10;
cfg.alpha = 0.4;
cfg.views = {'lateral', 'lateral', 'ventral', 'medial', 'medial', 'ventral',};
cfg.hemis = {'left', 'right', 'left', 'left', 'right', 'right', };
cfg.subplots = [2,3];
cfg.figureDim = [0 0 1 1];
cfg.CorrectFactor = 10;
        
load('cdcol_2018.mat')
for i = 1:size(VTC_selective,1)
    if contains(VTC_selective.elect_select_faces{i}, {'faces only', 'faces selective'}) == 1
        cfg.MarkerColor(i,:) = cdcol.grass_green;
    elseif contains(VTC_selective.elect_select_words{i}, {'words only', 'words selective'}) == 1
        cfg.MarkerColor(i,:) = cdcol.orange;
    elseif contains(VTC_selective.elect_select_numbers{i}, {'numbers only', 'numbers selective'}) == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    end
    
end
PlotModulation(dirs, VTC_selective, cfg)
savePNG(gcf, 300, [figure_dir, 'Calculia_only_brain_selective.png'])




%% ReadNumWord
%% Univariate Selectivity


vars = {'chan_num', 'FS_label', 'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef', ...
        'elect_select', 'act_deact_cond1', 'act_deact_cond2', 'sc1c2_FDR', 'sc1b1_FDR' , 'sc2b2_FDR', ...
        'sc1c2_Pperm', 'sc1b1_Pperm', 'sc2b2_Pperm', 'sc1c2_tstat', 'sc1b1_tstat', 'sc2b2_tstat'};
    
    
task = 'ReadNumWord';    
sinfo_ReadNumWord_numbers = sinfo(strcmp(sinfo.task, task),:);   
sinfo_ReadNumWord_numbers(strcmp(sinfo_ReadNumWord_numbers.sbj_name,'S12_36_SrS'),:) = [];





el_selectivity_ReadNumWord_numbers = concat_elect_select(sinfo_VTCLoc.sbj_name, task, dirs, vars);


ReadNumWord_selective = el_selectivity_ReadNumWord_numbers(contains(el_selectivity_ReadNumWord_numbers.elect_select, {'numbers selective', 'numbers only'}),:);
sort_tabulate(ReadNumWord_selective.elect_select, 'descend')

cfg = getPlotCoverageCFG('tasks_group'); 
cfg.MarkerSize = 10;
cfg.alpha = 0.4;
cfg.views = {'lateral', 'lateral', 'ventral', 'medial', 'medial', 'ventral',};
cfg.hemis = {'left', 'right', 'left', 'left', 'right', 'right', };
cfg.subplots = [2,3];
cfg.figureDim = [0 0 1 1];
cfg.CorrectFactor = 10;
        
load('cdcol_2018.mat')
for i = 1:size(VTC_selective,1)
    if contains(VTC_selective.elect_select_faces{i}, {'faces only', 'faces selective'}) == 1
        cfg.MarkerColor(i,:) = cdcol.grass_green;
    elseif contains(VTC_selective.elect_select_words{i}, {'words only', 'words selective'}) == 1
        cfg.MarkerColor(i,:) = cdcol.orange;
    elseif contains(VTC_selective.elect_select_numbers{i}, {'numbers only', 'numbers selective'}) == 1
        cfg.MarkerColor(i,:) = cdcol.light_cadmium_red;
    end
    
end
PlotModulation(dirs, VTC_selective, cfg)
savePNG(gcf, 300, [figure_dir, 'Calculia_only_brain_selective.png'])



%%
vars = {'sbj_name', 'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17'};
subjVars = ConcatSubjVars(subjects, dirs, vars);

sort_tabulate(subjVars.Yeo7, 'descend')





for i = 1:size(subjVars,1)
    str_tmp = strsplit(subjVars.sbj_name{i}, '_');
    
    subjVars.sbj_number(i) = str2num(str_tmp{2});
end

for i = 1:size(subjVars_old,1)    
    subjVars_old.sbj_number(i) = str2num(subjVars_old.sbj_name{i});
end


subjVars = subjVars(ismember(subjVars.sbj_number, subjVars_old.sbj_number),:);




subjVars(contains(subjVars.WMvsGM, {'empty', 'FreeSurfer_Defined_Medial_Wall', 'EMPTY'} ),:) = []
subjVars_old(contains(subjVars_old.WMvsGM, {'empty', 'FreeSurfer_Defined_Medial_Wall', 'EMPTY'} ),:) = []



sort_tabulate(subjVars.WMvsGM, 'descend')
sort_tabulate(subjVars_old.WMvsGM, 'descend')


%% Group analyses

vars = {'chan_num', 'FS_label', 'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef', ...
        'elect_select', 'act_deact_cond1', 'act_deact_cond2', 'sc1c2_FDR', 'sc1b1_FDR' , 'sc2b2_FDR', ...
        'sc1c2_Pperm', 'sc1b1_Pperm', 'sc2b2_Pperm', 'sc1c2_tstat', 'sc1b1_tstat', 'sc2b2_tstat'};
    
    
regions = {'ITG','IPS', 'SPL', 'MFG'};
task = 'MMR';
sinfo_task = sinfo(strcmp(sinfo.task, task),:);    
el_selectivity = concat_elect_select(sinfo_task.sbj_name, task, dirs, vars);
el_selectivity = el_selectivity(strcmp(el_selectivity.WMvsGM, 'GM') | strcmp(el_selectivity.WMvsGM, 'WM'), :);
el_selectivity = el_selectivity(~strcmp(el_selectivity.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);
el_selectivity = el_selectivity(contains(el_selectivity.elect_select, 'math only'),:);


for i = 1:length(regions)
    el_selec_tmp = el_selectivity(strcmp(el_selectivity.DK_long_josef, regions{i}),[1,end-1]);
    if isempty(el_selec_tmp)
    else
        data_all = concatenate_multiple_elect(el_selec_tmp, task, dirs, 'Band', 'HFB', 'stim');
        cond_names = {'autobio', 'math'};
        column = 'condNames';
        subplot(length(regions),1, i)
        plot_group_elect(data_all,task, cond_names, column);
        if strcmp(regions{i} , 'ITG')
            ylim([-0.4 2])
        else
            ylim([-0.2 1])
        end
        title([regions{i} ': ' num2str(length(data_all.wave)), ' electrodes'])
    end
end
savePNG(gcf, 600, [figure_dir, task, '_group_regions_selective.png'])


data_all = concatenate_multiple_elect(el_selectivity, task, dirs, 'Band', 'HFB', 'stim');


el_selec_tmp = el_selectivity(strcmp(el_selectivity.DK_long_josef, regions{2}),[1,end-1]);
data_all = concatenate_multiple_elect(el_selec_tmp, task, dirs, 'Band', 'HFB', 'stim');
cond_names = {'autobio', 'math'};
column = 'condNames';
stats_params = genStatsParams(task);
STATS = stats_group_elect(data_all,data_all.time, task,cond_names, column, stats_params);


        title([regions{2} ': ' num2str(length(data_all.wave)), ' electrodes'])


% Group analyses

1. Select which electrodes to include
-Statistical
    Compare all trails agains baseline
    permutation test between avg baseline period whithin trial vs. avg 1s period within trial
-Anatomical
    ROIS
After these steps you should have the electrode_list

2. Concatenate all electrodes of interest
data_all = concatenate_multiple_elect(electrode_list, task, dirs, 'Band', 'HFB', 'stim');

3. Compare two conditions across electrodes
-Define conditions and time window
    cond_names = {'autobio', 'math'};
    column = 'condNames';
    stats_params = genStatsParams(task);
-Average each electrode per condition within the 1s period
    (now you have a single value per electrode per condition)
    Ready to compare electrodes with independent sample t-test
STATS = stats_group_elect(data_all,data_all.time, task,cond_names, column, stats_params);




%% Vizualize proportions


vars = {'chan_num', 'FS_label', 'LvsR','MNI_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef', 'elect_select'};
elec_select = concat_selectivity_tasks(sinfo, 'calc_simultaneous', vars, dirs);



cond_names = {'math only', 'memory only'};
brain_group_list = {'Frontoparietal', 'Dorsal Attention', 'Default', 'Limbic',  'Ventral Attention','Visual', 'Somatomotor'};
brain_group_list = {'Depth', 'Frontoparietal', 'Dorsal Attention', 'Default', 'Limbic',  'Ventral Attention','Visual', 'Somatomotor'};

brain_group = 'Yeo7';


plot_proportion_selectivity(elec_select, 'MMR', cond_names, brain_group, brain_group_list)

brain_group_list = {'L','R'};
brain_group = 'LvsR';
plot_proportion_selectivity(el_selectivity_calc_sim, 'MMR', cond_names, brain_group, brain_group_list)



%% MMR and memoria comparison electrode by electrode
sinfo_MMR = sinfo(strcmp(sinfo.task, 'MMR'),:);
sinfo_Memoria = sinfo(strcmp(sinfo.task, 'Memoria'),:);
subjects_MMR_Memoria = intersect(sinfo_MMR.sbj_name, sinfo_Memoria.sbj_name);

el_selectivity_MMR = concat_elect_select(subjects_MMR_Memoria, 'MMR', dirs, vars);
el_selectivity_Memoria = concat_elect_select(subjects_MMR_Memoria, 'Memoria', dirs, vars);
elect_select_MMR = el_selectivity_MMR.elect_select;
elect_select_Memoria = el_selectivity_Memoria.elect_select;

elec_select = el_selectivity_MMR(:,[1:12,end-1])
elec_select.elect_select_MMR = elect_select_MMR;
elec_select.elect_select_Memoria = elect_select_Memoria;
elec_select = elec_select(strcmp(elec_select.WMvsGM, 'GM') | strcmp(elec_select.WMvsGM, 'WM'), :);
elec_select = elec_select(~strcmp(elec_select.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);

sort_tabulate(elec_select.elect_select_Memoria(strcmp(elec_select.elect_select_MMR, 'math only')), 'descend')
sort_tabulate(elec_select.elect_select_MMR(strcmp(elec_select.elect_select_Memoria, 'math only')), 'descend')



corrcoef([el_selectivity_MMR.sc1c2_tstat, el_selectivity_Memoria.sc1c2_tstat], 'rows','complete')


scatter(plotvals(:,1),plotvals(:,2),40,c,'filled'),colorbar;



scatter_kde(el_selectivity_MMR.sc1c2_tstat, el_selectivity_Memoria.sc1c2_tstat,  'filled', 'MarkerSize', 50)
colormap viridis

sum_t = nansum([el_selectivity_MMR.sc1c2_tstat, el_selectivity_Memoria.sc1c2_tstat], 2);
rgb = vals2colormap(sum_t*-1, 'cmRedBlue', [-10 10]);

scatter(el_selectivity_MMR.sc1c2_tstat, el_selectivity_Memoria.sc1c2_tstat, 100, rgb, 'filled')
xlabel('T-value Calc simultaneous')
ylabel('T-value Calc sequential')
set(gca,'fontsize',16)
box on
axis square

savePNG(gcf, 600, [figure_dir, task, 'MMR_Memoria_correspondence.png'])








%% ROL
%% ROL from Jessica and Omri NC

project_name = 'MMR';

parfor i = 1:size(sinfo_MMR,1)
    getROLALL_NC(sinfo_MMR.sbj_name{i},project_name,[],dirs,[],'HFB',[],'condNames',{'autobio', 'math'}) ;% condNames
end

plot_ROL_scatter


ROL_var = {'onsets', 'peaks'};
elecs = [105, 16, 61];
col = cbrewer2('Blues',6)
col = col(3:end,:)
col = cool(3)
cond_names = {'math'};
plot_ROL_scatter(ROL, ROL_var, elecs, cond_names, 'each column separately', 2,col)
plot_ROL_scatter(ROL, ROL_var, elecs, cond_names, 'by one column', 3,col)



    getROLALL_NC('S20_151_HT',project_name,[],dirs,[1:156],'HFB',[],'condNames',{'autobio', 'math'}) ;% condNames

getROLALL_NC('S13_57_TVD',project_name,[],dirs,[105,16,61],'HFB',[],'condNames',{'math'}) ;% condNames


%% Integrate selectivity and ROL
vars = {'chan_num', 'FS_label', 'LvsR','MNI_coord', 'fsaverageINF_coord', 'WMvsGM', 'sEEG_ECoG', 'DK_lobe', 'Yeo7', 'Yeo17', 'DK_long_josef', ...
        'elect_select', 'act_deact_cond1', 'act_deact_cond2', 'sc1c2_FDR', 'sc1b1_FDR' , 'sc2b2_FDR', ...
        'sc1c2_Pperm', 'sc1b1_Pperm', 'sc2b2_Pperm', 'sc1c2_tstat', 'sc1b1_tstat', 'sc2b2_tstat'};

task = 'MMR';    
sinfo_MMR = sinfo(strcmp(sinfo.task, task),:);    
el_selectivity_MMR = concat_elect_select(sinfo_MMR.sbj_name, task, dirs, vars);


el_selectivity_MMR_ROL = concat_elect_select_rol(sinfo_MMR.sbj_name, task, dirs, vars);


el_selectivity = el_selectivity_MMR_ROL(strcmp(el_selectivity_MMR_ROL.elect_select, 'math only'), :)
el_selectivity = el_selectivity(~strcmp(el_selectivity.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);
el_selectivity = el_selectivity(~contains(el_selectivity.DK_long_josef, {'OUT OF BRAIN', 'WHITE MATTER', 'EXCLUDE', 'POSTCENTRAL GYRUS', 'PRECENTRAL GYRUS'}),:);

el_selectivity.ROL_math_avg = cellfun(@nanmean, el_selectivity.ROL_math_onsets)
el_selectivity = el_selectivity(~isnan(el_selectivity.ROL_math_avg),:);


dir_save = '/Volumes/LBCN8T/Stanford/data/electrode_localization/plots/';

col_group = 'task_group'; % or task_group
cols = hsv(length(labels_josef));
cfg = getPlotCoverageCFG('tasks_group');
cfg.figureDim = [0 0 1 0.7];
cfg.views = {'lateral', 'lateral', 'ventral', 'ventral', 'medial', 'medial', 'posterior', 'posterior'}; %{'lateral', 'lateral', 'ventral', 'ventral'};
cfg.hemis = {'left', 'right', 'left', 'right', 'left', 'right', 'left', 'right'}; %{'left', 'right', 'left', 'right'};
cfg.subplots = [2,4];  % 2,2
cfg.plot_label = 0;
cfg.colum_label = {'sbj_name', 'FS_label'};
cfg.alpha = 0.1;
cfg.MarkerSize = 10;
cfg.MarkerColor = cols(i,:);

PlotModulation(dirs, el_selectivity, cfg)
fname = sprintf('%selectrodes_%s.png', dir_save, labels_josef{i});
savePNG(gcf, 300, fname)
close all


el_selectivity.LvsR = repmat({'L'}, size(el_selectivity,1),1,1)
el_selectivity.MNI_coord(:,1) = abs(el_selectivity.MNI_coord(:,1))*-1

cfg.ind = cellfun(@nanmean, el_selectivity.ROL_math_onsets)
cfg.MarkerColor = [];
cfg.views = {'lateral', 'ventral'};
cfg.hemis = {'left', 'left'};
cfg.subplots = [1,2];  % 2,2
cfg.MarkerSize = 20;
cfg.Colormap = 'Reds'
cfg.Cortex = 'MNI';
PlotModulation(dirs, el_selectivity, cfg)



sort_tabulate(el_selectivity.DK_long_josef, 'descend')
labels_plot = {'MFG', 'IPS', 'ITG', 'SPL', 'FG', 'IFG'}
el_selectivity = el_selectivity(contains(el_selectivity.DK_long_josef, labels_plot) & ~strcmp(el_selectivity.DK_long_josef, {'mSFG'}),:);
mean_labels = varfun(@median,el_selectivity,'InputVariables','ROL_math_avg', 'GroupingVariables','DK_long_josef');
[mean_labels, idx] = sortrows(mean_labels, 3);
% rol per region
el_selectivity.DK_long_josef_sort = el_selectivity.DK_long_josef;

for i = 1:length(mean_labels)
    labels_tmp = el_selectivity.DK_long_josef_sort(strcmp(el_selectivity.DK_long_josef_sort, mean_labels.DK_long_josef{i})) = 
    
end

ROL_vars = {'ROL_math_onsets', 'ROL_math_peaks'};
ROL_vars = {'sc1c2_tstat', 'sc1b1_tstat'};



for i = 1:length(ROL_vars)
    subplot(1,2,i)
    %     el_selectivity.ROL_tmp = cellfun(@nanmean, el_selectivity.(ROL_vars{i}))
    %     ROL_tmp = varfun(@median,el_selectivity,'InputVariables','ROL_tmp', 'GroupingVariables','DK_long_josef');
    ROL_tmp = varfun(@median,el_selectivity,'InputVariables',ROL_vars{i}, 'GroupingVariables','DK_long_josef');
    
    [~, idx] = sortrows(ROL_tmp, 3);
    vi = violinplot(el_selectivity.(ROL_vars{i}), el_selectivity.DK_long_josef, idx); % accuracy Min Max Result Abs deviant decade cross order;
    for iiii = 1:length(vi)
        cols_vi = cbrewer2('Greens', length(vi)+2);
        cols_vi(1:2,:) = [];
%         cols_vi = flip(cols_vi);
        vi(iiii).ViolinPlot.FaceColor = 'none';
        vi(iiii).ViolinAlpha =  1;
        vi(iiii).ScatterPlot.MarkerFaceColor = cols_vi(iiii,:);
        vi(iiii).EdgeColor = cols_vi(iiii,:);
        vi(iiii).BoxColor = cols_vi(iiii,:);
        vi(iiii).ViolinPlot.LineWidth = 2;
    end
    set(gca,'FontSize', 16)
    xtickangle(45)
    if contains(ROL_vars{i}, 'onsets')
        ylabel('ROL (ms)');
    elseif contains(ROL_vars{i}, 'peaks')
        
        ylabel('Time to peak (ms)');
    end
    if contains(ROL_vars{i}, 'sc1c2_tstat')
        ylabel('T-stat math vs. memory');
    else
        ylabel('T-stat math vs. baseline');
    end
    axis square
end


suptitle('Math only electrodes timing', 'FontSize', 20)

%% Single subject simultaneous
labels_plot = {'FG', 'ITG', 'SPL', 'IPS', 'IFG', 'MFG', 'SFG'}
lobes_plot = {'Temporal', 'Parietal', 'Frontal'}
el_selectivity = el_selectivity_MMR_ROL(strcmp(el_selectivity_MMR_ROL.elect_select, {'math only', }), :)
el_selectivity = el_selectivity(contains(el_selectivity.DK_long_josef, labels_plot) & ~strcmp(el_selectivity.DK_long_josef, {'mSFG'}),:);

el_selectivity = el_selectivity(~strcmp(el_selectivity.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);
el_selectivity = el_selectivity(~contains(el_selectivity.DK_long_josef, {'OUT OF BRAIN', 'WHITE MATTER', 'EXCLUDE', 'POSTCENTRAL GYRUS', 'PRECENTRAL GYRUS'}),:);
el_selectivity = el_selectivity(contains(el_selectivity.DK_long_josef, labels_plot) & ~strcmp(el_selectivity.DK_long_josef, {'mSFG'}),:);
el_selectivity.ROL_math_avg = cellfun(@nanmean, el_selectivity.ROL_math_onsets)


el_selectivity.labels_num = [];
el_selectivity.lobes_num = [];
for i = 1:size(el_selectivity,1)
    el_selectivity.labels_num(i) = find(strcmp(el_selectivity.DK_long_josef{i}, labels_plot));

end

el_tmp_all = [];
for i = 1:length(subjects)
    el_tmp = el_selectivity(strcmp(el_selectivity.sbj_name, subjects{i}),:);
    if size(el_tmp,1) > 1 & std(el_tmp.labels_num) > 0
        el_tmp_all = [el_tmp_all; el_tmp];
    else
    end
end

subjects = unique(el_tmp_all.sbj_name);
cols = hsv(length(subjects));


for i = 1:length(subjects)
%     subplot(6,5,i)
    el_tmp = el_tmp_all(strcmp(el_tmp_all.sbj_name, subjects{i}),:);
    plot(el_tmp.labels_num, el_tmp.ROL_math_avg, 'o', 'MarkerFaceColor', cols(i,:), 'MarkerEdgeColor', cols(i,:), 'Color', cols(i,:), 'MarkerSize', 10)
    boxplot([el_tmp.labels_num, el_tmp.ROL_math_avg],'PlotStyle','compact')

    hold on
    xlim([0.5 7.5])
    ylim([0 .4])
    set(gca,'xticklabels', labels_plot)
    set(gca,'FontSize', 12)
    ylabel('ROL (ms)')
end


cols = viridis(length(subjects));


sub_oder = []
for i = 1:length(subjects)
    el_tmp = el_selectivity(strcmp(el_selectivity.sbj_name, subjects{i}),:);
        
    means = varfun(@nanmean,el_tmp,'InputVariables','ROL_math_avg', 'GroupingVariables','labels_num');
    stds =  varfun(@nanstd,el_tmp,'InputVariables','ROL_math_avg', 'GroupingVariables','labels_num');
    sub_oder(i,1) = round(sum(means.labels_num)+std(means.labels_num));
    
end
[~, idx] = sort(sub_oder, 'ascend');
subjects = subjects(idx);

for i = 1:length(subjects)
    subplot(2,13,i)
    el_tmp = el_selectivity(strcmp(el_selectivity.sbj_name, subjects{i}),:);
    
    %     plot(el_tmp.labels_num, el_tmp.ROL_math_avg, '-o', 'MarkerFaceColor', cols(i,:), 'MarkerEdgeColor', cols(i,:), 'Color', cols(i,:), 'MarkerSize', 10)
    hold on
    
    means = varfun(@nanmean,el_tmp,'InputVariables','ROL_math_avg', 'GroupingVariables','labels_num');
    stds =  varfun(@nanstd,el_tmp,'InputVariables','ROL_math_avg', 'GroupingVariables','labels_num');
    plot(means.labels_num, means.nanmean_ROL_math_avg, '-o', 'MarkerFaceColor', cols(i,:), 'MarkerEdgeColor', cols(i,:), 'Color', cols(i,:), 'MarkerSize', 7, 'LineWIdth', 2)
    for ii = 1:size(means,1)
        mt = means.nanmean_ROL_math_avg(ii);
        st = stds.nanstd_ROL_math_avg(ii);
        %         plot(means.labels_num(ii), mt, '-o', 'MarkerFaceColor', cols(i,:), 'MarkerEdgeColor', cols(i,:), 'Color', cols(i,:), 'MarkerSize', 10)
        if st > 0
            line([means.labels_num(ii) means.labels_num(ii)], [mt-st mt+st], 'Color', cols(i,:), 'LineWidth', 2)
        else
        end
    end
    xlim([0.5 7.5])
    ylim([0 0.45])
    
    set(gca,'xticklabels', labels_plot)
    
    set(gca,'FontSize', 8)
    if i == 1 || i == 14
        ylabel('ROL (ms)')
    else
        set(gca,'ytick',[])
        xtickangle(45)
        set(gca,'xtick',1:7)
    end
    
    if i < 14
        set(gca,'xtick',[])
        
    else
    end
%     set(gca,'color', [.9 .9 .9]);
%     set(gcf,'color', [.9 .9 .9]);
    set(gcf,'color', 'w')
%     grid on
end


cfg.chan_highlight = 1;
cfg.highlight_col = [1 0 0];

cfg.views = {'ventral', 'ventral', 'lateral', 'lateral'};
cfg.hemis = {'right', 'left', 'left', 'right'};
cfg.figureDim = [0 0 .5 1];
cfg.subplots = [2, 2];
cfg.alpha = 0.6;
cfg.MarkerSize = 15;
cfg.MarkerSize_chan_highlight = 10;

for i = 1:length(subjects)
    s = subjects{i};
    el_tmp = el_selectivity(strcmp(el_selectivity.sbj_name, s),:);
    load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
    for ii = 1:size(el_tmp,1)
        cfg.chan_highlight = el_tmp.chan_num(ii);
        PlotCoverageElect(subjVar, cfg)
        fname = sprintf('%scoverage/%s_%s_%s_coverage_math_%s.png',dirs.result_dir, el_tmp.DK_long_josef{ii}, num2str(el_tmp.chan_num(ii)), s, task);
        savePNG(gcf, 300, fname)
    end
end

