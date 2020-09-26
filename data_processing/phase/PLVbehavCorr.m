close all
load cdcol.mat
%% compute behavioral metrics across trials (sliding window)

%window size (i.e. # of consecutive trials) across which to compute behav, PLV
% wintrials = 'blocks'; % number of trials, or 'blocks'
wintrials = 100;
nmove = 25; 
noverlap = wintrials-nmove;
freq_inds = 9;
e1 = 'LRSC10';
e2 = 'LRSC1';
%%

block_names = unique(PLV.trialinfo.block);
nblocks = length(block_names);
nfreqs = length(PLV.freqs);

if (strcmp(wintrials,'blocks'))
    dprime_behav = nan(1,nblocks);
    meanRT = nan(1,nblocks);
    varRT = nan(1,nblocks);
    PLV_win = nan(nfreqs,nblocks);
else
    dprime_behav = cell(1,nblocks);
    meanRT = cell(1,nblocks);
    varRT = cell(1,nblocks);
    PLV_win = cell(1,nblocks);
end

for bi = 1:nblocks
    trials = find(strcmp(PLV.trialinfo.block,block_names{bi}));
    ntrials = length(trials);
    trialinfo_tmp = PLV.trialinfo(trials,:);
    trialinfo_tmp.RT(~strcmp(trialinfo_tmp.respType,'CC'))=NaN; % only consider RTs during correct city responses
    if strcmp(wintrials,'blocks')
        dprime_behav(bi)=dprimeBehav(trialinfo_tmp);
        meanRT(bi) = nanmean(trialinfo_tmp.RT);
        varRT(bi) = nanvar(trialinfo_tmp.RT);
    else
        RTnorm = (trialinfo_tmp.RT-nanmean(trialinfo_tmp.RT))/nanstd(trialinfo_tmp.RT);
%         nwin = ntrials-wintrials+1;
        nwin = floor((ntrials-wintrials)/(nmove)+1);
        dprime_tmp = nan(1,nwin);
        meanRT_tmp = nan(1,nwin);
        varRT_tmp = nan(1,nwin);
        for wi = 1:nwin
%             tmp_trials = wi:wi+wintrials-1;
            tmp_trials = (nmove*(wi-1)+1):(nmove*(wi-1)+wintrials);
            dprime_tmp(wi) = dprimeBehav(trialinfo_tmp(tmp_trials,:));
            meanRT_tmp(wi)=nanmean(RTnorm(tmp_trials));
            varRT_tmp(wi)=nanvar(RTnorm(tmp_trials));
        end
        dprime_behav{bi}=dprime_tmp;
        meanRT{bi}=meanRT_tmp;
        varRT{bi}=varRT_tmp;
    end
    disp(['block ',num2str(bi)])
end

%% compute PLV across trials (sliding window)

for bi = 1:nblocks
    trials = find(strcmp(PLV.trialinfo.block,block_names{bi}));
    trialinfo_tmp = PLV.trialinfo(trials,:);
    PLV_tmp = PLV.([e1,'_',e2])(:,trials);
    if strcmp(wintrials,'blocks')
        PLV_win(:,bi)=nanmean(PLV_tmp,2);
    else
%         nwin = length(trials)-wintrials+1;
        nwin = floor((ntrials-wintrials)/(nmove)+1);
        PLVwin_tmp = nan(nfreqs,nwin);
        for wi = 1:nwin
%             tmp_trials = wi:wi+wintrials-1;
            tmp_trials = (nmove*(wi-1)+1):(nmove*(wi-1)+wintrials);
            PLVwin_tmp(:,wi)=nanmean(PLV_tmp(:,tmp_trials),2);
        end
        PLV_win{bi}=PLVwin_tmp;
    end
    disp(['block ',num2str(bi)])
end

%% plot timecourse of PLV vs. behavioral metrics across trials
col = [cdcol.scarlet; cdcol.periwinkleblue; cdcol.ultramarine; cdcol.grassgreen];
load cdcol.mat

if strcmp(wintrials,'blocks')
    for fi = freq_inds
        figure('Position',[200 200 1000 300])
        subplot(1,3,1),plot(abs(PLV_win(fi,:)),dprime_behav,'.','color',col(1,:),'MarkerSize',16)
        title('PLV vs. d-prime')
        subplot(1,3,2),plot(abs(PLV_win(fi,:)),meanRT,'.','color',col(2,:),'MarkerSize',16)
        title('PLV vs. mean RT')
        subplot(1,3,3),plot(abs(PLV_win(fi,:)),varRT,'.','color',col(3,:),'MarkerSize',16)
        title('PLV vs. var RT')
        suptitle(['Freq: ',num2str(PLV.freqs(fi)),' Hz'])
    end
else
    
    for fi = freq_inds
        figure('Position',[200 200 500 1500])
        for bi = 1:nblocks
            subplot(nblocks,1,bi)
            h(1)=plot(normMinMax(abs(PLV_win{bi}(fi,:))),'color',col(1,:),'LineWidth',2);
            hold on
            h(2)=plot(normMinMax(meanRT{bi}),'color',col(2,:),'LineWidth',2);
            h(3)=plot(normMinMax(varRT{bi}),'color',col(3,:),'LineWidth',2);
            h(4)=plot(normMinMax(dprime_behav{bi}),'color',col(4,:),'LineWidth',2);
            legend({'PLV','meanRT','varRT','dprime'})
            title(['Block ',num2str(bi)])
        end
        suptitle(['Freq: ',num2str(PLV.freqs(fi)),' Hz'])
    end
    
    % plot correlation bw PLV and behav measures
    % 1: PLV
    % 2: mean(RT)
    % 3: var(RT)
    % 4: d-prime
    
    corr_all = nan(nfreqs,nblocks,4,4);
    p_all = nan(nfreqs,nblocks,4,4);
    for bi = 1:nblocks
        data_tmp = nan(length(meanRT{bi}),4);
        data_tmp(:,2)=meanRT{bi}';
        data_tmp(:,3)=varRT{bi}';
        data_tmp(:,4)=dprime_behav{bi}';
        for fi = 1:nfreqs
            data_tmp(:,1)=abs(PLV_win{bi}(fi,:))';
            [corr_all(fi,bi,:,:),p_all(fi,bi,:,:)]=corrcoef(data_tmp,'rows','complete');
            for i = 1:4
                corr_all(fi,bi,i,i)=NaN;
                p_all(fi,bi,i,i)=NaN;
            end
        end
    end
    
    [p_fdr,~]=fdr(p_all(:),0.05);
    
    Ticks = {'PLV','mRT','vRT','dp'};
    cm = cbrewer2('RdYlBu');
    cm = cm(end:-1:1,:);
    for fi = freq_inds
        n_sig_pos = zeros(4,4);
        n_sig_neg = zeros(4,4);
        figure('Position',[200 200 2500 300])
        for bi = 1:nblocks
            subplot(1,nblocks+1,bi)
            tmp_corr = squeeze(corr_all(fi,bi,:,:));
            tmp_corr(logical(triu(ones(4))))=NaN;
            imagesc(tmp_corr,[-1 1])
            hold on
            colormap(cm)
            set(gca,'XTick',1:4)
            set(gca,'YTick',1:4)
            set(gca,'XTickLabel',Ticks)
            set(gca,'YTickLabel',Ticks)
            title(['Block ',num2str(bi)])
            tmp_p = squeeze(p_all(fi,bi,:,:)<p_fdr);
            tmp_p(logical(tril(ones(4))))=0;
            n_sig_pos = n_sig_pos + tmp_p.*squeeze(corr_all(fi,bi,:,:)>0);
            n_sig_neg = n_sig_neg + tmp_p.*squeeze(corr_all(fi,bi,:,:)<0);
            [i,j]=find(tmp_p);
            for pi = 1:length(i)
                plot(i(pi),j(pi),'k*')
            end
        end
        subplot(1,nblocks+1,nblocks+1)
        tmp_corr = squeeze(nanmean(corr_all(fi,bi,:,:),2));
        tmp_corr = tmp_corr.*(tril(ones(4))+triu(nan(4)));
        imagesc(tmp_corr,[-1 1])
        set(gca,'XTick',1:4)
        set(gca,'YTick',1:4)
        set(gca,'XTickLabel',Ticks)
        set(gca,'YTickLabel',Ticks)
        title('Avg across blocks')
        for i = 1:4
            for j = (i+1):4
                text(i,j,[num2str(n_sig_pos(i,j)),'-',num2str(n_sig_neg(i,j))])
            end
        end
        suptitle(['Freq: ',num2str(PLV.freqs(fi)),' Hz'])
        colorbar
    end
end


