clear all; close all; clc;

%% Globar Variable elements
sbj_name= 'S15_89b_JQ';
project_name= 'calculia';
block_name= 'E17-152_0030';
block_type = 'passive'; %'passive' or 'active'

initialize_dirs;

load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));

iEEG_rate=globalVar.iEEG_rate;

%% Reading PsychData BAHAVIORAL DATA
soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
K = load([globalVar.psych_dir '/' soda_name.name]);
    
    
lsi= length(K.theData);
goodbehavtrials = 1:lsi;

SOT= NaN*ones(1,lsi);
sbj_resp= NaN*ones(1,lsi);
RT = NaN*ones(1,lsi);
if (strcmp(block_type,'active'))
    for si= 1:lsi
        if ~isempty(K.theData(si).keys)
            sbj_resp(si)= str2num(K.theData(si).keys(1));
            SOT(si)= K.theData(si).flip.StimulusOnsetTime;
            RT(si)=K.theData(si).RT;
        end
    end
else
    for si= 1:lsi
        SOT(si)= K.theData(si).flip.StimulusOnsetTime;
    end
end

SOT = SOT(goodbehavtrials);
sbj_resp = sbj_resp(goodbehavtrials);
RT = RT(goodbehavtrials);
% if (strcmp(block_type,'active'))
%     for si= 2:lsi;
%         if ~isempty(K.theData(si).keys)
%             sbj_resp(si-1)= str2num(K.theData(si).keys(1));
%             SOT(si-1)= K.theData(si).flip.StimulusOnsetTime;
%             RT(si-1)=K.theData(si).RT;
%         end
%     end
% else
%     for si= 1:lsi;
%         SOT(si)= K.theData(si).flip.StimulusOnsetTime;
%     end
% end

%% reading analog channel from neuralData directory
load(sprintf('%s/Pdio%s_%.2d.mat',globalVar.originalData, bn, pdiochan));

%% varout is anlg (single percision)
downRatio= round(globalVar.Pdio_rate/iEEG_rate);
pdio= decimate(double(anlg),downRatio); % down sample to the iEEG rate
pdio = pdio/max(pdio);
clear anlg

%% Thresholding the signal
ind_above= pdio >0.5;
ind_df= diff(ind_above);
clear ind_above
onset= find(ind_df==1);
offset= find(ind_df==-1);
clear ind_df
pdio_onset= onset/iEEG_rate;
pdio_offset= offset/iEEG_rate;
% %remove onset flash
% 
pdio_onset(1:12)=[];
pdio_offset(1:12)=[];
% pdio_onset(1:8)=[];
% pdio_offset(1:8)=[];

%get osnets from diode
pdio_dur= pdio_offset - pdio_onset;
IpdioI= [pdio_onset(2:end)- pdio_offset(1:end-1) 0];
isi_ind = find(IpdioI > 0.3);

stim_offset= [pdio_offset(isi_ind) pdio_offset(end)];
stim_onset= [pdio_onset(isi_ind) pdio_onset(end)];
% stim_onset = [stim_onset(1:148) NaN stim_onset(149:end)];
% stim_offset = [stim_offset(1:148) NaN stim_offset(149:end)];

stim_dur= stim_offset - stim_onset;

%Ploting to check marks for STIM
marks_on= 0.6*ones(1,length(stim_onset));
marks_off= 0.4*ones(1,length(stim_offset));
figure, plot(pdio),hold on,
plot(stim_onset*iEEG_rate,marks_on,'r*');hold on
plot(stim_offset*iEEG_rate,marks_off,'g*');


%%
%Get trials, insturuction onsets

%get each stim onset (5 stim per trial)
stim_onset_first = stim_onset(1:5:end);%(1:5:end)
stim_onset_second = stim_onset(2:5:end);
stim_onset_third = stim_onset(3:5:end);
stim_onset_fourth = stim_onset(4:5:end);
stim_onset_fifth = stim_onset(5:5:end);

%check with plot (instruction and stim onsets),
marks_first= 0.9*ones(1,length(stim_onset_first));
marks_second= 0.7*ones(1,length(stim_onset_second));
marks_third= 0.5*ones(1,length(stim_onset_third));
marks_fourth= 0.3*ones(1,length(stim_onset_fourth));
marks_fifth= 0.1*ones(1,length(stim_onset_fifth));

%plot each presentation in trial
figure, plot(pdio,'k'),hold on,

plot(stim_onset_first*iEEG_rate,marks_first,'b*');
plot(stim_onset_second*iEEG_rate,marks_second,'y*');
plot(stim_onset_fourth*iEEG_rate,marks_fourth,'m*');
plot(stim_onset_third*iEEG_rate,marks_third,'c*');
plot(stim_onset_fifth*iEEG_rate,marks_fifth,'g*');

%% Start-end experiment times
%add 500ms either side to avoid window errors during epoching later on
globalVar.exp_start_point = stim_onset(1)-0.5; %-500ms
globalVar.exp_end_point = stim_offset(end)+0.5; %+500ms


%% Comparing photodiod with behavioral data
%for just the first stimulus of each trial
% pdio([1:5 47:50 57:59 66:71 78:88 120])=NaN; % OD 05
% SOT([9:18 20 22 23 25:31 38:41 48])=[]; % OD 05
% K.conds([9:18 20 22 23 25:31 38:41 48])=[];

df_SOT= diff(SOT);
df_stim_onset= diff(stim_onset_fifth); %fifth? why?
ngoodtrials = length(stim_onset_fifth);
%plot overlay
figure
plot(df_SOT(1:ngoodtrials-1),'o','MarkerSize',8,'LineWidth',3)
hold on
plot(df_stim_onset(1:ngoodtrials-1),'r*')
df= df_SOT(1:ngoodtrials-1) - df_stim_onset(1:ngoodtrials-1);

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

%flag large difference
if ~all(abs(df)<.1)
    disp('behavioral data and photodiod mismatch'),return
end


%group all, rearrange for trials (trials as rows, with 5 stimuli as columns)
% lsi=23;
all_stim_onset = [];
for ti = 1:ngoodtrials; %23 for OD5, lsi for others
    all_stim_onset(ti,1) = stim_onset_first(ti);
    all_stim_onset(ti,2) = stim_onset_second(ti);
    all_stim_onset(ti,3) = stim_onset_third(ti);
    all_stim_onset(ti,4) = stim_onset_fourth(ti);
    all_stim_onset(ti,5) = stim_onset_fifth(ti);
end



%% making a saving directory

fn= sprintf('%s/%s/%s/%s/events_old_%s.mat',results_root,project_name,sbj_name,block_name,block_name);
save(fn,'events');

