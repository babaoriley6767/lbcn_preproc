%% ROL from Jessica and Omri NC
project_name = 'MMR';
block_names = BlockBySubj(sbj_name,project_name);
dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 
% load subjVar
load([dirs.original_data filesep  sbj_name filesep 'subjVar_'  sbj_name '.mat']);

ROL_params = genROLParams_NC(project_name);
ROL_NC2 = getROLALL_NC(sbj_name,project_name,block_names,dirs,[],'HFB',ROL_params,'condNames',{'autobio', 'math'}) ;% condNames
%%%%%%%%
cond_names = 'condNames';%???
sub_cond = {'math'};

% go to the working folder
dir_out = [dirs.result_root,'/',project_name,'/',sbj_name,'/ROL_NC/'];
cd(dir_out)

ROL_NC_fig = ROL_NC2;%%%%%%%%
% Inspect results
elec_inspect = [105 16 61] ;

twin = [0.05 1];
%chao plot the distribution of ROL
plot_params = genPlotParams(project_name,'timecourse');
figure('units', 'normalized', 'outerposition', [0 0 0.2 0.4])
for i = 1:length(elec_inspect)
    elec = elec_inspect(i)
    ROL_NC_fig.(sub_cond{1}).onsets{elec}(ROL_NC_fig.(sub_cond{1}).peaks{elec} < twin(1) | ROL_NC_fig.(sub_cond{1}).peaks{elec} > twin(2)) = nan;
    
    h(i) = plot(sort(ROL_NC_fig.(sub_cond{1}).peaks{elec},'descend'), 1:length(ROL_NC_fig.(sub_cond{1}).peaks{elec}),'o','Color',plot_params.col(i,:),'LineWidth',1);
    hold on
end
title('Single trial ROL NC')
suptitle(subjVar.labels_EDF{elec_inspect})
xlabel('ROL (s)')
xlim([0 0.5])
xticks(0:0.1:2)
xticklabels(0:0.1:2)
ylabel('Trials')
set(gca,'fontsize',10)
grid on
leg = legend(h,sub_cond,'Location','Northeast', 'AutoUpdate','off');%
legend boxoff%
set(leg,'fontsize',18, 'Interpreter', 'none')
fn_out = sprintf('%s/%s_%s_%s_ROL2_fig.png',dir_out,sbj_name,subjVar.labels_EDF{elec_inspect},project_name);%
savePNG(gcf, 100, fn_out)%%%%%%%%%

% Exlucde (set to nan) ROLS beyond the temporal window of choice and calculate mean and median ROL across trials per electrode
for i = 1:length(ROL_NC_fig.(sub_cond{1}).onsets)%length of the elecs
    for j = 1:length(sub_cond)
    ROL_NC_fig.(sub_cond{j}).onsets{i}(ROL_NC_fig.(sub_cond{j}).onsets{i} < twin(1) | ROL_NC_fig.(sub_cond{j}).onsets{i} > twin(2)) = nan;
    ROL_NC_fig.(sub_cond{j}).median(i) = nanmedian(ROL_NC_fig.(sub_cond{j}).onsets{i});
    ROL_NC_fig.(sub_cond{j}).mean(i) = nanmean(ROL_NC_fig.(sub_cond{j}).onsets{i});
    end
end

% save the new ROL as ROL_fig in the result folder

fn_out = sprintf('%s%s_%s_ROL_NC_fig2.mat',dir_out,sbj_name,project_name);%%%%%%%%%
save(fn_out,'ROL_NC_fig');

% show the mean time of ROL and the percentage of trials with meaningful
% ROL(without NaN)
for i = 1:length(sub_cond)
    sprintf('%s_%s_%s_ROL_NC_mean_of_%s_is_%d',sbj_name,subjVar.labels_EDF{elec_inspect},project_name,sub_cond{i},(ROL_NC_fig.(sub_cond{i}).mean(elec_inspect)*1000))
end

for i = 1:length(sub_cond)
    sprintf('%s_%s_%s_ROL_NC_ratio_of_%s_from_%d_trials_is_%d',sbj_name,subjVar.labels_EDF{elec_inspect},project_name,sub_cond{i},length(ROL_NC_fig.(sub_cond{i}).onsets{elec_inspect,1}),sum(~isnan(ROL_NC_fig.(sub_cond{i}).onsets{elec_inspect,1}))*100/length(ROL_NC_fig.(sub_cond{i}).onsets{elec_inspect,1}) )
end