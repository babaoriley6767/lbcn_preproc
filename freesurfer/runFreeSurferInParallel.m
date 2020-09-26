
%% List subject to run freesurfer
parpool(16)
data_freesurfer = '/Volumes/LBCN8T/Stanford/data/freesurfer/new';
subj_folders = dir(fullfile(data_freesurfer));
subj_folders = subj_folders(cellfun(@(x) ~contains(x, '.'), {subj_folders.name}));

% list all niiFileName
cmd = [];
for i = 1:length(subj_folders)
    niiFileName_path = [subj_folders(i).folder filesep subj_folders(i).name filesep 'Neuroimage_Raw' filesep 'DICOM_T1'];
    tmp_files = dir(fullfile(niiFileName_path));
    length_tmp = cellfun(@length, {tmp_files.name});
    niiFileName = [niiFileName_path filesep tmp_files(find(length_tmp == max(length_tmp))).name];
    if i == length(subj_folders)
        cmd = [cmd sprintf('recon-all -s %s -i %s -all -localGI', subj_folders(i).name, niiFileName)];
    else
        cmd = [cmd sprintf('recon-all -s %s -i %s -all -localGI', subj_folders(i).name, niiFileName) ' & ']; % this makes the command run in parallel!
    end
end
cmd = ['export FREESURFER_HOME=/Applications/freesurfer; source /Applications/freesurfer/SetUpFreeSurfer.sh; ' cmd];

system(cmd)

