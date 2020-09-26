function MakeVideoActivationTime_lite(data, c_lim, time_lim, dirs)


%% Load template brain
load([dirs.code_root filesep 'vizualization/Colin_cortex_left.mat']);
cmcortex.left = cortex;
load([dirs.code_root filesep 'vizualization/Colin_cortex_right.mat']);
cmcortex.right = cortex;

%% Get indices for colloring
data.wave(data.wave>c_lim(2)) = data.wave(data.wave>c_lim(2))/max(data.wave(data.wave>c_lim(2))) * c_lim(2);
[col_idx,cols] = colorbarFromValues(data.wave(:), 'RedBlue',[],true);
col_idx = reshape(col_idx,size(data.wave,1), size(data.wave,2));

%% Plot parameters
mark = 'o';
MarkSizeEffect = 25;
colRing = [0 0 0]/255;
time = data.time(find(data.time == time_lim(1)):max(find(data.time <= time_lim(2))));

% Define channels to plot
chan_plot = data.MNI_coord;

%% Plot math
views = {'lateral', 'lateral', 'medial', 'medial', 'ventral', 'ventral'};
hemis = {'left', 'right', 'left', 'right', 'left', 'right'};

F = struct;
count = 0;
for e = [100 200]%:2:length(time)
    count = count+1;
    figureDim = [0 0 .4 1];
    f1 = figure('units', 'normalized', 'outerposition', figureDim);
    
    for i = 1:length(views)
        subplot(3,2,i)
        ctmr_gauss_plot(cmcortex.(hemis{i}),[0 0 0], 0, hemis{i}, views{i})
        for ii = 1:size(chan_plot)
            if (strcmp(hemis{i}, 'left') == 1 && chan_plot(ii,1) > 0) || (strcmp(hemis{i}, 'right') == 1 && chan_plot(ii,1) < 0)
            else
                % Order channels based on total actitivy (so far only for lateral)
                if (strcmp(hemis{i}, 'left') == 1) && (strcmp(views{i}, 'lateral') == 1)
                    plot3(chan_plot(ii,1) - sum(data.wave(ii,:)),chan_plot(ii,2),chan_plot(ii,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(ii,e),:), 'MarkerSize', MarkSizeEffect*abs(data.wave(ii,e))/2);
                elseif (strcmp(hemis{i}, 'right') == 1) && (strcmp(views{i}, 'lateral') == 1)
                    plot3(chan_plot(ii,1) + sum(data.wave(ii,:)) ,chan_plot(ii,2),chan_plot(ii,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(ii,e),:), 'MarkerSize', MarkSizeEffect*abs(data.wave(ii,e))/2);
                else
                    plot3(chan_plot(ii,1),chan_plot(ii,2),chan_plot(ii,3), 'o', 'Color', 'k', 'MarkerFaceColor', cols(col_idx(ii,e),:), 'MarkerSize', MarkSizeEffect*abs(data.wave(ii,e))/2);
                end
            end
        end
        alpha(0.7)
    end
    
    time_tmp = num2str(time(e));
    
    if length(time_tmp) < 6
        time_tmp = [time_tmp '00'];
    end
    if strcmp(time_tmp(1), '-')
        time_tmp = time_tmp(1:6);
    else
        if strcmp(time_tmp, '000')
        else
            time_tmp = time_tmp(1:5);
        end
    end
    
    text(260, -150, -60, [time_tmp ' s'], 'FontSize', 40)
    cdata = getframe(gcf);
    F(count).cdata = cdata.cdata;
    F(count).colormap = [];
    close all
end

fig = figure('units', 'normalized', 'outerposition', figureDim);
movie(fig,F,1)

dir_out = [dirs.result_root filesep 'videos' filesep];
videoRSA = VideoWriter([dir_out 'MMR' '.avi']);
videoRSA.FrameRate = 30;  % Default 30
videoRSA.Quality = 100;    % Default 75
open(videoRSA);
writeVideo(videoRSA, F);
close(videoRSA);

end