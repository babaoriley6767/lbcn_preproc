clear

%% Globar Variable elements
sbj_name= 'S14_64_SP';
project_name= 'AnimalLoc';
block_name= 'S14_64_SP_09';

initialize_dirs;
load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',data_root,sbj_name,project_name,sbj_name,block_name));
globalVar.psych_dir = sprintf('%s/analysis_ECOG/psychData/%s/%s',comp_root,sbj_name,block_name);
sbj_name= globalVar.sbj_name;

iEEG_rate=globalVar.iEEG_rate;

%% Reading PsychData BAHAVIORAL DATA

K= load(sprintf('%s/sodata.S14_64.01.04.2014.10.54.mat',globalVar.psych_dir)); % 03

lsi= length(K.theData);
SOT= zeros(1,lsi);
%sbj_resp= NaN*ones(1,lsi);
for si= 1:lsi
    SOT(si)= K.theData(si).flip.StimulusOnsetTime;
end

%% reading analog channel from neuralData directory
load(sprintf('%s/Pdio%s_02.mat',globalVar.data_dir,block_name));

%% varout is anlg (single percision)
downRatio= round(globalVar.Pdio_rate/iEEG_rate); 
pdio= decimate(double(anlg),downRatio); % down sample to the iEEG rate
clear anlg

pdio = pdio/max(pdio);

%Ploting to check marks
%  t= (1:length(pdio))/iEEG_rate;
%  figure,plot(t,pdio);
%  return

%% Thresholding the signal
%pdio = pdio(14*iEEG_rate:end); %To chop diode so offset is correct
%t = 1:length(pdio);
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

stim_ind= find(pdio_dur>.02);
stim_ind(1:12)=[]; %to skip misc. diode
% stim_ind(12)=NaN; %to skip misc. diode
% stim_ind(end)=[];
stim_onset= pdio_onset(stim_ind);
stim_offset= pdio_offset(stim_ind);
stim_dur= stim_offset - stim_onset;
rsp_onset= pdio_offset(stim_ind);

rest_ind= find(IpdioI>5 & IpdioI<5.3);
rest_onset= pdio_offset(rest_ind);
rest_offset= pdio_onset(rest_ind+1);
rest_dur= rest_offset - rest_onset;

%Ploting to check marks 
marks_stim= 0.5*ones(1,length(stim_onset));
marks_rsp= 0.5*ones(1,length(rsp_onset));
figure, plot(pdio),hold on, 
plot(stim_onset*iEEG_rate,marks_stim,'r*');hold on
plot(rsp_onset*iEEG_rate,marks_rsp,'g*');
return

[C,IA,IB] = intersect(rest_offset,stim_onset);
if length(IB)<length(rest_onset), error('check rest_onset'), end

%% Comparing photodiod with behavioral data
df_SOT= diff(SOT);
df_stim_onset= diff(stim_onset);
figure, plot(df_SOT,'o','MarkerSize',8,'LineWidth',3),hold on, plot(df_stim_onset,'r*')
df= df_SOT - df_stim_onset;
%figure, hist(df)
if ~all(abs(df)<.1)
   disp('behavioral data and photodiod mismatch')
   find(abs(df)>.1)
   return
end


%% events and categories from psychtoolbox information
% numCateg= 9;
wlist= K.stimlist;
cond= [K.conds]';
% rt=zeros(1,length(K.theData));

% stimNum= 1:length(wlist);
%categNames= {'internal-self','internal-other','internal-dist-other',...
%             'external-self','external-other','external-Dis-other',...
%             'math','episodic','rest'};

categNames= {'MammalFace','MammalBody','BirdFace','BirdBody','FishFace','FishBody','HumanFace','HumanBody','Object','Place','Limb'};
stimNum= [1:length(stim_onset)];

for ci=1:length(categNames)
    events.categories(ci).name= categNames{ci};
    events.categories(ci).categNum= ci;
    events.categories(ci).numEvents= sum(cond==ci);
    events.categories(ci).start= stim_onset(find(cond==ci));
    events.categories(ci).duration= stim_dur(find(cond==ci));
    events.categories(ci).stimNum= stimNum(find(cond==ci));
    events.categories(ci).wlist= wlist(find(cond==ci));
end


%% Comparing reaction times to stimuli durations
% df= abs(stim_dur - rt);
% if ~all(abs(df)<.2)
%    disp('Reaction times and photodiod mismatch\n'),
%    fprintf('trials did not match:\n %d\n',find(abs(df)>.2))
%    return
% end

%% making a saving directory

fn= sprintf('%s/events_%s.mat',globalVar.result_dir,block_name);
save(fn,'events');

