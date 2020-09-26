close all
load cdcol.mat
%% compute behavioral metrics across trials (sliding window)

%window size (i.e. # of consecutive trials) across which to compute behav, PLV
% wintrials = 'blocks'; % number of trials, or 'blocks'
% wintrials = 100;
% nmove = 25; 
% noverlap = wintrials-nmove;
freq_ind = 9;
e1 = 'LRSC9';
e2 = 'LRSC1';
%%

block_names = unique(PLV.trialinfo.block);
nblocks = length(block_names);
nfreqs = length(PLV.freqs);

RTnorm = cell(1,nblocks);
PLVblock = cell(1,nblocks);

figure('Position',[200 200 1000 400])
for bi = 1:nblocks
    trials = find(strcmp(PLV.trialinfo.block,block_names{bi}));
    ntrials = length(trials);
    trialinfo_tmp = PLV.trialinfo(trials,:);
    trialinfo_tmp.RT(~strcmp(trialinfo_tmp.respType,'CC'))=NaN; % only consider RTs during correct city responses
    PLVblock{bi} = PLV.([e1,'_',e2])(freq_ind,trials)';
    RTnorm{bi} = (trialinfo_tmp.RT-nanmean(trialinfo_tmp.RT))/nanstd(trialinfo_tmp.RT);
    subplot(2,nblocks,bi)
    polar(angle(PLVblock{bi}),RTnorm{bi},'o')
    subplot(2,nblocks,bi+nblocks)
    plot(abs(PLVblock{bi}),RTnorm{bi},'o')
    disp(['block ',num2str(bi)])
end

%% compute PLV across trials (sliding window)

