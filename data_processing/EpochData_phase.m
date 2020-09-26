function [epoched_data] = EpochData(data,lockevent,bef_time,aft_time)

% This functon takes in non-epoched data and event file with trial info
% and outputs epoched data
% INPUTS:
%   data: data from single channel (either raw data- 1 x time; or frequency decomposed data- freq x time)
%   evts: event file (events_byTrial)
%   lockevent: 'stim' or 'resp'
%   bef_time: time (in s) before lockevent to start each epoch of data
%   aft_time: time (in s) after lockevent to end each epoch of data

nfreq = size(data.wave,1);  % determine if single timeseries or spectral data (i.e. multiple frequencies)
ntrials = size(lockevent,1);
siglength = size(data.wave,2);
start_inds = floor(lockevent*data.fsample);
bef_ind = floor(bef_time*data.fsample);
aft_ind = floor(aft_time*data.fsample);
len_trial = aft_ind-bef_ind + 1;

if nfreq > 1
    epoched_data.wave = nan(nfreq,ntrials,len_trial);
    epoched_data.phase= nan(nfreq,ntrials,len_trial);
else
    epoched_data.wave = nan(ntrials,len_trial);
    epoched_data.phase= nan(ntrials,len_trial);
end

for i = 1:ntrials
    if isnan(start_inds(i)) %%%%
    else
        if (siglength>=start_inds(i)+aft_ind)
            inds = (start_inds(i)+bef_ind):(start_inds(i)+aft_ind);
        else  % if recording ended before the of the full last epoch
            inds = (start_inds(i)+bef_ind):siglength;
        end
        if nfreq > 1
            epoched_data.wave(:,i,1:length(inds))=data.wave(:,inds);
            epoched_data.phase(:,i,1:length(inds))=data.phase(:,inds);
        else
            epoched_data.wave(i,1:length(inds))=data.wave(inds);
            epoched_data.phase(i,1:length(inds))=data.phase(inds);
        end
    end
end

epoched_data.time = linspace(bef_time,aft_time,len_trial);
epoched_data.fsample = data.fsample;
epoched_data.label = data.label;
% add other fields from data to epoched_data
end
