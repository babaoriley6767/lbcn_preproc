function [ROL]= ROLbootstrap_NC(data,ROL_params)
%% INPUTS:
% data: epoched data
%       .wave: actual data
%       .time: timepoint corresponding to each data pt
%       .fsample: sampling rate
% params    (see genROLparams_chao.m)

%Chao Zhang - LBCN

% Updates for ver3, BLF - LBCN 2014.
% Cleaned up code, added comments
% Modified moving window, larger with more overlap

% modified by Amy Daitch- 2016
%%
%get the matrix data (hfb_points * trials)
alldata = data.wave';

% Normalize trial
stim_onset_inx = find(data.time == ROL_params.start_value,1);
end_time_inx = find(data.time == ROL_params.end_value);

win_max = stim_onset_inx:end_time_inx;
m = max(alldata(win_max,:),[],1);
alldata = alldata./repmat(m,size(alldata,1),1);


% Calculate baseline mean and standard deviation
b_start = find(data.time == ROL_params.baseline(1));
stim_bas_inx = find(data.time == ROL_params.baseline(2));

baseline_signal = mean(alldata(b_start:stim_bas_inx,:),2);
mean_bl = mean(baseline_signal);
std_bl = std(baseline_signal);

%

%% Loop through trials
for t = 1:size(data.wave,1)
    
    % Load data for specific trial
    mdata = alldata(:,t)';
    
    % Get number of bins
    numbins = (((ROL_params.end_value-ROL_params.start_value)/ROL_params.bin_timewin)-ROL_params.times_nonover)+1;
    
    % Create cell structure to hold bin data
    bin_data = cell(floor(numbins),6); % bin_data will contain (data; averages; slopes; whether average surpasses threshold; index of first bin value; index of last bin value)
    
    % Loop through bins and create data structure
    for b = 1:numbins
        
        % IF ACTIVE SITE (as appose to deactive)
        if ~ROL_params.deactive
            
            % Set threshold value
            thr = mean_bl + ROL_params.thr_value*std_bl;
            
            if b == 1
                
                % Set data segment of interest and store signal data
                s_value = find(abs(data.time - ROL_params.start_value)<0.001,1);
                e_value = find(abs(data.time - (ROL_params.start_value+(ROL_params.times_nonover*ROL_params.bin_timewin)))<0.001,1);
                bin_data(b,1) = {mdata((s_value):((e_value)))};
                
            else
                
                % Set data segment of interest and store signal data
                s_value = find(abs(data.time - (ROL_params.start_value+ ROL_params.bin_timewin*(b-1)))<0.001,1);
                e_value = find(abs(data.time - (ROL_params.start_value+(ROL_params.bin_timewin*(b-1))+(ROL_params.times_nonover*ROL_params.bin_timewin)))<0.001,1);
                bin_data(b,1) = {mdata(((s_value):((e_value))))};
                
                % one can run the line below to ensure that the bin sizes are generating correctly through the loop
                % bin_range = [start_value+ (params.bin_timewin*(b-1)),start_value+(params.bin_timewin*(b-1))+(times_nonover*params.bin_timewin)]
                
            end
            
            % Create cell structure and store bin average
            bin_data(b,2) = {mean(bin_data{b,1})};
            
            % Get slope
            coefficients = polyfit(1:length(bin_data{b,1}), bin_data{b,1}, 1);
            slope = coefficients(1);
            bin_data(b,3) = {slope};
            
            % Check if bin mean exceeds thershold (1 = yes, 0 = no)
            if bin_data{b,2} > thr
                bin_data(b,4) = {1};   
            else
                bin_data(b,4) = {0};  
            end  
            % Get index of first value
            bin_data(b,5) = {s_value};
            % Get index of last value
            bin_data(b,6) = {e_value};
            
            % IF DEACTIVE SITE
        else
            
            % Set threshold value
            thr = mean_bl - params.thr_value*std_bl;
            if b == 1
                
                % Set data segment of interest and store signal data
                s_value = find(data.time > ROL_params.star_tvalue,1);
                e_value = find(data.time > ROL_params.start_value+(ROL_params.times_nonover*ROL_params.bin_timewin),1);
                bin_data(b,1) = {mdata((s_value):((e_value)))};
                
            else
                
                % Set data segment of interest and store signal data
                s_value = find(data.time > ROL_params.start_value+ (ROL_params.bin_timewin*(b-1)),1);
                e_value = find(data.time > ROL_params.start_value+(ROL_params.bin_timewin*(b-1))+(ROL_params.times_nonover*ROL_params.bin_timewin),1);
                bin_data(b,1) = {mdata(((s_value):((e_value))))};
                
                % one can run the line below to ensure that the bin sizes are generating correctly through the loop
                % bin_range = [start_value+ (params.bin_timewin*(b-1)),start_value+(params.bin_timewin*(b-1))+(times_nonover*params.bin_timewin)]
                
            end
            
            % Create cell structure and store bin average
            bin_data(b,2) = {mean(bin_data{b,1})};
            
            % Get slope
            coefficients = polyfit(1:length(bin_data{b,1}), bin_data{b,1}, 1);
            slope = coefficients(1);
            bin_data(b,3) = {slope};
            
            % Check if bin mean exceeds thershold (1 = yes, 0 = no)
            if bin_data{b,2} > thr
                bin_data(b,4) = {1};   
            else
                bin_data(b,4) = {0};  
            end  
            % Get index of first value
            bin_data(b,5) = {s_value};
            % Get index of last value
            bin_data(b,6) = {e_value};
            
            
        end
        
    end
    
            %% Estimate ROL
            
            % counter to track slope and threshold
            counter = 0;
            peak_bin_index = 0;            
            % loop through bin data to find  ten consequtive bins meeting threshold
            % criterion
            for i = 1:length(bin_data) % would be better with 'while'               
                % if active electrode
                if ROL_params.deactive == 0                   
                    % Check if bin is above threshold, with a positive slope
                    if bin_data{i,4} == 1                      
                        counter = counter + 1;                     
                        % Check if counter exceeds window threshold
                        if counter ==  ROL_params.thr_value_counter
                            % save the value of tenth bin
                            peak_bin_index = i;
                            break
                        end
                    else
                        counter = 0;
                    end
                end
            end
            
          
        %% Initialize ROL

        ROL_Bin = (peak_bin_index-ROL_params.thr_value_counter)+1;

        if (peak_bin_index-ROL_params.thr_value_counter) >= 0
            
            onset_index = bin_data{ROL_Bin,5};
            time = data.time;
            onset = time(onset_index);
            
            % Estimate signal's peak from bins
            % win_peak = ROL_Bin:size(bin_data,1);
            if ~ROL_params.deactive
                [~, Peak_Bin]=max([bin_data{:,2}]);
                peak_index = bin_data{Peak_Bin,5};
                peak = time(peak_index);
                
            else
                [~, Peak_Bin]=min([bin_data{:,2}]);
                peak_index = bin_data{Peak_Bin,5};
                peak = time(peak_index);
            end
            peaks(t) = peak;                                   
            onsets(t) = onset;
            
            % show trial-by-trial onset
            
            % Un-comment contents to see trial by trial estimates
            if ~isnan(onset) 
               %figure; plot(D.time(stim_onset_inx:end_time_inx), mdata(stim_onset_inx:end_time_inx));
               %hold on; plot(onset, .3,'r*') 
               %hold on; plot(peak, .3,'g*') 
                
            end
            
            % Estimate slope in window of positivity to reach onset           
            %twin = bin_data{ROL_Bin+tpeak-1,6};
            %slope_peaks(t,e) = (mdata(twin)-mdata(onset_index))/(length(onset_index:twin)*(1/D.fsample));
        else
            peaks(t) = NaN;
            onsets(t) = NaN;
            
        end

        
    end
    
ROL.peaks= peaks;
ROL.onsets = onsets;
end


