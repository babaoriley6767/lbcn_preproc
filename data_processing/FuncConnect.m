function corr_chans = FuncConnect(data_fc_lp, cfg)
%% Arguments

block_names = fieldnames(data_fc_lp);

for bi = 1:length(block_names)
    bn = block_names{bi};
    for il = 1:5%size(data_fc_lp.(bn),2)
        if cfg.cross_corr
            for ic = 1:5%size(data_fc_lp.(bn),2)
                % Cross correlation
                fprintf('cross correlation of %d and %d\n %s', il, ic, bn);
                [r, lags] = crosscorr(double(data_fc_lp.(bn)(:,il)), double(data_fc_lp.(bn)(:,ic)), 'NumLags',cfg.cross_corr_lags*cfg.fsample);
                corr_chans.(bn).cross{il,ic} = r;
                [peak, lag] = max(r);
                corr_chans.(bn).cross_peak(il,ic) = peak;
                corr_chans.(bn).cross_peak_lag(il,ic) = lags(lag);
            end
        else
        end
    end
    % Zero lag
    if cfg.zero_lag
        fprintf('zero correlation of %s', bn);
        corr_chans.(bn).zero_lag = corr(data_fc_lp.(bn));
    else
    end
end
end

