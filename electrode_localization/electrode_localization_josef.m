%% 
[server_root, comp_root, code_root] = AddPaths('Pedro_iMAC');
dirs = InitializeDirs(' ', ' ', comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'

subj_josef_dir = '/Volumes/LBCN8T/Stanford/data/electrode_localization/subjects/second/';
subj_josef = dir(fullfile([subj_josef_dir]))

subjects = [];
count = 1
for i = 1:length(subj_josef)
    s_tmp = subj_josef(i);
    name_tmp = strsplit(s_tmp.name, {'_', '.'});
    if isempty(name_tmp{1}) & length(name_tmp) > 2
        subjects{count} = [name_tmp{2} '_' name_tmp{3} '_' name_tmp{4}];
    elseif length(name_tmp) == 2
    else
        subjects{count} = [name_tmp{1} '_' name_tmp{2} '_' name_tmp{3}];
        count = count + 1;
    end
end


% Load Josef's table, load subjVar and integrate
for i = 1:length(subjects)
    s = subjects{i};
    load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
    col = find(strcmp(subjVar.elinfo.Properties.VariableNames, 'DK_long_josef'));

    josef_tmp = CorrectNamesJosef(subjVar.elinfo(:,col));
    josef_tmp = table2cell(josef_tmp);
    
    subjVar.elinfo.DK_long_josef = [];
    subjVar.elinfo.DK_long_josef = josef_tmp;
    save([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat'], 'subjVar');
    disp(['raplaced subjVar with josef localization of subject ' s])
end


% Load Josef's table, load subjVar and integrate
for i = 11:length(subjects)
    s = subjects{i};
    %     s
    j_table = readtable(sprintf('%s%s.xlsx',subj_josef_dir,  s));
    last_col = find(strcmp(j_table.Properties.VariableNames, 'Destr_long'));
    j_table = j_table(:,last_col+1);
    j_table.Properties.VariableNames = {'DK_long_josef'};
    
    j_table = CorrectNamesJosef(j_table);
    %     j_table(1:10,:)
    %     j_table = j_table(:,last_col+1:last_col+2);
    %     j_table.Properties.VariableNames = {'DK_long_josef', 'LBCN_josef'};
    
    
    load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
    
    %     save([dirs.original_data filesep  s filesep 'subjVar_pre_josef_'  s '.mat'], 'subjVar')
    %     load([dirs.original_data filesep  s filesep 'subjVar_pre_josef_'  s '.mat'])
    %     disp(['saved copy of subjVar of subject ' s])
    %     if sum(strcmp(subjVar.elinfo.Properties.VariableNames, 'DK_long_josef'))  == 0
    %         subjVar.elinfo = [subjVar.elinfo j_table];
    josef_tmp = table2cell(j_table);
    
    subjVar.elinfo.DK_long_josef = [];
    subjVar.elinfo.DK_long_josef = josef_tmp;
    
    save([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat'], 'subjVar');
    disp(['raplaced subjVar with josef localization of subject ' s])
    %     else
    %     end
end

subjects_missing = {'S13_56_THS'};

for i = 1:length(subjects_missing)
    s = subjects_missing{i};
    load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
    fname = sprintf('%s/%s.xlsx',dirs.comp_root, s);
    writetable(subjVar.elinfo, fname)
end




Problem with S13_56_THS, excel sheet does not contain all channels
Problem with S11_31_DZa, excel sheet does not contain all channels
Problem with S18_131_CB, excel sheet does not contain all channels




vars = {'sbj_name','chan_num', 'FS_label', 'WMvsGM', 'LvsR', 'sEEG_ECoG', 'DK_lobe', 'Destr_long', 'DK_long_josef', 'MNI_coord'};
subjVar_all = ConcatSubjVarsTasks(subjects, dirs, vars);
writetable(subjVar_all, sprintf('%sfull_cohort_electrode_localization.xlsx',subj_josef_dir))


% Explore
elecs = subjVar_all(contains(subjVar_all.LBCN_josef, {'IPS'}) & subjVar_all.MMR == 1,:);
sub_MMR_IPS = unique(elecs.sbj_name)


elecs = subjVar_all(contains(subjVar_all.LBCN_josef, {'pITG'}) & subjVar_all.MMR == 1,:);

% Load MMR selectivity
load('/Volumes/LBCN8T/Stanford/data/Results/MMR/elinfo/elinfo_MMR.mat')
data_MMR = data_all;


select = 


elect_select

sub_MMR_IPS = unique(elecs.sbj_name)
IPS_all = []
for i = 1:length(sub_MMR_IPS)
    s = sub_MMR_IPS{i};

    if contains(s,{'S15_90_SO', 'S17_116_AA', 'S18_132_MDC'})
    else
        load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
        IPS_tmp = table(subjVar.elinfo.DK_long_josef, data_MMR.(s).elect_select);
        IPS_tmp.Properties.VariableNames = {'LBCN_josef', 'elect_select'};
        IPS_all = [IPS_all; IPS_tmp];
    end
end

IPS_all = IPS_all(contains(IPS_all.LBCN_josef, 'IPS'),:)

tabulate(IPS_all.elect_select)



elecs = subjVar_all(contains(subjVar_all.LBCN_josef, {'AG'}) & subjVar_all.MMR == 1,:);
sub_MMR_AG = unique(elecs.sbj_name)
AG_all = []
for i = 1:length(sub_MMR_AG)
    s = sub_MMR_AG{i};

    if contains(s,{'S15_90_SO', 'S17_116_AA', 'S18_132_MDC'})
    else
        load([dirs.original_data filesep  s filesep 'subjVar_'  s '.mat']);
        AG_tmp = table(subjVar.elinfo.LBCN_josef, data_MMR.(s).elect_select);
        AG_tmp.Properties.VariableNames = {'LBCN_josef', 'elect_select'};
        AG_all = [AG_all; AG_tmp];
    end
end

AG_all = AG_all(contains(AG_all.LBCN_josef, 'AG'),:)

tabulate(AG_all.elect_select)

cfg = getPlotCoverageCFG('full');
cfg.alpha = 0.5
cfg.MarkerSize = 6
cfg.MarkerColor = 'r'
plot_elects.elinfo = elecs
PlotModulation(dirs, plot_elects, cfg)





elecs = subjVar_all(contains(subjVar_all.LBCN_josef, {'IPS'}) & ~contains(subjVar_all.LBCN_josef, {'AG'}) & subjVar_all.MMR == 1,:);

tabulate(elecs.LBCN_josef)
discretize(elecs.LBCN_josef)

cfg.MarkerColor = 'b'
plot_elects.elinfo = elecs
PlotModulation(dirs, plot_elects, cfg)


elecs = subjVar_all(contains(subjVar_all.LBCN_josef, {'SPL'}) & ~contains(subjVar_all.LBCN_josef, {'DYSPLASIA TISSUE'}) & subjVar_all.MMR == 1,:);
tabulate(elecs.LBCN_josef)

cfg.MarkerColor = 'g'
plot_elects.elinfo = elecs
PlotModulation(dirs, plot_elects, cfg)


% ROIs math 

math_rois = {'IPS', 'AG', 'ITG', 'SPL', 'SFG', 'MFG', 'IFG', 'mPFC', 'HIPPOCAMPUS'};
elecs = subjVar_all(contains(subjVar_all.DK_long_josef, math_rois),:);





cfg = getPlotCoverageCFG('full');
cfg.alpha = 0.5;
cfg.MarkerSize = 8;
plot_elects.elinfo = elecs
cfg.MarkerEdgeColor = [0 0 0]

colors = hsv(length(math_rois))
for i = 1:length(math_rois)
    elecs_tmp = elecs(contains(elecs.DK_long_josef, math_rois{i}),:);
    cfg.MarkerColor = colors(i,:);
    cfg.plot_label = 1;
    cfg.colum_label = {'sbj_name', 'FS_label'};
    cfg.col_label = [0 0 0];
    cfg.label_font_size = 6;
    plot_elects.elinfo = elecs_tmp;
    PlotModulation(dirs, plot_elects, cfg)
    savePNG(gcf, 300, sprintf('%scoverage_%s.png', subj_josef_dir,math_rois{i}))
    close all
end


MMR_rois_all = MMR_rois_all(contains(MMR_rois_all,))


subj_josef_dir

a = tabulate(subjVar_all.DK_long_josef)
josef = table
josef.name = a(:,1)
josef.count = a{:,2}
josef.count = vertcat(a{:,2})
josef = sortrows(josef, 'name')


%% Check which subjects contain Josef label\





