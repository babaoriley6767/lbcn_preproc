function [bad_chan] = promptBadChan

%% Block
bad_chan = nan;
while sum(isnan(bad_chan)) >= 1
    prompt = 'bad_chan: ';
    bad_chan_tmp = input(prompt,'s');
    bad_chan = str2double(strsplit(bad_chan_tmp));
    if sum(isnan(bad_chan)) >= 1
        disp('You can only type numbers')
    else
    end
end


end