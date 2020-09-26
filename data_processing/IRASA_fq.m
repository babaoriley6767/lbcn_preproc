function IRASA = IRASA_fq(sbj_name, project_name, block_names, dirs, electrode, freq_band,locktype, column,conds)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MATLAB script for the extraction of rhythmic spectral features
% from the electrophysiological signal based on Irregular Resampling
% Auto-Spectral Analysis (IRASA, Wen & Liu, Brain Topogr. 2016)
%
% Ensure FieldTrip is correcty added to the MATLAB path:
%   addpath <path to fieldtrip home directory>
%   ft_defaults
%
% From Stolk et al., Electrocorticographic dissociation of alpha and
% beta rhythmic activity in the human sensorimotor system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extended by Pedro Pinheiro-Chagas (2020)



% get both electrode names and electrode numbers
load([dirs.data_root,filesep,'OriginalData',filesep,sbj_name,filesep,'global_',project_name,'_',sbj_name,'_',block_names{1},'.mat'])
if iscell(electrode)
    elecnums = ChanNamesToNums(globalVar,electrode);
    elecnums = elecnums;
else
    elecnums = electrode;
    elecnames = ChanNumsToNames(globalVar,elecnums);
end

% Load subject variable
load([dirs.original_data filesep  sbj_name filesep 'subjVar_'  sbj_name '.mat']);

cfg = [];
cfg.decimate = false;
concat_params = genConcatParams(project_name, cfg);
concat_params.decimate = true;
concat_params.fs_targ = 500;
concat_params.data_format = 'fieldtrip_raw'; %'fieldtrip_fq' fieldtrip_raw
concat_params.trialinfo_var = column; % '' isCalc int_cue_targ_time


IRASA = struct;
for iel = 1:length(elecnums)
   
    % Load and select data
    sbj_name
    elecnums(iel)
    data_all = ConcatenateAll(sbj_name,project_name,block_names,dirs, elecnums(iel),'CAR',freq_band,locktype,concat_params);
    trialinfo_tmp = table(data_all.trialinfo);
    trialinfo_tmp.Properties.VariableNames = {column};
    
    if isempty(conds)
        tmp = find(~cellfun(@isempty,(data_all.trialinfo.(column))));
        conds = unique(data_tmp.trialinfo.(column)(tmp));
    end
    [grouped_trials_all,grouped_condnames] = groupConds(conds,trialinfo_tmp,column,'none', [],false);
    
    % Don't calculate IRASA if ntrials in at least one of the conditions is smaller than 3
    if sum(cellfun(@length,grouped_trials_all) < 3) == 0
        for i = 1:length(conds)
            
            % Select trials condition
            data = data_all;
            fields_correct = {'trial', 'time', 'trialinfo'};
            for ii = 1:length(fields_correct)
                data.(fields_correct{ii}) = data.(fields_correct{ii})(grouped_trials_all{i});
            end
            data.trialinfo = ones(length(data.trialinfo),1,1);
            
            % partition the data into ten overlapping sub-segments
            w = data.time{1}(end)-data.time{1}(1); % window length
            cfg               = [];
            cfg.length        = w*.9;
            cfg.overlap       = 1-((w-cfg.length)/(10-1));
            data_r = ft_redefinetrial(cfg, data);
            
            % perform IRASA and regular spectral analysis
            cfg               = [];
            cfg.foilim        = [1 50];
            cfg.taper         = 'hanning';
            cfg.pad           = 'nextpow2';
            cfg.keeptrials    = 'yes';
            cfg.method        = 'irasa';
            frac_r = ft_freqanalysis(cfg, data_r);
            cfg.method        = 'mtmfft';
            orig_r = ft_freqanalysis(cfg, data_r);
            
            % average across the sub-segments
            frac_s = {};
            orig_s = {};
            for rpt = unique(frac_r.trialinfo)'
                cfg               = [];
                cfg.trials        = find(frac_r.trialinfo==rpt);
                cfg.avgoverrpt    = 'yes';
                frac_s{end+1} = ft_selectdata(cfg, frac_r);
                orig_s{end+1} = ft_selectdata(cfg, orig_r);
            end
            frac_a = ft_appendfreq([], frac_s{:});
            orig_a = ft_appendfreq([], orig_s{:});
            
            % average across trials
            cfg               = [];
            cfg.trials        = 'all';
            cfg.avgoverrpt    = 'yes';
            frac = ft_selectdata(cfg, frac_a);
            orig = ft_selectdata(cfg, orig_a);
            
            % subtract the fractal component from the power spectrum
            cfg               = [];
            cfg.parameter     = 'powspctrm';
            cfg.operation     = 'x2-x1';
            osci = ft_math(cfg, frac, orig);
            osci.powspctrm(osci.powspctrm < 0) = 0;
            
            % Fit the gaussian to find the peaks
            parameters = 1:3; % gaussians for 1-3 free parameters
            oscipeaks = struct;
            for iii = 1:length(parameters)
                model = ['gauss', num2str(iii)];
                try
                    %                 [f,goodness] = fit(osci.freq', osci.powspctrm', model);
                    [f,goodness] = fit(osci.freq', osci.powspctrm'-frac.powspctrm', model); % is this correct?
                    oscipeaks.model.(model).fit = f;
                    oscipeaks.model.(model).goodness = goodness;
                    for iiii = 1:iii
                        mean_tmp = f.(['b' num2str(iiii)]);
                        std_tmp = f.(['c' num2str(iiii)])/sqrt(2)*2.3548;
                        oscipeaks.model.(model).peaks.mean(iiii) = mean_tmp;
                        oscipeaks.model.(model).peaks.std(iiii) = std_tmp;
                        oscipeaks.model.(model).peaks.power(iiii) = mean(orig.powspctrm(min(find(orig.freq>=mean_tmp-std_tmp)):max(find(orig.freq<=mean_tmp+std_tmp))));
                    end
                catch
                    oscipeaks.model.(model).fit = nan;
                    oscipeaks.model.(model).goodness = nan;
                    oscipeaks.model.(model).peaks.mean = nan;
                    oscipeaks.model.(model).peaks.std = nan;
                    oscipeaks.model.(model).peaks.power = nan;
                end
                
            end
            % See why negative, if negative set to 0.
            IRASA.(['el_' elecnames{iel}]).(conds{i}) = oscipeaks;
            IRASA.(['el_' elecnames{iel}]).(conds{i}).ntrials = length(grouped_trials_all{i});
            IRASA.(['el_' elecnames{iel}]).(conds{i}).orig = orig;
            IRASA.(['el_' elecnames{iel}]).(conds{i}).frac = frac;
            IRASA.(['el_' elecnames{iel}]).(conds{i}).osci = osci;
        end
        
    else
        parameters = 1:3; % gaussians for 1-8 free parameters
        oscipeaks = struct;
        for iii = 1:length(parameters)
            model = ['gauss', num2str(iii)];
            oscipeaks.model.(model).fit = nan;
            oscipeaks.model.(model).goodness = nan;
            oscipeaks.model.(model).peaks.mean = nan;
            oscipeaks.model.(model).peaks.std = nan;
            oscipeaks.model.(model).peaks.power = nan;
        end
        for i = 1:length(conds)
%             IRASA.(['el_' globalVar.channame{iel}]).(conds{i}) = oscipeaks;
            IRASA.(['el_' elecnames{iel}]).(conds{i}) = oscipeaks;
            IRASA.(['el_' elecnames{iel}]).(conds{i}).ntrials = length(grouped_trials_all);
            IRASA.(['el_' elecnames{iel}]).(conds{i}).orig = nan;
            IRASA.(['el_' elecnames{iel}]).(conds{i}).frac = nan;
            IRASA.(['el_' elecnames{iel}]).(conds{i}).osci = nan;
        end
        
    end
    
end



% Save
% dir_out = sprintf('%s/%s/%s/signal_properties/', dirs.result_root, project_name, sbj_name);
dir_base = '/Volumes/LBCN8T_2/Stanford/data/Results';
dir_out = sprintf('%s/%s/%s/signal_properties/', dir_base, project_name, sbj_name);

if ~exist(dir_out,'dir')
    mkdir(dir_out)
end
fname = [dir_out 'IRASA.mat'];
save(fname, 'IRASA')

end



