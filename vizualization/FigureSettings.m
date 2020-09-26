% The new defaults will not take effect if there are any open figures. To
% use them, we close all figures, and then repeat the first example.
close all;

width = 9;     % Width in inches
height = 5.625;    % Height in inches
alw = 2;    % AxesLineWidth
fsz = 25;      % Fontsize
lw = 2.5;      % LineWidth
msz = 10;       % MarkerSize

% The properties we've been using in the figures
set(0, 'defaultAxesFontSize', fsz);
set(0, 'defaultAxesLineWidth', alw);
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [200 200 width*100, height*100]);

% Set the defaults for saving/printing to a file
set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(0, 'defaultFigurePaperPosition', defsize);

clear alw bottom defpos defsize fsz height left lw msz width

close all