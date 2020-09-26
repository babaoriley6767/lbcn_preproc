function EventIdentifier_Memoria(sbj_name, project_name, block_names, dirs)
%% Globar Variable elements

switch project_name
    case 'Memoria'
        n_stim_per_trial = 5;
    case 'Calculia'
        n_stim_per_trial = 5;
    case 'Calculia_production'
        n_stim_per_trial = 3;
%         n_initpulse = 0; % maybe change to 12
end

%% loop across blocks
for i = 1:length(block_names)
    bn = block_names{i};
    [n_initpulse,~] = EventIdentifierExceptions(sbj_name,project_name, bn);
    %% Load globalVar
    
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    iEEG_rate=globalVar.iEEG_rate;
    

    %% reading analog channel from neuralData directory
    load(sprintf('%s/Pdio%s_01.mat',globalVar.originalData,bn)); % going to be present in the globalVar
     
   
    %% varout is anlg (single percision)
    downRatio= round(globalVar.Pdio_rate/iEEG_rate);
    if max(anlg) < max(abs(anlg))
       pdio= decimate(double(anlg),downRatio)*-1; % down sample to the iEEG rate and make it positive ?
    else
       pdio= decimate(double(anlg),downRatio); % down sample to the iEEG rate and make it positive ?
    end
   
    clear anlg
    
    pdio = pdio/max(pdio);
    
    
    %% Thresholding the signal
    ind_above= pdio > 0.5;
    ind_df= diff(ind_above);
    clear ind_above
    onset= find(ind_df==1);
    offset= find(ind_df==-1);
    clear ind_df
    pdio_onset= onset/iEEG_rate;
    pdio_offset= offset/iEEG_rate;
    
    % %remove onset flash
    pdio_onset(1:n_initpulse)=[]; % Add in calculia production the finisef to experiment to have 12 pulses
    pdio_offset(1:n_initpulse)=[]; %
    
    %get osnets from diode
    pdio_dur= pdio_offset - pdio_onset;
    IpdioI= [pdio_onset(2:end)-pdio_offset(1:end-1) 0];
    isi_ind = find(IpdioI > 0.2);
    
    stim_offset= [pdio_offset(isi_ind) pdio_offset(end)];
    stim_onset= [pdio_onset(isi_ind) pdio_onset(end)];
    
    %% IF MISMATCH BW PDIO AND BEHAV DATA, EDIT HERE:
    [stim_onset,stim_offset] = StimOnsetExceptions(sbj_name,bn,stim_onset,stim_offset);

    stim_dur= stim_offset - stim_onset;
    
        %% Load trialinfo 
    % ---------------------------------------------
    % Create specific subfunctions to extract the relevant info for each
    % project_name
    load([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');

    % Add the all_stim_onset
    event_trials = find(~strcmp(trialinfo.condNames, 'rest'));
        
    rest_trials = find(strcmp(trialinfo.condNames, 'rest'));

    StimulusOnsetTime = trialinfo.StimulusOnsetTime(event_trials,1); % **
        
      
    
    %% Get trials, insturuction onsets
    %% modified for Memoria
    colnames = trialinfo.Properties.VariableNames;
    
    ntrials = size(trialinfo,1);
    if ismember('nstim',colnames) % for cases where each trial has diff # of stim
        all_stim_onset = nan(ntrials,max(trialinfo.nstim));
        stimnum = repmat(1:max(trialinfo.nstim),[ntrials,1]);
        counter = 1;
        for ti = 1:ntrials
            inds = counter:(counter+trialinfo.nstim(ti)-1);
            if inds(end)<=length(stim_onset)
                all_stim_onset(ti,1:trialinfo.nstim(ti))=stim_onset(inds);
                counter = counter+trialinfo.nstim(ti);
            end
        end
    else
        all_stim_onset = reshape(stim_onset,n_stim_per_trial,length(stim_onset)/n_stim_per_trial)';
    end
    stimnum_rs = reshape(stimnum,[1,numel(stimnum)]);
    all_stim_onset_rs = reshape(all_stim_onset,[1,numel(all_stim_onset)]);
    % the second input is project dependent
    %reshape onsets to account for the number of events in each trial
    
%%
   % Plot photodiode segmented data
    figureDim = [0 0 1 1];
    figure('units', 'normalized', 'outerposition', figureDim)
    subplot(2,3,1:3)
    hold on
    plot(pdio)
   
    % plot each stim number in diff. color
    stim_syms = {'m*','r*','g*','c*','b*'};
    heights = 0.9:-0.2:0.1;
    for i = 1:max(trialinfo.nstim)
        stim_inds = find(stimnum_rs==i);
        plot(all_stim_onset_rs(stim_inds)*iEEG_rate,heights(i)*ones(1,length(stim_inds)),stim_syms{i})
    end
        
    

    %% Comparing photodiod with behavioral data
    %for just the first stimulus of each trial
    df_SOT= diff(StimulusOnsetTime)';
    % df_stim_onset= diff(stim_onset_fifth); %fifth? why?
    df_stim_onset = diff(all_stim_onset(:,1))';
    %plot overlay
    subplot(2,3,4)
    plot(df_SOT,'o','MarkerSize',8,'LineWidth',3),hold on, plot(df_stim_onset,'r*')
    df= df_SOT - df_stim_onset;
    
    %plot diffs, across experiment and histogram
    subplot(2,3,5)
    plot(df), ylim([-.005 .005]);
    title('Diff. behavior diode (exp)');
    xlabel('Trial number');
    ylabel('Time (ms)');
    subplot(2,3,6)
    hist(df), xlim([-.005 .005])
    title('Diff. behavior diode (hist)');
    xlabel('Time (ms)');
    ylabel('Count');

    %flag large difference
    if ~all(abs(df)<.1)
        disp('behavioral data and photodiod mismatch')
        return
    end
    
    
    %% Updating the events with onsets 
    trialinfo.allonsets = nan(ntrials,size(all_stim_onset,2));
    if (size(all_stim_onset,2)>1)      
        trialinfo.allonsets(event_trials,:) = all_stim_onset;
    else
        trialinfo.allonsets(event_trials) = all_stim_onset;
    end
    trialinfo.RT_lock = nan(ntrials,1);
    for ti = 1:ntrials
        trialinfo.RT_lock(ti) = trialinfo.RT(ti) + trialinfo.allonsets(ti,trialinfo.nstim(ti));
    end

    
    %% Save trialinfo   
    fn = [dirs.project,filesep,sbj_name,filesep,bn,filesep,'trialinfo_',bn,'.mat'];
%     fn= sprintf('%s/trialinfo_%s.mat',globalVar.result_dir,bn);
    save(fn, 'trialinfo');
    
end


end