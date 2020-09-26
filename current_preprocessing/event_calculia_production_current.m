function EventIdentifier (sbj_name, project_name, block_name, dirs)
%% Globar Variable elements
sbj_name= 'S18_124';
project_name= 'Calculia_production';
block_name= 'E18-309_0024';

initialize_dirs;



load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_name));
globalVar.psych_dir = sprintf('%s/psychData/%s/%s',comp_root,sbj_name,block_name);
globalVar.result_dir = sprintf('%s/Results/%s/%s/%s',comp_root,project_name,sbj_name,block_name);
%%% FIX ALL THE PATHS!!!!!!!


sbj_name= globalVar.sbj_name;


iEEG_rate=globalVar.iEEG_rate;

%% Reading PsychData BAHAVIORAL DATA
soda_name = dir(fullfile(globalVar.psych_dir, '*.mat'));
K= load([globalVar.psych_dir '/' soda_name.name]); % block 55 %% FIND FILE IN THE FOLDER AUTO


lsi= length(K.theData);

SOT= nan(1,lsi);
sbj_resp= nan(1,lsi);
RT = [K.theData.RT];
for si= 1:lsi %
    if (~isempty(K.theData(si).flip))
        SOT(si)= K.theData(si).flip.StimulusOnsetTime; %% time between 
        if ~isnan(str2num(K.theData(si).keys))
            sbj_resp(si)= str2num(K.theData(si).keys(1));
        else
            sbj_resp(si)= NaN;
        end
    end
end
%
%return
%% reading analog channel from neuralData directory
load(sprintf('%s/Pdio%s_01.mat',globalVar.data_dir,block_name));

%% varout is anlg (single percision)
downRatio= round(globalVar.Pdio_rate/iEEG_rate); 
pdio= decimate(double(anlg),downRatio)*-1; % down sample to the iEEG rate and make it positive
clear anlg

pdio = pdio/max(pdio)*2;


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

% pdio_onset(1:12)=[]; % Add in calculia production the finisef to experiment to have 12 pulses 
% pdio_offset(1:12)=[]; % 


%get osnets from diode
pdio_dur= pdio_offset - pdio_onset;
IpdioI= [pdio_onset(2:end)-pdio_offset(1:end-1) 0];
isi_ind = find(IpdioI > 0.2);

stim_offset= [pdio_offset(isi_ind) pdio_offset(end)];
stim_onset= [pdio_onset(isi_ind) pdio_onset(end)];
% stim_onset = [stim_onset(1:115) stim_onset(117:end)];
% stim_offset = [stim_offset(1:115) stim_offset(117:end)];

stim_dur= stim_offset - stim_onset;

%Ploting to check marks for STIM
marks_on= 0.5*ones(1,length(stim_onset));
marks_off= 0.4*ones(1,length(stim_offset));
figure, plot(pdio),hold on, 
plot(stim_onset*iEEG_rate,marks_on,'r*');hold on
plot(stim_offset*iEEG_rate,marks_off,'g*');


% return
%%
%Get trials, insturuction onsets
n_stim_per_trial = 3;
all_stim_onset = NaN*ones(lsi,n_stim_per_trial); %% the second input is project dependent 
rest_onset = [];
rest_offset = [];


% SIMPLIFY THAT AND MAKE IT PROJECT DEPENDENT

counter = 1;
for ti = 1:lsi
    end_counter = min(counter+n_stim_per_trial,length(stim_onset));
    numinds = end_counter-counter;
    all_stim_onset(ti,1:numinds) = stim_onset(counter:counter+numinds-1);
    counter = counter + n_stim_per_trial;
end

%%% WHY IS THE LAST EVETN OF THE LAST TRIAL NAN???? Doesnt matter much
%%% cause we are using only the 1 column.



%plot each presentation in trial
figure, plot(pdio,'k'),hold on, 

plot(all_stim_onset(:,1)*iEEG_rate,0.9*ones(lsi,1),'b*');
plot(all_stim_onset(:,2)*iEEG_rate,0.7*ones(lsi,1),'y*');
plot(all_stim_onset(:,3)*iEEG_rate,0.5*ones(lsi,1),'c*');


return

%% Start-end experiment times - check why???
%add 500ms either side to avoid window errors during epoching later on
globalVar.exp_start_point = stim_onset(1)-0.5; %-500ms
globalVar.exp_end_point = stim_offset(end)+0.5; %+500ms

%save updated globals
fn=sprintf('%s/originalData/%s/global_%s_%s_%s.mat',data_root,sbj_name,project_name,sbj_name,block_name);
save(fn,'globalVar');
close all
return

%% Comparing photodiod with behavioral data
%for just the first stimulus of each trial

df_SOT= diff(SOT);
% df_stim_onset= diff(stim_onset_fifth); %fifth? why?
df_stim_onset = diff(all_stim_onset(:,1))';
%plot overlay
figure, plot(df_SOT,'o','MarkerSize',8,'LineWidth',3),hold on, plot(df_stim_onset,'r*')
df= df_SOT - df_stim_onset;

%plot diffs, across experiment and histogram
figure
    subplot(1,2,1)
    plot(df), ylim([-.005 .005]);
        title('Diff. behavior diode (exp)');
        xlabel('Trial number');
        ylabel('Time (ms)');
    subplot(1,2,2)
    hist(df), xlim([-.005 .005])
        title('Diff. behavior diode (hist)');
        xlabel('Time (ms)');
        ylabel('Count');
        
%flag large difference
if ~all(abs(df)<.1)
   disp('behavioral data and photodiod mismatch'),return
end

return

%% events and categories from psychtoolbox information
categNames1 = unique(K.slist.conds_addsub);          

for i = 1:length(K.slist.conds_addsub_min)
    for ii = 1:length(categNames1)
        if strcmp(categNames1{ii}, K.slist.conds_addsub{i})
            conds2(:,i) = ii;
        else
        end
    end
end

for ti = 1:lsi
    subj_resp{ti} = K.theData(ti).keys(1);
end


for ci=1:length(categNames1)
    cat = categNames1{ci};
    events.categories(ci).name= sprintf('%s',categNames1{ci});
    events.categories(ci).categNum= ci;
    events.categories(ci).numEvents= sum(conds2==ci);
    events.categories(ci).start= all_stim_onset(find(conds2==ci),1);
    events.categories(ci).allonset= all_stim_onset(find(conds2==ci),:);
    events.categories(ci).stimNum= find(conds2==ci);
    events.categories(ci).wlist= K.slist.problem(find(conds2==ci));
    events.categories(ci).RT= RT(find(conds2==ci));
    events.categories(ci).sbj_resp= sbj_resp(find(conds2==ci));
    events.categories(ci).duration = ((events.categories(ci).allonset(:,n_stim_per_trial)-events.categories(ci).allonset(:,1))'+events.categories(ci).RT)';
end

categNames = categNames1;

fn= sprintf('%s/events_%s.mat',globalVar.result_dir,block_name);
save(fn,'events','categNames');


%% making a saving directory

fn= sprintf('%s/events_%s.mat',globalVar.result_dir,block_name);
save(fn,'events','categNames');

