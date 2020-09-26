function [mgrid_coord, elect_names, elecRgb] = getmgrid(dirs)

subDir=dirs.freesurfer;
subj = dir(dirs.freesurfer);
subj = subj(end).name;
subDir = [subDir subj];

[mgrid_coord, elect_names, elecRgb,~,elecPresent] = mgrid2matlab_custom(subj,0, dirs.freesurfer);
% elecPresent = elecPresent_exceptions(subj,elecPresent);
% mgrid_coord = mgrid_coord(elecPresent==1,:);
end
