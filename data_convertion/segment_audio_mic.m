%% Segment and play answers MMR EBS !!!
% 
clear all
sbj_name = 'S18_126';
project_name = 'Calculia_production';
block_names = BlockBySubj(sbj_name,project_name);
bn = 1;
load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_names{bn}),'globalVar');
load(sprintf('/Volumes/LBCN8T/Stanford/data/neuralData/originalData/%s/%s/Pdio%s_02.mat',sbj_name, block_names{bn}, block_names{bn}))

soda_name = dir(fullfile(globalVar.psych_dir, '*.mat'));
load([globalVar.psych_dir '/' soda_name.name], 'slist'); % block 55 %% FIND FILE IN THE FOLDER AUTO

 

%% Normalize signal
normic = anlg./(max(abs(anlg)));

%% Define threshold and silence
thrh = 1.1; % this probably depends on the microfone and session
min_silence = 20000; % this depends on the task - it should be around 3 seconds 

%% Envelope
samples = 1000;
[up,lo] = envelope(normic,samples,'rms');

%% Start and end points
% find cut point start
cut_point1 = diff(([0 up]-[0 lo])<thrh);
cut_point1(cut_point1~=-1) = 0;

% find cut point end
cut_point2 = diff(([up 0]-[lo 0])<thrh);
cut_point2(cut_point2~=1) = 0;

% combine cutpoints
cutpoints = abs(cut_point1) + cut_point2; 

%% Count the number of regions
ct_fill = ~bwareaopen(~cutpoints, min_silence); % remove some intermediate zeros
[L, numRegions] = bwlabel(ct_fill); % count regions of 1's
numRegions

%% Calculate onsets
ct_fill_0 = (ct_fill~=0);
ct_fill_d = diff(ct_fill_0);
start = find([ct_fill_0(1) ct_fill_d]==1)'; % Start index of each group
finish = find([ct_fill_d -ct_fill_0(end)]==-1)'; % Last index of each group

count = length(start);
onset_offset = cell(count,1);
for i = 1:count
    onset_offset{i} = [ start(i) finish(i)] ;
end

%% Visually inspect if all the events were picked up
plot(anlg)
hold on
for i = 1:length(onset_offset)
    plot(onset_offset{i}(1):onset_offset{i}(2),zeros(length(anlg(onset_offset{i}(1):onset_offset{i}(2))),1), 'LineWidth', 50, 'Color', 'red')
    text(onset_offset{i}(1),0, num2str(i), 'FontSize', 30)
end
% if needed, correct timing manually
[xi,~] = getpts
t = 47; 
start(t) = floor(xi(1))
finish(t) = floor(xi(2))



%% Play
pause(2)
for i = 1:length(onset_offset)
    soundsc(anlg(onset_offset{i}(1)-5000:onset_offset{i}(2)+5000), 10000); % -+5000 just to hear better
    i
    pause(3)
end
i = 75
soundsc(anlg(onset_offset{i}(1):onset_offset{i}(2)+10000), 10000); % -+5000 just to hear better



%% Manually type the responses

%%% BE CAREFUL DO NOT RUN THIS LINE TWICE %%%
prod_result = nan(length(onset_offset),1);
%%% BE CAREFUL DO NOT RUN THIS LINE TWICE %%%

no_nan_resp = find(~isnan(prod_result)); length(no_nan_resp)
prod_result = prod_result(no_nan_resp,1); % take only the first col
start = start(no_nan_resp);
finish = finish(no_nan_resp);

% Add some additional variables
slist.prod_result = prod_result;
slist.accuracy = (slist.result==slist.prod_result);
slist.dist_from_result = (slist.result-slist.prod_result);
slist.onset_prod = start;
slist.offset_prod = finish;
slist.trial_number = [1:64]';

%% Additional checking
onset_offset = onset_offset(no_nan_resp);
v = 35
soundsc(anlg(onset_offset{v}(1)-5000:onset_offset{v}(2)+5000), 10000); % -+5000 just to hear better
slist.trial_number = []
%% Save 
save([globalVar.psych_dir '/' subject_ID '_' blocks{bn} '_slist.mat'], 'slist'); % block 55 %% FIND FILE IN THE FOLDER AUTO

