function event_numcomparison_current(sbj_name, project_name, block_names, dirs, pdio_chan)

for i = 1:length(block_names)
    %% Load globalVar
    bn = block_names{i};
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    iEEG_rate=globalVar.iEEG_rate;
    
    % Load trigger channel
    load(sprintf('%s/Pdio%s_%.2d.mat',globalVar.originalData, bn, pdio_chan)); % going to be present in the globalVar

    
    
    % Load soda
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]); 
    
    % Ajust exceptions for specific subjects
    n_initpulse_onset = 12;
    if strcmp(sbj_name, 'S18_127') && strcmp(bn, 'E18-706_0039')
        K.theData = K.theData(3:end);
    elseif strcmp(sbj_name, 'G18_24') && strcmp(bn, 'G024_comparison_01')
        n_initpulse_onset = 10;
    elseif strcmp(sbj_name, 'G18_24') && strcmp(bn, 'G024_comparison_03')
        n_initpulse_onset = 8;
     
        
    end
    
    
    % Load trialinfo
    load([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');

    
    % Load stim list
%     load([globalVar.psych_dir '/Run' num2str(i)  '/permutedTrials.mat']);
    
    
    %% Reading PsychData BAHAVIORAL DATA
    lsi= length(K.theData);    
    
    %% varout is anlg (single percision)
    downRatio= round(globalVar.Pdio_rate/iEEG_rate);
    pdio= decimate(double(anlg),downRatio); % down sample to the iEEG rate
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
    
    pdio_onset(1:n_initpulse_onset)=[]; %
    pdio_offset(1:n_initpulse_onset)=[]; %
    
    
    %get osnets from diode
    pdio_dur= pdio_offset - pdio_onset;
    IpdioI= [pdio_onset(2:end)-pdio_offset(1:end-1) 0];
    isi_ind = find(IpdioI > 0.2);
    
    stim_offset= [pdio_offset(isi_ind) pdio_offset(end)];
    stim_onset= [pdio_onset(isi_ind) pdio_onset(end)];
    
    stim_dur= stim_offset - stim_onset;
    
    %Ploting to check marks for STIM
    marks_on= 0.5*ones(1,length(stim_onset));
    marks_off= 0.4*ones(1,length(stim_offset));
    figure, plot(pdio),hold on,
    plot(stim_onset*iEEG_rate,marks_on,'r*');hold on
    plot(stim_offset*iEEG_rate,marks_off,'g*');
    
    
    
    stim_offset= [pdio_offset(isi_ind) pdio_offset(end)];
    stim_onset= [pdio_onset(isi_ind) pdio_onset(end)];
    instr_onset = stim_onset(1:33:end);
    stim_onset(1:33:end)=[];
    stim_offset(1:33:end)=[];
    stim1_onset = stim_onset(1:2:end);
    stim2_onset = stim_onset(2:2:end);
    
    if strcmp(sbj_name, 'S18_127') && strcmp(bn, 'E18-706_0039')
        stim2_onset(end+1) = nan;
    end
    
    
    % counter = 1;
    % while counter <= length(stim_onset)
    %     stim1_onset = [stim1_onset stim_onset(counter)];
    %     counter = counter+1;
    %     if (stim_onset(counter)-stim_onset(counter-1)>1.2 && stim_onset(counter)-stim_onset(counter-1)<1.4)
    %         stim2_onset = [stim2_onset stim_onset(counter)];
    %         counter=counter+1;
    %     else
    %         stim2_onset = [stim2_onset stim_onset(counter-1)+1.27];
    %     end
    % end
    
    all_stim_onset(:,1)=stim1_onset;
    all_stim_onset(:,2)=stim2_onset;
  
    %plot each presentation in trial
    figure, plot(pdio,'k'),hold on,
    
    plot(instr_onset*iEEG_rate,0.9*ones(length(instr_onset),1),'m*');
    plot(all_stim_onset(:,1)*iEEG_rate,0.7*ones(lsi,1),'b*');
    plot(all_stim_onset(:,2)*iEEG_rate,0.5*ones(lsi,1),'y*');
    
    % %% Start-end experiment times
    % %add 500ms either side to avoid window errors during epoching later on
    % globalVar.exp_start_point = stim_onset(1)-0.5; %-500ms
    % globalVar.exp_end_point = stim_offset(end)+0.5; %+500ms
    %
    % %save updated globals
    % fn=sprintf('%s/originalData/%s/global_%s_%s_%s.mat',data_root,sbj_name,project_name,sbj_name,block_name);
    % save(fn,'globalVar');
    % close all
    % return
    
       
    
    %% Comparing photodiod with behavioral data
    %for just the first stimulus of each trial
    
    df_SOT= diff(trialinfo.StimulusOnsetTime');
    % df_stim_onset= diff(stim_onset_fifth); %fifth? why?
    df_stim_onset = diff(all_stim_onset(:,1))';
    %plot overlay
    figure, plot(df_SOT,'o','MarkerSize',8,'LineWidth',3),hold on, plot(df_stim_onset,'r*')
    df= df_SOT - df_stim_onset;
    
    %plot diffs, across experiment and histogram
    figure
    subplot(1,2,1)
    plot(df), ylim([-.05 .05]);
    title('Diff. behavior diode (exp)');
    xlabel('Trial number');
    ylabel('Time (s)');
    subplot(1,2,2)
    hist(df), xlim([-.05 .05])
    title('Diff. behavior diode (hist)');
    xlabel('Time (s)');
    ylabel('Count');
    
%     %flag large difference
%     if ~all(abs(df)<.1)
%         disp('behavioral data and photodiod mismatch'),return
%     end
    
    
    %% Plug it into trialinfo
    trialinfo.allonsets = all_stim_onset;
    trialinfo.RT_lock = trialinfo.RT + trialinfo.allonsets(:,end);
    
    %% Save trialinfo
    fn= sprintf('%s/trialinfo_%s.mat',globalVar.psych_dir,bn);
    save(fn, 'trialinfo');   
    
end




