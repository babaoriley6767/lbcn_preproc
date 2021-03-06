function AnnotateContinuousData(sbj_name, project_name, bn, dirs,el,freq_band,thr_raw,thr_diff,epoch_params,datatype)
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



% Load globalVar
fn = sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn);
load(fn,'globalVar');


% dir_CAR = [dirs.data_root,'/originalData/',sbj_name,'/',bn];
dir_in = [dirs.data_root,filesep,datatype,'Data',filesep,freq_band,filesep,sbj_name,filesep,bn];
% dir_in = [globalVar.([datatype,'Data']),freq_band,filesep,sbj_name,filesep,bn];
dir_out = [dir_in,filesep,'AnnotatedData'];
if ~exist(dir_out)
    mkdir(dir_out)
end






end

