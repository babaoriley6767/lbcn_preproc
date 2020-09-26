function subjVar_new = reorderElecCoords(subjVar,globalVar)

% reorders electrode coords to match order of ECoG data

nchan_gv = globalVar.nchan; % # of chans according to globalVar
nchan_fs = length(subjVar.elect_names); % # of chans from freesurfer
% nchan = length(subjVar.elect_names);
names_tdt = globalVar.channame;
names_fs = subjVar.elect_names;

ispresent = nan(1,nchan_fs);

for i = 1:nchan_fs
    tmp = find(ismember(names_tdt,names_fs(i)));
    if ~isempty(tmp)
        new_order(i)= tmp(1);
    end
end

bad_inds_fs = find(isnan(new_order));
bad_inds_gv = setdiff(1:nchan_gv,new_order(~isnan(new_order)));

if isempty(bad_inds_fs) || isempty(bad_inds_fs) % if everything matches uip
    subjVar_new.cortex = subjVar.cortex;
    subjVar_new.V = subjVar.V;
    subjVar_new.elect_native = nan(nchan_fs,3);
    subjVar_new.elect_MNI = nan(nchan_fs,3);
    subjVar_new.elect_names = subjVar.elect_names;
    subjVar_new.elect_native(new_order,:) = subjVar.elect_native;
    subjVar_new.elect_MNI(new_order,:) = subjVar.elect_MNI;
    subjVar_new.elect_names(new_order) = subjVar.elect_names;
    if ~isempty(bad_inds_gv) % if not all electrodes were detected in freesurfer, add NaNs to coords
        for i = 1:length(bad_inds_gv)
            subjVar_new.elect_names = [subjVar_new.elect_names; globalVar.channame{bad_inds_gv(i)}];
            subjVar_new.elect_native = [subjVar_new.elect_native; NaN NaN NaN];
            subjVar_new.elect_MNI = [subjVar_new.elect_MNI; NaN NaN NaN];
        end
    else
        subjVar_new.elect_names = subjVar_new.elect_names(1:nchan_gv);
        subjVar_new.elect_native = subjVar_new.elect_native(1:nchan_gv,:);
        subjVar_new.elect_MNI = subjVar_new.elect_MNI(1:nchan_gv,:);
    end
else 
    undefined_subjVar = subjVar.elect_names(bad_inds_fs(bad_inds_fs<=length(subjVar.elect_names)))
    undefined_globalVar = globalVar.channame(bad_inds_gv)
    subjVar_new = subjVar;
end
