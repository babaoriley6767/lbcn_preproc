function ROL_params = genROLParams_NC(project_name)
%% INPUTS:
%   task: task name
% this method is based on Jessica and Omri's paper 'https://doi.org/10.1038/s41467-020-14432-8'
% edited by Chao on May. 13, 2020
% the reason that Chao did it is to make it adapted to Pedro's pipeline
switch project_name
    case {'race_encoding_simple', 'MMR', 'UCLA'}
        % Set ROL parameters
        ROL_params = struct;
        ROL_params.thr_value = 1; % How many SD over baseline period
        ROL_params.thr_value_counter = 25; % How many bins must surpass threshold
        ROL_params.bin_timewin = 0.002; % How much non-overlap between bins
        ROL_params.times_nonover = 15; % 30ms bins with 28ms overlap
       
        ROL_params.blc = 1; % chao
        ROL_params.power = false;
        ROL_params.smooth = false;
        ROL_params.deactive = false;
        % Set range parameters
        % ROL_params.end_value = .5; % 500 ms
        ROL_params.end_value = 1;
        ROL_params.start_value = 0; % stim_onset
        ROL_params.bas_value = 0; % end of baseline
        ROL_params.baseline = [-0.2 0];% time window of baseline
        
        ROL_params.pre_event = -0.2;% baseline period used for baseline correction
        ROL_params.dur = 1;%1000ms
end


end