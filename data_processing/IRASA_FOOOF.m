addpath(genpath('/Users/pinheirochagas/Pedro/Stanford/code/lbcn_personal/'))
addpath(genpath('/Users/pinheirochagas/Pedro/Stanford/code/lbcn_preproc/'))
addpath('/Users/pinheirochagas/Pedro/Stanford/code/fieldtrip/')
ft_defaults

%% IRASA pipeline
[server_root, comp_root, code_root] = AddPaths('Pedro_iMAC');%% IRASA pipeline
[server_root, comp_root, code_root] = AddPaths('Pedro_iMAC');
sbj_name = 'S19_141_LKb';
project_name = 'EglyDriver';
dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'

load([dirs.original_data filesep  sbj_name filesep 'subjVar_'  sbj_name '.mat']);
sbj_name = 'S19_141_LKb';
project_name = 'EglyDriver';
dirs = InitializeDirs(project_name, sbj_name, comp_root, server_root, code_root); % 'Pedro_NeuroSpin2T'

load([dirs.original_data filesep  sbj_name filesep 'subjVar_'  sbj_name '.mat']);

for el = 1:length(subjVar.labels_EDF)
    IRASA_fq(sbj_name, project_name, subjVar.labels_EDF{el}, dirs)
end

%% Plot
plotIRASA(sbj_name, project_name, 61, dirs)


%% FOOF
addpath(genpath('/Users/pinheirochagas/Pedro/Stanford/code/fooof/'))
addpath(genpath('/Users/pinheirochagas/Pedro/Stanford/code/fooof_mat/'))

elec=113
bn='E19-665_0024'
dir_in = [dirs.data_root,filesep,'CAR','Data',filesep,'CAR',filesep,sbj_name,filesep,bn];
load(sprintf('%s/%siEEG%s_%.2d.mat',dir_in,'CAR',bn,elec));


fs=data.fsample;
wave=data.wave;
[psd, freq] = pwelch(wave, 4000, [], [], 1000);

% Transpose, to make FOOOF inputs row vectors
freq = freq';
psd = psd';

% FOOOF settings
settings = struct();  % Use defaults
f_range = [1, 60];

% Run FOOOF
fooof_results = fooof(freq, psd, f_range, settings,1);

% Print out the FOOOF Results
fooof_results

plot(fooof_results.freqs,fooof_results.fooofed_spectrum)
hold on
plot(fooof_results.freqs,fooof_results.power_spectrum)
plot(fooof_results.freqs,fooof_results.bg_fit)
hold off


plot(fooof_results.fooofed_spectrum - fooof_results.bg_fit)





t = 0:1/fs:5-1/fs;

x = cos(2*pi*100*t) + randn(size(t));

[pxx,f] = pwelch(wave,500,300,500,fs);

plot(f,10*log10(pxx)) 

xlabel('Frequency (Hz)')

ylabel('PSD (dB/Hz)')



