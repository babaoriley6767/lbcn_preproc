function plotIRASA(sbj_name, project_name, elecs, dirs, irasa_params)

% Load subjVar
load([dirs.original_data filesep  sbj_name filesep 'subjVar_'  sbj_name '.mat']);
if isempty(elecs)
    elecs = 1:length(subjVar.labels_EDF);
else
end

% Load IRASA
dir_base = '/Volumes/LBCN8T_2/Stanford/data/Results';
load(sprintf('%s/%s/%s/signal_properties/IRASA.mat', dir_base, project_name, sbj_name));

all_elecs = fieldnames(IRASA);

% Figure pararameters
fontsize = 16;
colors = {'blue', 'red', 'green'};
% Loop across electrodes
for el = 1:length(all_elecs) %
    dt = IRASA.(all_elecs{el});
    figure('units', 'normalized', 'outerposition', [0 0 0.5 0.3])
    % Loop across conditions
    for ic = 1:length(irasa_params.conds)
        dtc = dt.(irasa_params.conds{ic});
        %% plot the fractal component and the power spectrum
        subplot(1,2,1)
        if isstruct(dtc.frac)
            plot(dtc.frac.freq, dtc.frac.powspctrm, 'linewidth', 3, 'color', [0 0 0])
            hold on; plot(dtc.orig.freq, dtc.orig.powspctrm, 'linewidth', 3, 'color', [.6 .6 .6])
            title([irasa_params.conds{ic} ' ' all_elecs{el}], 'interpreter', 'none')
            set(gca,'fontsize',fontsize)
            legend('Fractal component', 'Power spectrum');
            
            if sum(~isnan(dtc.model.(irasa_params.model).peaks.mean)) ~= 0
                for im = 1:length(dtc.model.(irasa_params.model).peaks.mean)
                    m_t = dtc.model.(irasa_params.model).peaks.mean(im);
                    if m_t > 0
                        m_t_str = num2str(m_t);
                        st_t = dtc.model.(irasa_params.model).peaks.std(im);
                        texty = dtc.orig.powspctrm(max(find(m_t > dtc.orig.freq)));
                        if ~isempty(texty)
                            text(m_t, texty, m_t_str(1:end-2), 'HorizontalAlignment', 'left', 'VerticalAlignment', 'baseline', 'FontSize', 20, 'Color', colors{im})
                            plot(dtc.orig.freq(min(find(dtc.orig.freq>=m_t-st_t)):max(find(dtc.orig.freq<=m_t+st_t))), dtc.orig.powspctrm(min(find(dtc.orig.freq>=m_t-st_t)):max(find(dtc.orig.freq<=m_t+st_t))), 'Color', colors{im}, 'LineWidth',3)
                        else
                        end
                    else
                    end
                end
                % Complete legend
                legend('Fractal component', 'Power spectrum', 'FWHM oscillation peak 1', 'FWHM oscillation peak 2');
                xlabel('Frequency'); ylabel('Power');
                
            end
        else
           plot(1,1)
        end
        
    end
    
    % Save
    dir_base = '/Volumes/LBCN8T_2/Stanford/data/Results';
    fout = sprintf('%s/%s/%s/signal_properties/IRASA_%s.png', dir_base, project_name, sbj_name, all_elecs{el});
    savePNG(gcf, 300, fout)
    close all
end


%
%     subplot(1,2,2)
%     plot(dtc.frac.freq, frac.powspctrm, ...
%         'linewidth', 3, 'color', [0 0 0])
%     hold on; plot(orig.freq, orig.powspctrm, ...
%         'linewidth', 3, 'color', [.6 .6 .6])
%     title(subjVar.labels_EDF{el})
%     xlabel('Log(Frequency)'); ylabel('Log(Power)');
%     set(gca, 'YScale', 'log')
%     set(gca, 'XScale', 'log')
%     set(gca,'fontsize',fontsize)
% set(gca, 'YLim', yl);
% set(gca,'fontsize',fontsize)