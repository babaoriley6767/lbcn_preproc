function [ROL]= ROLbootstrap(data,params)
%% INPUTS:
% data: epoched data
%       .wave: actual data
%       .time: timepoint corresponding to each data pt
%       .fsample: sampling rate
% params    (see genROLparams.m)

% Mo Dastjerdi - LBCN

% Updates for ver3, BLF - LBCN 2014.
% Cleaned up code, added comments
% Modified moving window, larger with more overlap

% modified by Amy Daitch- 2016

%% set default values for params if undefined

if isempty(params)
    params = genROLparams();
end

thrwin_pt = floor(params.thrwin*data.fsample);
mindur_pt = floor(params.mindur*data.fsample);

[ntrials,siglength] = size(data.wave);
bl_inds = find(data.time>= params.bl(1) & data.time <= params.bl(2));


%% determine threshold based on null/baseline (ITI) distribution

baseline = data.wave(:,bl_inds);
mean_bl = nanmean(baseline(:));
std_bl = nanstd(baseline(:));
data_bc = (data.wave-mean_bl)/std_bl; % baseline corrected data

ntrials_bs = ceil(ntrials*params.bs_frac);
bs_trials = zeros(params.bs_reps,ntrials_bs);

data_bs = [];           % bootstrapped trials (averaged across subsets of trials)
for ri = 1:params.bs_reps
    bs_trials(ri,:)=randperm(ntrials,ntrials_bs);
    data_bs = [data_bs; nanmean(data_bc(bs_trials(ri,:),:),1)];
end

bs_bl = data_bs(:,bl_inds); % bootstrapped baseline

thr_val = params.thr*nanstd(bs_bl(:));

%% boostrapping

slopewin_pt = floor(params.slopewin*data.fsample);

winlen_pt = floor(params.winlen*data.fsample);
overlap_pt = floor(params.overlap*data.fsample);

% bs_onsets = nan(1,params.bs_reps); %bootstrapped onsets
bs_rol_thr = nan(1,params.bs_reps); %bootstrapped onsets
bs_rol_fit = nan(1,params.bs_reps); %bootstrapped onsets

start_ind = find(data.time > params.minrol,1);
for ti = 1:params.bs_reps
    
    numwins = 0; % number of consecutive windows surpassing thresh
%     ind = 1; % index of beginning of sliding window (within a bootstrapped trial)
    ind = start_ind;
    while (numwins < mindur_pt) && (ind < siglength)
        win_start = ind;
        win_end = min(ind+thrwin_pt-1,siglength);
        temp_inds = win_start:win_end;
        if (nanmean(data_bs(ti,temp_inds))>thr_val)
            %             if (nanmean(temp_mn(temp_inds))>thr_val)
            numwins = numwins+1;
        else
            numwins = 0;
        end
        ind = ind+1;
    end
    if (numwins >= mindur_pt)  % if threshold was exceeded for at least min duration
        ind = ind-mindur_pt; % first index where threshold was crossed
        bs_rol_thr(ti) = data.time(ind);
        % set window for computing more exact onset (and account for
        % possibility that the window might be cut off by beginning or
        % end of trial)
        win_start = max(ind+slopewin_pt(1),start_ind);
        win_end = min(ind+slopewin_pt(2),siglength);
        win_pt = win_start:win_end;
        
        sig_tmp = data_bs(ti,win_pt);
        w_time = data.time(win_pt);
        
        % divide larger window into smaller, partially-overlapping
        % windows
        sig_tmp= buffer(sig_tmp,winlen_pt,overlap_pt,'nodelay');
        t_tmp= buffer(w_time,winlen_pt,overlap_pt,'nodelay');
        sig_tmp(:,end)=[];
        t_tmp(:,end)=[];
        nwins = size(sig_tmp,2);
        
        slopes=NaN*ones(1,nwins);
        mse=NaN*ones(1,nwins);
        for ii=1:nwins
            Ps= polyfit(t_tmp(:,ii),sig_tmp(:,ii),1);
            y2= polyval(Ps,t_tmp(:,ii));
            slopes(ii)= Ps(1);
            mse(ii)= sum((sig_tmp(:,ii)-y2).^2);
        end
        
        [s_tmp iA]= sort(slopes,'descend'); %slopes
        [e_tmp iB]= sort(mse,'ascend'); %errors
        %get smallest error, of top 5 slopes
        i_tmp= find( mse(iA(1:5))== min(mse(iA(1:5))) );
        %         i_tmp = find(slopes(iB(1:5))==max(slopes(iB(1:5))));
        if ~isempty(i_tmp)
%             bs_onsets(ti)= t_tmp(1,iA(i_tmp));
            bs_rol_fit(ti) = t_tmp(1,iA(i_tmp));
        end
    end
end


%remove outliers
% rsp_outliers = find(rsp_onset > 4*std(abs(rsp_onset)));
% rsp_onset(rsp_outliers) = nan;

%% Output data
ROL.thr = bs_rol_thr;
ROL.fit = bs_rol_fit;
ROL.trace_bc = data_bc;
ROL.trace_bs = data_bs;
ROL.time = data.time;





