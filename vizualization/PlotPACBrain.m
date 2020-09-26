function PlotPACBrain(el, cfg)

% Convert coordinates to left hemi
el.e1(:,1) = -abs(el.e1(:,1));
el.e2(:,1) = -abs(el.e2(:,1));

%% Adjust elect coords
% el = CorrectElecLoc(el, 'lateral','left', cfg.correction_factor);

load('cdcol_2018.mat')
marker_size = 5;

MarkerFaceColor = 'k';
MarkerEdgeColor = 'w';

% Load cortex
% [cmcortex.right.vert cmcortex.right.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['rh.' 'pial']));
[cmcortex.left.vert cmcortex.left.tri]=read_surf(fullfile('/Applications/freesurfer/subjects/fsaverage/surf',['lh.' 'pial']));

% Plot cortex
% figureDim = [0 0 .3 .5];
% figure('units', 'normalized', 'outerposition', figureDim)
ctmr_gauss_plot(cmcortex.left,[0 0 0], 0, 'left', 'lateral')
alpha(cfg.alpha)

% Plot electrode arrows
for ii = 1:size(el,1)
    hold on
    plot3(el.e1(ii,1),el.e1(ii,2),el.e1(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', MarkerFaceColor, 'MarkerEdgeColor', MarkerEdgeColor);
    plot3(el.e2(ii,1),el.e2(ii,2),el.e2(ii,3), 'o', 'MarkerSize', marker_size, 'MarkerFaceColor', MarkerFaceColor, 'MarkerEdgeColor', MarkerEdgeColor);
    
    if sum(el.dir(ii,:) == [2,1]) == 2
        mArrow3(el.e1(ii,:), el.e2(ii,:), 'stemWidth', 0.5, 'tipWidth', 3, 'FaceColor', cfg.arrow_col);
    else
        mArrow3(el.e1(ii,:), el.e2(ii,:), 'stemWidth', 0.5, 'tipWidth', 3, 'FaceColor', cfg.arrow_col);
    end
%     set(gcf,'Color',[0.1 0.1 0.1])
end