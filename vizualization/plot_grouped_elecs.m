function plot_grouped_elecs(subjVar)

close all
load('cdcol_2018.mat')
groupcols = [cdcol.indian_red; cdcol.light_olive_40; cdcol.azurite_blue; cdcol.raw_russet;  cdcol.yellow; ...
    cdcol.sky_blue;cdcol.jade_green; cdcol.fast_orange; cdcol.turquoise_green; cdcol.violet; cdcol.raspberry_red;...
    cdcol.veronese_green; cdcol.sapphire_blue; cdcol.silver_2; cdcol.flame_red; cdcol.purple; cdcol.cobalt_blue_10; ...
    cdcol.middle_phthalocyanine_green];

nchans = length(subjVar.elect_names);

groupname = cell(nchans,1);
elecnum = nan(nchans,1);

for i = 1:nchans
    temp_name = char(subjVar.elect_names(i));
    ginds = find(isletter(temp_name));
%     ninds = find(isnumber(temp_name));
    groupname{i}=temp_name(ginds);
%     elecnum(i)=temp_name(ninds);
end
uniquegroups = unique(groupname);

load('Colin_cortex_right')
figure('Position',[200 200 2000 2000])
subplot(2,2,1)
ctmr_gauss_plot(subjVar.cortex.left,[0 0 0], 0, 'r', 1)
alpha(0.7)
hold on
subplot(2,2,3)
ctmr_gauss_plot(cortex,[0 0 0], 0, 'r', 1)
alpha(0.7)
hold on

count = 1;
l_inds = [];
for gi = 1:length(uniquegroups)
    inds = find(strcmp(groupname,uniquegroups{gi}) & subjVar.elect_native(:,1)<=0);
    if ~isempty(inds)
        subplot(2,2,1)
        h(count)=plot3(subjVar.elect_native(inds,1),subjVar.elect_native(inds,2),subjVar.elect_native(inds,3), 'o', 'Color', 'k', 'MarkerFaceColor', groupcols(gi,:), 'MarkerSize', 10);
        title('Native Brain: Left')
        subplot(2,2,3)
        plot3(subjVar.elect_MNI(inds,1),subjVar.elect_MNI(inds,2),subjVar.elect_MNI(inds,3), 'o', 'Color', 'k', 'MarkerFaceColor', groupcols(gi,:), 'MarkerSize', 10);
        title('MNI Brain: Left')
        count = count+1;
        l_inds = [l_inds gi];
    end
end
alpha(0.7)
subplot(2,2,1)
% legend(h,uniquegroups(l_inds))
legend boxoff



load('Colin_cortex_right')
subplot(2,2,2)
ctmr_gauss_plot(subjVar.cortex.right,[0 0 0], 0, 'r', 1)
alpha(0.7)
hold on
subplot(2,2,4)
ctmr_gauss_plot(cortex,[0 0 0], 0, 'r', 1)
alpha(0.7)
hold on

count = 1;
r_inds = [];
for gi = 1:length(uniquegroups)
    inds = find(strcmp(groupname,uniquegroups{gi}) & subjVar.elect_native(:,1)>=0);
    if ~isempty(inds)
        subplot(2,2,2)
        h(count)=plot3(subjVar.elect_native(inds,1),subjVar.elect_native(inds,2),subjVar.elect_native(inds,3), 'o', 'Color', 'k', 'MarkerFaceColor', groupcols(gi,:), 'MarkerSize', 10);
        title('Native Brain: Right')
        subplot(2,2,4)
        plot3(subjVar.elect_MNI(inds,1),subjVar.elect_MNI(inds,2),subjVar.elect_MNI(inds,3), 'o', 'Color', 'k', 'MarkerFaceColor', groupcols(gi,:), 'MarkerSize', 10);
        title('MNI Brain: Right')
        count = count+1;
        r_inds = [r_inds gi];
    end
end
alpha(0.7)
subplot(2,2,2)
% legend(h,uniquegroups(r_inds))
legend boxoff



    

