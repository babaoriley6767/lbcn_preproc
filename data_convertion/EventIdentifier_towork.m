function EventIdentifier (sbj_name, project_name, block_names, dirs, pdio_chan)
%% Globar Variable elements

%% loop across blocks
for i = 1:length(block_names)
    bn = block_names{i};
    
    switch project_name
        case 'MMR'
            n_stim_per_trial = 1;
        case 'UCLA'
            n_stim_per_trial = 1;
        case 'Memoria'
            n_stim_per_trial = 5;
        case 'Calculia'
            n_stim_per_trial = 5;
        case 'Calculia_production'
            n_stim_per_trial = 3;
    end
    
    %% Load globalVar
    
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    iEEG_rate=globalVar.iEEG_rate;
    
    
    %% reading analog channel from neuralData directory
    load(sprintf('%s/Pdio%s_%.2d.mat',globalVar.originalData, bn, pdio_chan)); % going to be present in the globalVar
    
    
    %% varout is anlg (single precision)
    downRatio = round(globalVar.Pdio_rate/iEEG_rate); 
    pdio = decimate(double(anlg),downRatio); % down sample to the iEEG rate
%     pdio = pdio/max(double(pdio))*2;
    pdio = pdio/max(pdio);
    [n_initpulse_onset, n_initpulse_offset] = find_skip(anlg, 0.001, globalVar.Pdio_rate);
    clear anlg
    n_initpulse_onset = 12; n_initpulse_offset = 12

    ind_above= pdio >0.5;
ind_df= diff(ind_above);
clear ind_above
onset= find(ind_df==1);
offset= find(ind_df==-1);
clear ind_df
pdio_onset= onset/iEEG_rate;
pdio_offset= offset/iEEG_rate;
pdio_dur= pdio_offset - pdio_onset;
IpdioI= [pdio_onset(2:end)-pdio_offset(1:end-1) 0];

stim_ind= find(pdio_dur>.01);
stim_ind(1:12)=[]; %to skip misc. diode
    
    
    %% Thresholding the signal
    ind_above = pdio > 0.5;
    ind_df= diff(ind_above);
    clear ind_above
    onset = find(ind_df==1);
    offset = find(ind_df==-1);
    clear ind_df
    pdio_onset = onset/globalVar.iEEG_rate;
    pdio_offset = offset/globalVar.iEEG_rate;
    pdio_dur= pdio_offset - pdio_onset;
    IpdioI = [pdio_onset(2:end)-pdio_offset(1:end-1) 0];
    
    stim_ind= find(pdio_dur>.01);
    stim_ind(1:12)=[]; %to skip misc. diode
    
    
    % %remove onset flash
    pdio_onset = pdio_onset(stim_ind); % Add in calculia production the finisef to experiment to have 12 pulses
    pdio_offset = pdio_offset(stim_ind); %
    clear n_initpulse_onset; clear n_initpulse_offset;
    
    %get onsets from diode
    
    stim_offset= [pdio_offset(isi_ind) pdio_offset(end)];
    stim_onset= [pdio_onset(isi_ind) pdio_onset(end)];
    % stim_onset = [stim_onset(1:115) stim_onset(117:end)];
    % stim_offset = [stim_offset(1:115) stim_offset(117:end)];
    
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
    if ismember('nstim',colnames) % for cases where each trial has diff # of stim
        ntrials = size(trialinfo,1);
        all_stim_onset = nan(ntrials,max(trialinfo.nstim));
        
        counter = 1;
        for ti = 1:ntrials
            inds = counter:(counter+trialinfo.nstim(ti)-1);
            all_stim_onset(ti,1:trialinfo.nstim(ti))=stim_onset(inds);
            counter = counter+trialinfo.nstim(ti);
        end
    else
        
        all_stim_onset = reshape(stim_onset,n_stim_per_trial,length(stim_onset)/n_stim_per_trial)';
    end
    % the second input is project dependent
    %reshape onsets to account for the number of events in each trial
    
    %%
    % Plot photodiode segmented data
    figureDim = [0 0 1 1];
    figure('units', 'normalized', 'outerposition', figureDim)
    subplot(2,3,1:3)
    hold on
    plot(pdio)
    
    % Event onset
    plot(stim_onset*globalVar.Pdio_rate,0.9*ones(length(stim_onset),1),'r*');
    
    
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
    plot(df);
    title('Diff. behavior diode (exp)');
    xlabel('Trial number');
    ylabel('Time (ms)');
    subplot(2,3,6)
    hist(df)
    title('Diff. behavior diode (hist)');
    xlabel('Time (ms)');
    ylabel('Count');
    
    %flag large difference
    if ~all(abs(df)<.1)
        disp('behavioral data and photodiod mismatch'),return
    end
    
    
    %% Updating the events with onsets
    trialinfo.allonsets(event_trials,:) = all_stim_onset;
    trialinfo.RT_lock = trialinfo.RT + trialinfo.allonsets(:,end);
    %     trialinfo.RT_lock = K.slist.onset_prod/(globalVar.Pdio_rate);
    % update that
    
    % Include the rest events FIX THIS, REST EVENT ONSET SEEMS ODD!!!
    %     if ~isempty(rest_trials)
    %         for i = 1:length(rest_trials)
    %             onset_rest(i,1) = trialinfo.allonsets(rest_trials(i)-1,end) + trialinfo.RT(rest_trials(i)-1) + ISI?;
    %         end
    %     else
    %     end
    %     trialinfo.allonsets(rest_trials,:) = onset_rest;
    
    
    %% Save trialinfo
    fn= sprintf('%s/trialinfo_%s.mat',globalVar.result_dir,bn);
    save(fn, 'trialinfo');
    
end


end



% 
%     switch project_name
%         case 'MMR'
%             n_stim_per_trial = 1;
%             n_initpulse_onset = 12;
%             n_initpulse_offset = 12;
%         case 'Memoria'
%             n_stim_per_trial = 5;
%             n_initpulse_onset = 12;
%             n_initpulse_offset = 12;
%         case 'Calculia'
%             n_stim_per_trial = 5;
%             n_initpulse_onset = 12;
%             n_initpulse_offset = 12;
%         case 'Calculia_production'
%             n_stim_per_trial = 3;
%             n_initpulse_onset = 0;
%             n_initpulse_offset = 12; % maybe change to 12
%     end
%     
%     % Correct for different initiation TTL pulses
%     switch bn
%         case 'S14_64_SP_02'
%             n_initpulse_onset = 13;
%             n_initpulse_offset = 14;
%     end
%     