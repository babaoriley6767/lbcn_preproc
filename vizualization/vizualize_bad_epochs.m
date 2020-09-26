
[badind, filtered_beh,spkevtind,spkts] = LBCN_filt_bad_trial(data.wave',data.fsample*5);

hold off

subplot(3,1,1)
plot(data.wave(data.trialinfo.badtrials_raw==0,:)', 'Color', 'k')
hold on
plot(data.wave(data.trialinfo.badtrials_raw==1,:)', 'Color', 'r')


subplot(3,1,2)
plot(data.wave(data.trialinfo.badtrials_HFO==0,:)', 'Color', 'k')
hold on
plot(data.wave(data.trialinfo.badtrials_HFO==1,:)', 'Color', 'r')

subplot(3,1,3)
plot(data.wave(badind == 0,:)', 'Color', 'k')
hold on
plot(data.wave(badind == 1,:)', 'Color', 'r')


