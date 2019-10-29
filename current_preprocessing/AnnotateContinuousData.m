function [em, ti, lockevent, data_fsample] = AnnotateContinuousData(sbj_name, project_name, bn, dirs,el,freq_band,datatype)
%% INPUTS:
%   sbj_name: subject name
%   project_name: name of task
%   block_names: blocks to be analyed (cell of strings)
%   dirs: directories pointing to files of interest (generated by InitializeDirs)
%   elecs: can select subset of electrodes to epoch (default: all)
%   datatype: 'CAR', 'HFB', or 'Spect' (which type of data to load and epoch)
%   thr_raw: threshold for raw data (z-score threshold relative to all data points) to exclude timepoints
%   thr_diff: threshold for changes in signal (diff bw two consecutive points; also z-score)
%   epoch_params.locktype: 'stim' or 'resp' (which events to timelock to)
%   epoch_params.bef_time: time (in s) before event to start each epoch of data
%   epoch_params.aft_time: time (in s) after event to end each epoch of data
%   epoch_params.blc: baseline correction
%       .run: true or false (whether to run baseline correction)
%       .locktype: 'stim' or 'resp' (which event to use to choose baseline window)
%       .win: 2-element vector specifiying window relative to lock event to use for baseline, in sec (e.g. [-0.2 0])
%   epoch_params.noise.method: 'trials','timepts', or 'none' (which baseline data to
%                       exclude before baseline correction)
%               .noise_fields_trials  (which trials to exclude- if method = 'trials')
%               .noise_fields_timepts (which timepts to exclude- if method = 'timepts')

% datatype = 'Band'
% freq_band = 'HFB'
% el = 1

%% Load globalVar
fn = sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn);
load(fn,'globalVar');

%% Create folder with annotated data
dir_in = [dirs.data_root,filesep,datatype,'Data',filesep,freq_band,filesep,sbj_name,filesep,bn];
dir_out = [dir_in,filesep,'AnnotatedData'];
if ~exist(dir_out)
    mkdir(dir_out)
end


%% Load and unify trialinfo
load([dirs.psych_root,filesep,sbj_name,filesep,bn,filesep,'trialinfo_',bn,'.mat'])

ti = unifyTrialinfoEncoding(project_name, trialinfo);
lockevent = ti.allonsets(:,1);



%% Load data type of choice
load(sprintf('%s/%siEEG%s_%.2d.mat',dir_in,freq_band,bn,el));


data_fsample = floor(data.fsample);
inds_stim = floor(lockevent*data_fsample);
inds_RT = floor(ti.RT_lock*data_fsample);



%% Complete encoding matrix
em = zeros(size(data.wave,2), size(ti,2)+1); % +1 .is because of HFB. it should be + how many brain features... 
ti_m = ti{:,:};
% Add HFB
em(:,1) = data.wave;

for i = 1:size(inds_stim,1)
    if inds_RT(i) ~= 0
    duration = inds_stim(i):inds_RT(i);
    em(duration, 2:size(ti_m,2)+1) = repmat(ti_m(i,:), length(duration), 1);  
    else
       % here need to complete with the stim duration for the rest condition 
    end
end

% em_math = em;
% em_math(em_math(:,2)~=4,1) = nan;
% lockevent_math = lockevent(ti.task_general_cond_name ==4);
% inds_stim_math = floor(lockevent_math*data.fsample);
% 
% em_memo = em;
% em_memo(em_memo(:,2)~=6,1) = nan;
% lockevent_memo = lockevent(ti.task_general_cond_name ==6);
% inds_stim_memo = floor(lockevent_memo*data.fsample);
% 
% hold on
% plot(em(:,1), 'Color', [.7 .7 .7])
% plot(em_memo(:,1),'b')
% plot(em_math(:,1), 'r')





end

