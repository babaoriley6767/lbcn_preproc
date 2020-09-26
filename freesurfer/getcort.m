function cortex = getcort(dirs)

cortex = [];
cortex.left = [];
cortex.right = [];
% cortex.left_semi_inflated = [];
% cortex.right_semi_inflated = [];
cortex.left_inflated = [];
cortex.right_inflated = [];

subDir=dirs.freesurfer;
subj = dir(dirs.freesurfer);
subj = subj(end).name;
subDir = [subDir subj];

[cortex.left.vert, cortex.left.tri] = read_surf(fullfile(subDir,'surf', 'lh.PIAL'));
[cortex.right.vert, cortex.right.tri] = read_surf(fullfile(subDir,'surf','rh.PIAL'));

% 
% [cortex.left_semi_inflated.vert, cortex.left_semi_inflated.tri] = read_surf(fullfile(subDir,'surf', 'lh.pial_semi_inflated'));
% [cortex.right_semi_inflated.vert, cortex.right_semi_inflated.tri] = read_surf(fullfile(subDir,'surf', 'rh.pial_semi_inflated'));

[cortex.left_inflated.vert, cortex.left_inflated.tri] = read_surf(fullfile(subDir,'surf', 'lh.inflated'));
[cortex.right_inflated.vert, cortex.right_inflated.tri] = read_surf(fullfile(subDir,'surf', 'rh.inflated'));



end


