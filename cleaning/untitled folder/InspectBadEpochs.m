%%%%%%%%%%%%%load sample data from a noisy patient. Data input in columes
function InspectBadEpochs(badind, spkevtind, spkts, data_raw, fs)

%%plot the results
[bb,aa]=butter(2,70/(fs/2), 'high');
df = filtfilt(bb,aa,data_raw);
spkdt=nan(size(df));
spkdt(spkts)=df(spkts);
t = (0:size(data_raw,1)-1)/fs-0.3;
%% see which epoches are detected and which data points are identified
figureDim = [0 0 1 .4];
figure('units', 'normalized', 'outerposition', figureDim)
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

%% Plot the identified bad epochs (the entire epoch should be excluded)%%%%%%%%%%%%
figure
for i=find(badind)
    
    plot(t,data_raw(:,i),'k');
    xlim([t(1) t(end)]);
    set(gca,'linewidth',1,'fontsize',16);
    title(strcat('Bad data',':',num2str(i)));
    pause;
end

end