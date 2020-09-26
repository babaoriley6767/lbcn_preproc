function data_fc_lp = PreprocFuncConnect(sbj_name,block_names, dirs, elecs, nsec_crop)
%% Arguments
% sbj_name
% block_names
% nsec_crop: seconds to crop to avoid edge artifacts.
data_fc_lp = struct;
for el = 1:length(elecs)
    for bi = 1:length(block_names)
        bn = block_names{bi};
        dir_in = [dirs.data_root,filesep,'Band','Data',filesep,'HFB',filesep,sbj_name,filesep,bn];
        disp(['loading channel ' sprintf('%.2d',elecs(el))])
        load(sprintf('%s/%siEEG%s_%.2d.mat',dir_in,'HFB',bn,el));
        disp(['bandpass filtering channel ' sprintf('%.2d',el)])
        % Bandpass
        data_tpm = ft_preproc_bandpassfilter(data.wave, 1000, [0.1, 1], 4, 'but', 'twopass', 'reduce');
        % Crop to eliminate edge artifacts
        crop_s = max(find(nsec_crop>data.time));
        data_tpm = data_tpm(crop_s:end-crop_s);
        data.time = data.time(crop_s:end-crop_s);
        % Bring time back to 0
        data.time = data.time - min(data.time);
        data_fc_lp.(bn)(:,el) = data_tpm;
    end
end
end

