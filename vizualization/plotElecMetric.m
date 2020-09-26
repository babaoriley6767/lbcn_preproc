function plotElecMetric(sbj_name,dirs,elecs,vals)

% load sbj variable w/cortex, elecs, etc.
load([dirs.original_data,filesep,sbj_name,filesep,'subjVar.mat'])

% load globalVar (to determine correct electrode ordering)

