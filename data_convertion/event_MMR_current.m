clear

%% Globar Variable elements
sbj_name= 'S18_124';
project_name= 'MMR';
block_name= 'E18-309-0005';

initialize_dirs;
load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_names{1}));
globalVar.psych_dir = sprintf('%s/analysis_ECoG/psychData/%s/%s',comp_root,sbj_name,block_name);
sbj_name= globalVar.sbj_name;

iEEG_rate=globalVar.iEEG_rate;

%% Reading PsychData BAHAVIORAL DATA

% K = load(sprintf('%s/sodata.S18_124.18.04.2018.13.15.mat',globalVar.psych_dir)); % 
K = load('sodata.RB-1.05.12.2010.15.17.mat')

lsi= length(K.theData);
SOT= zeros(1,lsi);
sbj_resp= NaN*ones(1,lsi);
good_pdio_trials = 1:lsi;

for si= 1:lsi
    SOT(si)= K.theData(si).flip.StimulusOnsetTime;
    if ~isnan(str2num(K.theData(si).keys(1)))
       sbj_resp(si)= str2num(K.theData(si).keys(1));
    else
       sbj_resp(si)= NaN;
    end
end

SOT = SOT(good_pdio_trials);
sbj_resp = sbj_resp(good_pdio_trials);

%% reading analog channel from neuralData directory
load(sprintf('%s/OriginalData/%s/%s/Pdio%s_02.mat',dirs.data_root,sbj_name,block_names{1},block_names{1}));

%% varout is anlg (single percision)
downRatio= round(globalVar.Pdio_rate/iEEG_rate); 
pdio= decimate(double(anlg),downRatio); % down sample to the iEEG rate
clear anlg

pdio = pdio/max(pdio);

%Ploting to check marks
%  t= (1:length(pdio))/iEEG_rate;
%  figure,plot(t,pdio);
%  return

df_SOT= diff(SOT);
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

stim_ind= find(pdio_dur>.01);
stim_ind(1:12)=[]; %to skip misc. diode
% stim_ind(end) = [];

% stim_onset= [pdio_onset(stim_ind(1:34)) NaN*ones(1,19) pdio_onset(stim_ind(36:end))];
% stim_offset= [pdio_offset(stim_ind(1:34)) NaN*ones(1,19) pdio_offset(stim_ind(36:end))];
% stim_onset = [pdio_onset(stim_ind(1:16)),NaN,pdio_onset(stim_ind(17:end))];
% stim_offset = [pdio_offset(stim_ind(1:16)),NaN,pdio_offset(stim_ind(17:end))];
% stim_onset(17)=stim_onset(16)+df_SOT(16);
% stim_onset(18)=stim_onset(17)+df_SOT(17);
% stim_offset(17)=stim_offset(16)+df_SOT(16);
% stim_offset(18)=stim_offset(17)+df_SOT(17);
stim_onset= pdio_onset(stim_ind);
stim_offset= pdio_offset(stim_ind);
stim_dur= stim_offset - stim_onset;
rsp_onset= pdio_offset(stim_ind);

% rest_ind= find(IpdioI>5 & IpdioI<5.3);
rest_ind= find(IpdioI>4.5 & IpdioI<10.5);
rest_onset= pdio_offset(rest_ind);
rest_offset= pdio_onset(rest_ind+1);
rest_dur= rest_offset - rest_onset;

%Ploting to check marks 
marks_stim= 0.6*ones(1,length(stim_onset));
marks_rsp= 0.4*ones(1,length(stim_offset));
time = (1:length(pdio))/globalVar.Pdio_rate;
figure, plot(time,pdio),hold on, 
% plot(stim_onset*iEEG_rate,marks_stim,'r*');hold on
% plot(rsp_onset*iEEG_rate,marks_rsp,'g*');
plot(stim_onset,marks_stim,'r*');hold on
plot(stim_offset,marks_rsp,'g*');
return
%%
[C,IA,IB] = intersect(rest_offset,stim_onset);
if length(IB)<length(rest_onset), error('check rest_onset'), end
return
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
wlist= K.wlist;
cond= [K.conds(good_pdio_trials)]';
% cond = K.conds;
% rt=zeros(1,length(K.theData));
rt= NaN*ones(1,length(K.theData));
for ii=1:length(K.theData)
    % rt(ii)=K.theData(ii).RT;
    % tmp= K.theData(ii).RT;
    rt(ii)=K.theData(ii).RT;
end

% stimNum= 1:length(wlist);

if strcmp(project_name,'UCLA')
    categNames= {'internal-self','internal-other','internal-dist-other',...
        'external-self','external-other','external-Dis-other',...
        'math','episodic','rest'};
else
    categNames= {'self-internal','other','self-external','autobio','math','rest','fact'};
end
stimNum= [1:length(stim_onset)];

for ci=1:length(categNames)
    cat = categNames(ci);
    if ~strcmp(cat,'rest')
        events.categories(ci).name= sprintf('%s',categNames{ci});
        events.categories(ci).categNum= ci;
        events.categories(ci).numEvents= sum(cond==ci);
        events.categories(ci).start= stim_onset(find(cond==ci));
        events.categories(ci).duration= stim_dur(find(cond==ci));
        events.categories(ci).stimNum= stimNum(find(cond==ci));
        events.categories(ci).wlist= wlist(find(cond==ci));
        events.categories(ci).RT= rt(find(cond==ci));
        events.categories(ci).sbj_resp= sbj_resp(find(cond==ci));
        
        if strcmp(cat,'math')
            correct= NaN*ones(1,sum(cond==ci));
            wlist_tmp= wlist(find(cond==ci));
            for ii=1:length(wlist_tmp)
                tmp = wlist_tmp(ii);
                tmp2= tmp{1};
                pl= regexp(tmp2,'+');
                el= regexp(tmp2,'=');
                if ( str2double(tmp2(1:(pl-1))) + str2double(tmp2((pl+1):(el-1))) == str2double(tmp2((el+1):end)))
                    correct(ii)=1;
                else
                    correct(ii)=2;
                end
            end
            events.categories(ci).correct= correct;
            
%         elseif strcmp(cat,'fact')
%             events.categories(ci).correct=[K.wlistInfo(events.categories(ci).stimNum).correct];
%             events.categories(ci).correct(events.categories(ci).correct==0)=2;
        else
            events.categories(ci).correct=[];
        end
               
    else
        events.categories(ci).name= sprintf('%s',categNames{ci});
        events.categories(ci).categNum= ci;
        events.categories(ci).numEvents= sum(length(rest_onset));
        events.categories(ci).start= rest_onset + 0.2;
        events.categories(ci).duration= rest_dur - 0.2;
        events.categories(ci).wlist= {'+'};
        events.categories(ci).RT=[];
        events.categories(ci).subcat=[];
    end
end


%% Comparing reaction times to stimuli durations
% df= abs(stim_dur - rt);
% if ~all(abs(df)<.2)
%    disp('Reaction times and photodiod mismatch\n'),
%    fprintf('trials did not match:\n %d\n',find(abs(df)>.2))
%    return
% end

%% making a saving directory

fn= sprintf('%s/%s/%s/%s/events_%s.mat',results_root,project_name,sbj_name,block_name,block_name);
save(fn,'events');

