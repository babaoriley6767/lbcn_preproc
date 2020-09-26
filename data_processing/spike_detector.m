function data_bn = spike_detector(data_bn,el,subjVar,project_name)

    if (~strcmp(project_name, 'Rest') && ~strcmp(project_name, 'EglyDriver'))
        for iout = 1:size(data_bn.wave, 1)
            data_tmp(iout,:) = data_bn.wave(iout,:);
            data_tmp(iout,data_bn.time>data_bn.trialinfo.RT(iout)) = nan;
        end
        max_val = max(data_tmp, [], 2);
        if strcmp(subjVar.elinfo.DK_lobe{el}, 'Occipital')
            thrhold = 4;
        else
            thrhold = 3;
        end
        data_bn.trialinfo.spike_hfb = zscore(log(max_val))>thrhold ;
    end

end

