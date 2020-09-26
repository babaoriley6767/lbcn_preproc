function plotPhaseRTCorr(sbj_name,project_name,dirs,elecs,plot_params)

load([dirs.result_root,'/',project_name,'/',sbj_name,'/allblocks/phaseRTcorr.mat'])
dir_out = [dirs.result_root,'/',project_name,'/',sbj_name,'/Figures/phaseRTCorr/'];

if ~exist(dir_out)
    mkdir(dir_out)
end

if isempty(plot_params)
   plot_params = genPlotParams(project_name,'RTCorr');
   plot_params.xlim = [phaseRT.time(1) phaseRT.time(end)];
end

freq_inds = [find(phaseRT.freqs >= plot_params.freq_range(1),1) find(phaseRT.freqs >= plot_params.freq_range(2),1)];
[~,nfreqs,~]=size(phaseRT.rho);

freq_ticks = 1:4:nfreqs;
freq_labels = cell(1,length(freq_ticks));
for i = 1:length(freq_ticks)
    freq_labels{i}=num2str(round(phaseRT.freqs(freq_ticks(i))));
end
if plot_params.norm
    tag = '_norm';
else
    tag = '';
end

for ei = 1:length(elecs)
    el = elecs(ei);
    if plot_params.norm
        imagesc(phaseRT.time,1:nfreqs,squeeze(phaseRT.rho_norm(el,:,:)),plot_params.clim)
    else
        imagesc(phaseRT.time,1:nfreqs,squeeze(phaseRT.rho(el,:,:)),plot_params.clim)
    end
    axis xy
    hold on
    colormap(plot_params.cmap);
    set(gca,'YTick',freq_ticks)
    set(gca,'YTickLabel',freq_labels)
    plot([0 0],ylim,'k-','LineWidth',3)
    xlabel(plot_params.xlabel)
    ylabel(plot_params.ylabel)
    xlim(plot_params.xlim)
    ylim(freq_inds)
    set(gca,'fontsize',plot_params.textsize)
    box off
    colorbar
    title(phaseRT.channame{ei})
    
    fn_out = sprintf('%s/%s_phaseRTCorr%s_%s.png',dir_out,sbj_name,tag,phaseRT.channame{ei});
    saveas(gcf,fn_out)
    close
end

end

