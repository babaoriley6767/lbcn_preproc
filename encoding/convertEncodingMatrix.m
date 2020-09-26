function [enc_matrix_brain, trialinfo_concat, col_names]= convertEncodingMatrix(data, cfg)
%% Converts data structure into a encoding matrix
% Here this matrix is represented as a table, for easy access to the fields.
% Each row represents a given time unit.
% Each column represents different data feature for a single channel, such as:
%        brain (e.g. HFB); taks (e.g. Math vs. Memory); behavioral (e.g. RT) or subject.
%

% Define time windows to crop
if ~isempty(cfg.time_window)
    min_time_idx = min(find(data.time >= cfg.time_window(1)));
    max_time_idx = max(find(data.time <= cfg.time_window(2)));
    time_window = min_time_idx:max_time_idx;
end


% Define which kind of data: Band vs. Spec
size_wave = size(data.wave);

enc_matrix = table;
ti = unifyTrialinfoEncoding(data.project_name, data.trialinfo);

% Band data
if length(size_wave) == 3
    trial_dim = 1;
    elect_dim = 2;
    time_dim = 3;
    
    % Crop time
    if ~isempty(cfg.time_window)       
        data.time = data.time(time_window);
        data.wave = data.wave(:,:,time_window);
    end
    
    
    n_trials = size(data.wave,trial_dim);
    n_elects = size(data.wave,elect_dim);
    n_time = size(data.wave,time_dim);
    
    
    % Basic matrix with task features
%     enc_matrix.subj_name = repmat(subjVar.sbj_name(1:6),n_trials*n_time, 1);
    task_names = {'VTCLoc', 'Scramble', 'AllCateg', 'Logo', '7Heaven', 'UCLA', 'MMR', 'MFA', 'Context', 'Calculia', 'Memoria', 'GradCPT'}';
    task = find(strcmp(data.project_name, task_names));    
    enc_matrix.task = repmat(task,n_trials*n_time, 1);
    
    % specifics
    enc_matrix.trial = reshape(repmat(1:n_trials, n_time,1), n_trials*n_time, 1);
    enc_matrix.time = repmat(data.time, 1, n_trials)';
    
    % Add brain features per electrode
    enc_matrix_brain = [];
    for i = 1:n_elects
        brain_tmp = reshape(squeeze(data.wave(:,i,:))', n_trials*n_time,1);
        % Set all nans to zeros
        brain_tmp(isnan(brain_tmp)) = 0;
        enc_matrix_brain(:,i) = brain_tmp;
    end
    
    % Plug trial info
    trialinfo_concat = repelem(ti,n_time,1);
    trialinfo_concat = [enc_matrix trialinfo_concat];
    trialinfo_concat_array = table2array(trialinfo_concat);
    % Convert to matrix 
    col_names = horzcat({'task','trial', 'time'}, ti.Properties.VariableNames);
    
else
end




end











% 
% 
% 
% 
% 
% 
% 
% 
% function [enc_matrix_el, trialinfo_concat, col_names]= convertEncodingMatrix(data, cfg)
% %% Converts data structure into a encoding matrix
% % Here this matrix is represented as a table, for easy access to the fields.
% % Each row represents a given time unit.
% % Each column represents different data feature for a single channel, such as:
% %        brain (e.g. HFB); taks (e.g. Math vs. Memory); behavioral (e.g. RT) or subject.
% %
% 
% % Define time windows to crop
% if ~isempty(cfg.time_window)
%     min_time_idx = min(find(data.time >= cfg.time_window(1)));
%     max_time_idx = max(find(data.time <= cfg.time_window(2)));
%     time_window = min_time_idx:max_time_idx;
% end
% 
% 
% % Define which kind of data: Band vs. Spec
% size_wave = size(data.wave);
% 
% enc_matrix = table;
% ti = unifyTrialinfoEncoding(data.project_name, data.trialinfo);
% 
% % Band data
% if length(size_wave) == 3
%     trial_dim = 1;
%     elect_dim = 2;
%     time_dim = 3;
%     
%     % Crop time
%     if ~isempty(cfg.time_window)       
%         data.time = data.time(time_window);
%         data.wave = data.wave(:,:,time_window);
%     end
%     
%     
%     n_trials = size(data.wave,trial_dim);
%     n_elects = size(data.wave,elect_dim);
%     n_time = size(data.wave,time_dim);
%     
%     
%     % Basic matrix with task features
% %     enc_matrix.subj_name = repmat(subjVar.sbj_name(1:6),n_trials*n_time, 1);
%     task_names = {'VTC', 'Scramble', 'AllCateg', 'Logo', '7Heaven', 'UCLA', 'MMR', 'MFA', 'Context', 'Calculia', 'Memoria', 'GradCPT'}';
%     task = find(strcmp(data.project_name, task_names));    
%     enc_matrix.task = repmat(task,n_trials*n_time, 1);
%     
%     % specifics
%     enc_matrix.trial = reshape(repmat(1:n_trials, n_time,1), n_trials*n_time, 1);
%     enc_matrix.time = repmat(data.time, 1, n_trials)';
%     
%     % Add brain features per electrode
%     enc_matrix_el = cell(n_elects,1);
%     for i = 1:n_elects
%         enc_matrix_el{i} = enc_matrix;
%         enc_matrix_el{i}.elec = repmat(data.elecs(i),n_trials*n_time, 1);
%         enc_matrix_el{i}.HFB = reshape(squeeze(data.wave(:,i,:))', n_trials*n_time,1);
%     end
%     
%     % Convert to matrix 
%     trialinfo_concat = repelem(ti,n_time,1);
%     trialinfo_concat_array = table2array(trialinfo_concat);
%     
%     for i = 1:n_elects
%         enc_matrix_el{i} =  enc_matrix_el{i}{:,:};
%         % Set all nans to zeros
%         enc_matrix_el{i}(isnan(enc_matrix_el{i})) = 0;
%         % Plug in stimuli features;
%         enc_matrix_el{i} = [enc_matrix_el{i} trialinfo_concat_array];
%     end
%     
% %     % Set all nans to zeros
% %     enc_matrix_binary = enc_matrix_el{61};
% %     enc_matrix_binary(enc_matrix_binary ~= 0) = 1;
% %     imagesc(enc_matrix_binary)
% %     xticks([1:size(enc_matrix_binary,2)]);
% %     colormap(flipud(gray))
% %     enc_matrix.Properties.VariableNames{strcmp(enc_matrix.Properties.VariableNames, 'wlist')} = 'stim';
%     
%      col_names = horzcat({'task','trial', 'time', 'elect', 'HFB'}, ti.Properties.VariableNames);
%     
%     % Spec data
% else
% end
% 
% 
% 
% 
% end