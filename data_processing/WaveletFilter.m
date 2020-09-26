function [wave_out] = WaveletFilter(data,fsample,fs_targ,freqs, span, norm, avgfreq)

%% INPUTS
% data: EEG signal (1 x time)
% freqs (optional): vector containing frequencies at which wavelet is
%                   computed (in Hz), or string
% span (optional): span of wavelet (i.e. width of gaussian that forms
%                  wavelet, in units of cycles- specific to each
%                  frequency)
% fs_targ (optional): target sampling rate of wavelet output
% norm (optional): normalize amplitude of timecourse within each frequency
%                  band (to eliminate 1/f power drop with frequency)
% avgfreq (optional): average across frequency dimension to yield single timecourse 
%                     (e.g. for computing HFB timecourse). If set to true,
%                     only amplitude information will remain (not phase, since 
%                     cannot average phase across frequencies)

if isempty(avgfreq)
    if strcmp(freqs,'HFB')
        avgfreq = true;
    else
        avgfreq = false;
    end
end

% if using standard frequency band, e.g. 'HFB', find actual frequencies
if ischar(freqs)
    freqs = genFreqs(freqs);
end

if isempty(span)
    span = 1;
end
if isempty(norm)
    norm = true;
end

if strcmp(freqs,'HFB')
    spans = ones(numel(freqs),1)*span;  %% if HFB  use the same value
else
    spans = linspace(0.3,1.2,numel(freqs))*span; %% if spec  use linspace
end
%%

ds = round(fsample/fs_targ); % factor by which to downsample
data = data(:)'; % make sure signal is a row vector
time =(1:length(data))/fsample;
siglength_ds = length(time(1:ds:end));
wave_out.wave = zeros(numel(freqs),siglength_ds,'single');
if ~avgfreq
    wave_out.phase = zeros(numel(freqs),siglength_ds,'single');
end
wave_out.spectrum = zeros(1,numel(freqs)); % power spectrum (before normalizing)
% Spectral data, frequencies saved separately 


for f = 1:numel(freqs)
    freq = freqs(f);
    %% need to discuss
    span=spans(f); 
    %%
    sigma = span/freq;
    t = -4*sigma:1/fsample:4*sigma;
    wavelet = exp(-(t.^2)/(2*sigma^2)).*exp(1i*2*pi*freq*t);    % wavelet = gaussian * complex sinusoid
    wave_tmp = conv(data,conj(wavelet),'same');                 % convolve signal with wavelet
    wave_out.wave(f,:) = abs(wave_tmp(:,1:ds:end)).^2;          % downsample and converting the complex to real numbers  
%     wave_out.wave(f,:) = abs(wave_tmp(:,1:ds:end));          % downsample and converting the complex to real numbers
    wave_out.spectrum(f) = nanmean(wave_out.wave(f,:));
    if ~avgfreq
        wave_out.phase(f,:) = angle(wave_tmp(:,1:ds:end)); 
    end
end


if (norm)
    wave_out.wave = zscore(wave_out.wave,[],2); % normalize across time-dimension
end
    
% HFB or another frequency band (averaging across frequencies)
if (avgfreq)
    wave_out.wave = nanmean(wave_out.wave,1);
end

wave_out.freqs = freqs;
wave_out.wavelet_span = span;
wave_out.time = time(1:ds:end);
wave_out.fsample = round(fsample/ds);

