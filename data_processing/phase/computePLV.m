function PLV = computePLV(data1,data2,PLVdim,plv_params)
%% INPUTS:
%       data1, data2: data structures containting 'phase','freqs','time',etc.
%       PLVdim:  dimension along which to compute PLV ('trials' or 'time')
%                'trials': (1 PLV value per freq/trial; i.e. across time)  or
%                'time': (1 PLV value per freq/timept; i.e. across trials)
%       plv_params: (see genPLVParams.m)
%% OUTPUT
%   PLV     .vals: complex array with dimensions freqs x trials (if PLVdim = 'trials')
%                   or freqs x time (if PLVdim = 'time)
%                   abs(PLV.vals) returns the phase-locking value and 
%                   angle(PLV.vals) returns the most common phase diff
%           .freqs: frequencies at which PLV was computed
%           .trialinfo (if PLVdim = 'trials')
%           .time (if PLVdim = 'time')

freq_inds = find(data1.freqs >= plv_params.freq_range(1) & data1.freqs <= plv_params.freq_range(2));
time_inds = find(data1.time >=plv_params.t_win(1) & data1.time <=plv_params.t_win(2)); 
PLV.freqs = data1.freqs(freq_inds);

phase_diff = angle(exp(1i*(data1.phase(freq_inds,:,time_inds)-data2.phase(freq_inds,:,time_inds))));

if (strcmp(PLVdim,'trials')) % compute across time (1 value per trial)
    PLV.vals = squeeze(nanmean(exp(1i*(phase_diff)),3)); 
    PLV.trialinfo = data1.trialinfo;
else % compute across trials (1 value per timept in trial)
    PLV.vals = squeeze(nanmean(exp(1i*(phase_diff)),2)); 
    PLV.time = data1.time;
end