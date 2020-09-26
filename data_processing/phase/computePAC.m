function PAC = computePAC(data_phase,data_amp,pac_params)
% This function computes the phase amplitude coupling between a phase
% signal and an amplitude signal (could come from the same or different
% electrode site). Data should have dimensions of either freq x time 
% or freq x trials x time (but data_phase and data_amp must have same
% dimensions ). For each set of frequencies, it will compute
% the z-score of the actual PAC value along a distribution of surrogate
% values (generated by shifting amp relative to phase by random time)

%% INPUTS
% data_phase: data from which phase is extracted
% data_amp: data from which amp is extracted (if using phase and amp from
%           same electrode, leave empty)
% pac_params: (generated by genPACParams.m)

%% OUTPUTS
% PAC   .raw:   raw PAC value
%       .norm:  z-scored relative to surrogate distribution)
%       .phase_freq: frequencies used for phase
%       .amp_freq: frequencies used for amplitude
% Note: abs(PAC.raw/PAC.norm) returns degree of PAC;
%   angle(PAC.raw/PAC.norm) returns the phase of LF corresponding to highest
%   amplitude of HF)

if isempty(data_amp) % if extracting phase and amp from same data structure (i.e. from same elec)
    data_amp = data_phase;
end

if ndims(data_phase.phase) == 2 % (non-epoched data)
    [nfreq,ntime] = size(data_phase.phase);
else % if dim = 3 (epoched data), reshape data to dims. of freq x time
    [nfreq,ntrials,ntime] = size(data_phase.phase);
    data_phase.phase = permute(data_phase.phase,[1 3 2]);
    data_amp.wave = permute(data_amp.wave,[1 3 2]);
    data_phase.phase = reshape(data_phase.phase,[nfreq,ntime*ntrials]);
    data_amp.wave = reshape(data_amp.wave,[nfreq,ntime*ntrials]);
    data_amp.wave = normMinMax(data_amp.wave,2); % normalize amp between 0 and 1 (along time dim.), so that there are no negative amps
    ntime = ntrials*ntime;
end

% generate random time-shifts (b/w phase and amp signals) in order to
% compute surrogate dist. of PAC values 
min_skip = floor(data_phase.fsample); % min shift = 1s
max_skip = floor(ntime - data_phase.fsample); % max shift = siglength - 1s
skip = floor((max_skip-min_skip)*rand(1,pac_params.nreps))+min_skip;

phase_inds = find(data_phase.freqs >= pac_params.phase_freq(1) & data_phase.freqs <= pac_params.phase_freq(2));
amp_inds = find(data_amp.freqs >= pac_params.amp_freq(1) & data_amp.freqs <= pac_params.amp_freq(2));
nphase = length(phase_inds);
namp = length(amp_inds);

PAC.phase_freq = data_phase.freqs(phase_inds);
PAC.amp_freq = data_phase.freqs(amp_inds);

PAC.raw = nan(nphase,namp);  % Raw PAC value
PAC.norm = nan(nphase,namp); % z-scored PAC relative to surrogate distribution (w/shifted signals)

for pi = 1:nphase
    phase_tmp = data_phase.phase(phase_inds(pi),:);
    for ai = 1:namp
        if (PAC.amp_freq(ai)>(2*PAC.phase_freq(pi)))
            amp_tmp = data_amp.wave(amp_inds(ai),:);
            z = amp_tmp.*exp(1i*phase_tmp);
            PAC.raw(pi,ai) = nanmean(z);
            surr_pac = zeros(1,pac_params.nreps);
            for ri = 1:pac_params.nreps
                amp_surr = amp_tmp([skip(ri):end,1:skip(ri)-1]); % randomly shift amp relative to phase
                surr_pac(ri) = abs(nanmean(amp_surr.*exp(1i*phase_tmp)));
            end
            [surr_mn,surr_sd] = normfit(surr_pac); % fit normal distribution to surrogate data
            m_norm_length = (abs(PAC.raw(pi,ai))-surr_mn)/surr_sd; % only normalize magnitude of PAC
            m_norm_phase = angle(PAC.raw(pi,ai)); % maintain phase info (i.e. phase of LF corresponding to highest amp of HF)
            PAC.norm(pi,ai) = m_norm_length*exp(1i*m_norm_phase);
            disp(['Phase: ',num2str(PAC.phase_freq(pi)), ' Hz; Amp: ',num2str(PAC.amp_freq(ai)),' Hz'])
        end
    end
end



