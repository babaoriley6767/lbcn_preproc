
function coords_plot = CorrectElecLoc(coords, views, hemisphere, correction_factor)
%% Function to optimize electrode location for plotting

coords_plot = coords;
% correction_factor = 0;
switch views
    case {'lateral', 'frontal', 'parietal'}
        if strcmp(hemisphere, 'right')
            coords_plot(:,1) = coords_plot(:,1) + correction_factor;
        elseif strcmp(hemisphere, 'left')
            coords_plot(:,1) = coords_plot(:,1) - correction_factor;
        end
    case 'medial'
        if strcmp(hemisphere, 'right')
            coords_plot(:,1) = coords_plot(:,1) - correction_factor;
        elseif strcmp(hemisphere, 'left')
            coords_plot(:,1) = coords_plot(:,1) + correction_factor;
        end
    case {'ventral', 'temporal'}
        coords_plot(:,3) = coords_plot(:,3) - correction_factor;
end
end