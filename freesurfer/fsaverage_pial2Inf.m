function infCoor=fsaverage_pial2Inf(dirs,MNI_coord,Hem)
% This function converts any electrode coordinate on fsaverage pial surface
% to fsaverage inflated brain coordinates.
% Serdar Akkol, 2020 August.

sub_dir = dirs.fsDir_local;

% numeric electrode coordinates have been passed in the function call
pial_coor=MNI_coord;
leftIds=find(strcmpi(Hem,'L'));
rightIds=find(strcmpi(Hem,'R'));
nChan=size(pial_coor,1);


%% Loop over hemispheres
infCoor=zeros(nChan,3);
for hemLoop=1:2,
    if hemLoop==1,
        hem='l';
        useIds=leftIds;
    else
        hem='r';
        useIds=rightIds;
    end
    if size(useIds,1)>1,
        useIds=useIds';
    end
    
    %% Read Sub Pial Surf
    %fname=[sub_dir '/surf/' hem 'h.pial'];
    fname=fullfile(sub_dir,'surf',[hem 'h.pial']);
    pial=readSurfHelper(fname);
    
    %% Read Sub Inflated Surf
    %fname=[sub_dir '/surf/' hem 'h.inflated'];
    fname=fullfile(sub_dir,'surf',[hem 'h.inflated']);
    inflated=readSurfHelper(fname);
    
    %% Get vertices for electrodes on sub's pial surface
    nPialVert=size(pial.vert,1);
    nUseId=length(useIds);
    if nUseId
        for a=useIds,
            df=pial.vert-repmat(pial_coor(a,:),nPialVert,1);
            dst=sum(abs(df),2);
            [dummy, sub_vid]=min(dst);
            
            %% Get electrode coordinates on inflated brain
            infCoor(a,:)=inflated.vert(sub_vid,:);
        end
        
        %% Plot to check
        if 0
            figure(10); clf;
            subplot(121);
            plot3(inflated.vert(:,1),inflated.vert(:,2),inflated.vert(:,3),'b.'); hold on;
            plot3(infCoor(useIds,1),infCoor(useIds,2),infCoor(useIds,3),'ro');
            axis square;
            
            subplot(122);
            plot3(pial.vert(:,1),pial.vert(:,2),pial.vert(:,3),'b.'); hold on;
            plot3(pial_coor(useIds,1),pial_coor(useIds,2),pial_coor(useIds,3),'ro');
            axis square;
        end
    end
end

end