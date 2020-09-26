[badind, filtered_beh,spkevtind,spkts] = LBCN_filt_bad_trial(data.wave',500)


sum(data.trialinfo.badtrial == data.trialinfo.badtrial_su)/64

subplot(3,1,1)
plot(data.wave(data.trialinfo.badtrial_su==0,:)', 'Color', 'k')
hold on
plot(data.wave(data.trialinfo.badtrial_su==1,:)', 'Color', 'r')

subplot(3,1,2)
hold off
plot(data.wave(data.trialinfo.badtrial==0,:)', 'Color', 'k')
hold on
plot(data.wave(data.trialinfo.badtrial==1,:)', 'Color', 'r')


subplot(3,1,3)
hold off
plot(data.wave(spkevtind==0,:)', 'Color', 'k')
hold on
plot(data.wave(spkevtind==1,:)', 'Color', 'r')



