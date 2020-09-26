%%%%%%%%%%%%%load sample data from a noisy patient. Data input in columes 


load('/Users/pinheirochagas/Pedro/Stanford/code/lbcn_preproc/cleaning/untitled folder/sample_data_S123.mat');


data_raw = data_CAR.wave'
[badind, filtered_beh,spkevtind,spkts] = LBCN_filt_bad_trial_noisy(data_CAR.wave',fs,[],[],8,0.6);


%%%%%%%%%%%%%plot the results
[bb,aa]=butter(2,[80 200]/(fs/2));
df = filtfilt(bb,aa,data_raw);
spkdt=nan(size(df));
spkdt(spkts)=df(spkts);
t = (0:size(data_raw,1)-1)/fs-0.3;
%%%%%%%%%%%%%see which epoches are detected and which data points are
%%%%%%%%%%%%%identified 
figure
for i=find(spkevtind)
    subplot 211; 
    plot(t,data_raw(:,i),'k');
    hold on
    line([0 0],[-abs(min(data_raw(:,i)))*1.2 abs(max(data_raw(:,i)))*1.2],'color','k','linewidth',1);
    hold off
    ylim([-abs(min(data_raw(:,i)))*1.2 abs(max(data_raw(:,i)))*1.2]);
    xlim([t(1) t(end)]);
    title('Raw data');
    set(gca,'linewidth',2,'fontsize',16);
    subplot 212;
    plot(t,df(:,i),'k');
    hold on;
    plot(t,spkdt(:,i),'r','linewidth',1);
    line([0 0],[-abs(min(df(:,i)))*1.2 abs(max(df(:,i)))*1.2],'color','k','linewidth',1);
    title(strcat('Filtered data and identified data points',':',num2str(i)));
    hold off;
    ylim([-abs(min(df(:,i)))*1.2 abs(max(df(:,i)))*1.2]);
    xlim([t(1) t(end)]);
    set(gca,'linewidth',1,'fontsize',16);
    pause
end

%%%%%%%%%%%%%%%%%%%%%%plot the identified bad epochs (the entire epoch should be excluded)%%%%%%%%%%%% 
figure
for i=find(badind)

    plot(t,data_raw(:,i),'k');
    xlim([t(1) t(end)]);
    set(gca,'linewidth',1,'fontsize',16);
    title(strcat('Bad data',':',num2str(i)));
    pause;
end