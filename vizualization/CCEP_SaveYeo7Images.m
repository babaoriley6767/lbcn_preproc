clc
FigureSettings

savepath='D:\Research\CCEP\Figures\';

addpath(genpath('C:\Users\Mike\Documents\iELVis-master'))

map=pmkmp(8,'IsoL');

map=hsv(8)

global globalFsDir;
globalFsDir='D:\Research\CCEP\FS';
cd(globalFsDir);

% Read annotation file


% Network you want to plot

map=viridis(8)
for id = 2:8
% for id = 3

subplot(1,7,id-1)
    [averts, label, col]=read_annotation('/Applications/freesurfer/subjects/fsaverage/label/lh.Yeo2011_7Networks_N1000.annot');

    albl=label;
    actbl=col;
    [cort.vert cort.tri]=read_surf('/Applications/freesurfer/subjects/fsaverage/surf/lh.inflated');
    if min(min(cort.tri))<1
        cort.tri=cort.tri+1; %sometimes this is needed, sometimes not. no comprendo. DG
    end
    

    [~,locTable]=ismember(albl,actbl.table(:,5));
    locTable(locTable==0)=1; % for the case where the label for the vertex says 0
    fvcdat=actbl.table(locTable,1:3)./255; %scale RGB values to 0-1
    netdat=actbl.struct_names(locTable);
    clear locTable;

    netind=find(fvcdat(cort.tri(:,1))==fvcdat(cort.tri(:,2)) & fvcdat(cort.tri(:,1))==fvcdat(cort.tri(:,3)));
    edgeind=find(~(fvcdat(cort.tri(:,1))==fvcdat(cort.tri(:,2)) & fvcdat(cort.tri(:,1))==fvcdat(cort.tri(:,3))));
    edgeind=unique(cort.tri(edgeind,1));

    % Make verteces gray
    col.table(:,1:3)=map*255;
    color=col.table(id,1:3);
    col.table(:,1:3) = 0.8.*255.*ones(size(col.table(:,1:3)));

    % Color parcel of interest
    col.table(id,1:3)=color;

    albl=label;
    actbl=col;

    [~,locTable]=ismember(albl,actbl.table(:,5));
    locTable(locTable==0)=1; % for the case where the label for the vertex says 0
    fvcdat=actbl.table(locTable,1:3)./255; %scale RGB values to 0-1
    netdat=actbl.struct_names(locTable);
    clear locTable;
    
    hTsurf=trisurf(cort.tri, cort.vert(:, 1), cort.vert(:, 2), cort.vert(:, 3),...
        'FaceVertexCData', fvcdat,'FaceColor', 'interp','FaceAlpha',1); hold on

    shading interp; lighting gouraud; material dull; axis off, hold on
    lightParams=[];
%     light('Position',[-1 0 0]);
    view(270,0);
    alpha(1);


    
    scatter3(cort.vert(edgeind, 1), cort.vert(edgeind, 2), cort.vert(edgeind, 3),...
        ones(length(cort.vert(edgeind, 3)),1)*2,'filled','MarkerEdgeColor','k','MarkerFaceColor','k')

    clear cortsave

end