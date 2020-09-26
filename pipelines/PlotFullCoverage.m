function getPlotCoverageCFG(type)

cfg.MarkerSize = 3;
cfg.MarkerColor = [0 0 0];
cfg.Colormap = 'BluesWhite'; %viridis
cfg.Cortex =  'MNI';
cfg.CorrectFactor = 0;
cfg.alpha = 1;
cfg.save = false;
cfg.clim = [0 0.1];
cfg.project_left = 0;
cfg.color_center_zero = false;
cfg.MarkerSize_mod = 0;
cfg.figureDim = [0 0 .35 1];
cfg.views = {'lateral', 'lateral', 'ventral', 'ventral', 'medial', 'medial'}; %{'lateral', 'lateral', 'ventral', 'ventral'};
cfg.hemis = {'left', 'right', 'left', 'right', 'left', 'right'}; %{'left', 'right', 'left', 'right'};
cfg.subplots = [3,2];  % 2,2
cfg.chan_highlight = [];
cfg.bad_chans = 0;
cfg.plot_label = 0;
cfg.alpha = 0;
cfg.project_name = [];
cfg.ind = []; % indices for modulation
subjVar_plot.elinfo = subjVar_all;
PlotModulation(dirs, subjVar_plot, cfg)
end

