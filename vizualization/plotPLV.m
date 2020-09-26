close all

goodtrials = find(strcmp(PLV.trialinfo.respType,'CC') & strcmp(PLV.trialinfo.condNotAfterMtn,'city'));
e1 = 'LDP1';
e2 = 'LTP1';
nfreq = 17;

phase_diffs = cell(1,nfreq);
for i = 1:nfreq
    phase_diffs{i} = angle(PLV.([e1,'_',e2])(i,goodtrials));
    itc_tmp = itc(phase_diffs{i});
    p(i) = circular_p(abs(itc_tmp),length(goodtrials));
%     polar(angle(PLV.([e1,'_',e2])(i,goodtrials)),PLV.trialinfo.RT(goodtrials)','o')
%     plot(PLV.trialinfo.RT(goodtrials),abs(PLV.([e1,'_',e2])(i,goodtrials)),'o')

end

[p_fdr_05,~]=fdr(p,0.05);
[p_fdr_005,~]=fdr(p,0.005);
[p_fdr_0005,~]=fdr(p,0.0005);

for i = 1:nfreq
    subplot(3,6,i)
    polarhistogram(phase_diffs{i},32)
    if p(i) < p_fdr_0005
        title([num2str(PLV.freqs(i)) 'Hz***'])
    elseif p(i) < p_fdr_005
        title([num2str(PLV.freqs(i)) 'Hz**'])
    elseif (i) < p_fdr_05
        title([num2str(PLV.freqs(i)) 'Hz*'])
    else
        title([num2str(PLV.freqs(i)) 'Hz'])
    end
end
suptitle([e1,' - ',e2])