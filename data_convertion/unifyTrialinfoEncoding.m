function [ti, ti_string] = unifyTrialinfoEncoding(project_name, ti)
%%

% Task general_cond_name
% number_reading ---------------- 1
% number_identification --------- 2
% calculation_simoultaneous ----- 3
% calculation_sequential -------- 4
% memory_simoultaneous ---------- 5
% memory_sequential ------------- 6
% rest  ------------------------- 7
% attention --------------------- 8
%
%
% Number format
% digit ------------------------- 1
% number_dot -------------------- 2
% number_word ------------------- 3
%
%
% Calculation specs
% operand_1
% operand_2
% operand_min
% operand_max
% operation -------------------- 1 (addition) 2 (subtraction) 3(multiplication)
% result
% presented_result
% deviant
% abs_deviant
% cross_decade ----------------- 1 (no) 2 (yes)
% ls_sl ------------------------ 1 (l+s) 2 (s+l)
%
% Number specs
% number_of_digits
% number_ids
% size_on_screen - visual angle - to be calculatesd
%
% Memory specs
% memory type
%        autobio --------------- 1
%        other  ---------------- 2
%        self-external  -------- 3
%        self-internal  -------- 4
%        fact ------------------ 5

%
% autobio_general
% autobio_medical
% fact
% time (present, recent )


switch project_name
    case 'MMR'
        
        %% Basics
        for i = 1:size(ti,1)
            if strcmp(ti.condNames{i}, 'math')
                task_general_cond_name{i,1} = 'calculation_simultaneous';
            elseif strcmp(ti.condNames{i}, 'rest')
                task_general_cond_name{i,1} = 'rest';
            else
                task_general_cond_name{i,1} = 'memory_simultaneous';
            end
            
            % Task type
            if strcmp(ti.condNames{i}, 'rest')
                task_type{i,1} = 'passive';
            else
                task_type{i,1} = 'active';
            end
        end
        condNames = ti.condNames;
        
        
        %% Math
        % Number format
        for i = 1:size(ti,1)
            if strcmp(ti.condNames{i}, 'math')
                number_format{i,1} = 'digit';
            else
                number_format{i,1} = nan;
            end
        end
        
        operand_1 = ti.Operand1;
        operand_2 = ti.Operand2;
        operand_min = ti.OperandMin;
        operand_max = ti.OperandMax;
        operation = ti.Operator; % 1 for addition and -1 for subtraction
        result = ti.CorrectResult;
        presented_result = ti.PresResult;
        deviant = ti.Deviant;
        abs_deviant = ti.AbsDeviant;
        
        for i = 1:size(ti,1)
            if ~strcmp(ti.condNames{i}, 'math')
                operand_1(i) = nan;
                operand_2(i) = nan;
                operand_min(i) = nan;
                operand_max(i) = nan;
                operation(i) = nan;
                result(i) = nan;
                presented_result(i) = nan;
                deviant(i) = nan;
                abs_deviant(i) = nan;
            else
            end
        end
        
        for i = 1:size(ti,1)
            if deviant(i) == 0
                deviant(i) = 100;
                abs_deviant(i) = 100;
            end
        end
        
        
        % Cross decade
        for i = 1:size(ti,1)
            if strcmp(ti.condNames{i}, 'math')
                max_tmp = num2str(operand_max(i));
                res_tmp = num2str(result(i));
                if strcmp(max_tmp(1), res_tmp(1))
                    cross_decade{i,1} = 'no_cross_decade';
                else
                    cross_decade{i,1} = 'cross_decade';
                end
                
            else
                cross_decade{i,1} = nan;
            end
            
        end
        
        % Smaller + larger or larger + smaller
        for i = 1:size(ti,1)
            if strcmp(ti.condNames{i}, 'math')
                if operand_1(i) > operand_2(i)
                    ls_sl{i,1} = 'l+s';
                elseif operand_1(i) < operand_2(i)
                    ls_sl{i,1} = 's+l';
                else
                    ls_sl{i,1} = 'tie';
                end
            else
                ls_sl{i,1} = nan;
            end
        end
        
        % Number of digits
        for i = 1:size(ti,1)
            number_of_digits(i,1) = length(regexp(ti.wlist{i},'\d'));
        end
        
        % Digits ID
        for i = 1:size(ti,1)
            if ti.isCalc(i) == 1
                number_ids(i,1) = str2num([num2str(operand_1(i)) num2str(operand_2(i)) num2str(presented_result(i))]);
            else
                number_ids(i,1) = nan;
            end
        end
        
        %% Memory
        memory_type = ti.condNames;
        
        for i = 1:size(ti,1)
            if ~strcmp(ti.conds_math_memory{i}, 'memory')
                memory_type{i} = nan;
            else
            end
        end
        
        %% Behavioral performance
        for i = 1:size(ti,1)
            % Keys
            if isempty(ti.keys{i})
                keys(i,1) = nan;
            else
                if iscell(ti.keys{i})
                    ti.keys{i} = ti.keys{i}{1}
                else
                    if isempty(str2num(ti.keys{i}))
                        keys(i,1) = nan;
                    else
                        keys(i,1) = str2num(ti.keys{i});
                    end
                end
            end
        end
        % RT
        RT = ti.RT;
        RT(RT == 0) = nan;
        
        % Accuracy
        accuracy = ti.Accuracy;
        accuracy(~strcmp(ti.condNames, 'math'),:) = nan;
        accuracy(accuracy == 0) = 2;
        
        
        
    case 'Context'
        
        %% Basics
        task_general_cond_name = cellstr(repmat('calculation_sequential', size(ti,1), 1));
        task_type = cellstr(repmat('active', size(ti,1), 1));
        
        %% Math
        % Number format
        for i = 1:size(ti,1)
            if strcmp(ti.condition{i}, 'numerals')
                number_format{i,1} = 'digit';
            else
                number_format{i,1} = 'number_word';
            end
        end
        
        operand_1 = ti.operand1;
        operand_2 = ti.operand2;
        operand_min = ti.minOperand;
        operand_max = ti.maxOperand;
        operation = ti.operator; % 1 for addition and -1 for subtraction
        result = ti.corrResult;
        presented_result = ti.presResult;
        deviant = ti.Deviant;
        abs_deviant = ti.absDeviant;
        for i = 1:size(ti,1)
            if deviant(i) == 0
                deviant(i) = 100;
                abs_deviant(i) = 100;
            end
        end
        
        % Cross decade
        for i = 1:size(ti,1)
            max_tmp = num2str(operand_max(i));
            res_tmp = num2str(result(i));
            
            if length(res_tmp)==1
                cross_decade{i,1} = 'no_cross_decade';
            else
                if strcmp(max_tmp(1), res_tmp(1))
                    cross_decade{i,1} = 'no_cross_decade';
                else
                    cross_decade{i,1} = 'cross_decade';
                end
            end
        end
        
        % Smaller + larger or larger + smaller
        for i = 1:size(ti,1)
            if operand_1(i) > operand_2(i)
                ls_sl{i,1} = 'l+s';
            elseif operand_1(i) < operand_2(i)
                ls_sl{i,1} = 's+l';
            else
                ls_sl{i,1} = 'tie';
            end
        end
        
        % Digits ID
        for i = 1:size(ti,1)
            number_ids(i,1) = str2num([num2str(operand_1(i)) num2str(operand_2(i)) num2str(presented_result(i))]);
        end
        
        % Number of digits
        for i = 1:size(ti,1)
            number_of_digits(i,1) = length([num2str(operand_1(i)) num2str(operand_2(i)) num2str(presented_result(i))]);
        end
        
        
        %% Memory
        for i = 1:size(ti,1)
            memory_type{i, 1} = nan;
        end
        
        %% Behavioral performance
        for i = 1:size(ti,1)
            % Keys
            if isempty(ti.keys(i))
                keys(i,1) = nan;
            else
                if isempty(ti.keys(i))
                    keys(i,1) = nan;
                else
                    keys(i,1) = ti.keys(i);
                end
            end
        end
        % RT
        RT = ti.RT;
        RT(RT == 0) = nan;
        
        % Accuracy
        accuracy = ti.Accuracy;
        accuracy(accuracy == 0) = 2;
        
        
    case 'MFA'
        %% Basics
        task_general_cond_name = cellstr(repmat('calculation_simultaneous', size(ti,1), 1));
        task_type = cellstr(repmat('active', size(ti,1), 1));
        
        %% Math
        % Number format
        for i = 1:size(ti,1)
            if strcmp(ti.stim_type{i}, 'digit')
                number_format{i,1} = 'digit';
            elseif strcmp(ti.stim_type{i}, 'word')
                number_format{i,1} = 'number_word';
            else
                number_format{i,1} = 'number_dot';
            end
        end
        
        
        operand_1 = ti.Operand1;
        operand_2 = ti.Operand2;
        
        for i = 1:size(ti,1)
            operand_min(i,1) = min([operand_1(i), operand_2(i)]);
            operand_max(i,1) = max([operand_1(i), operand_2(i)]);
        end
        
        for i = 1:size(ti,1)
            if strcmp(ti.Operation{i}, 'add')
                operation(i,1) = 1; % 1 for addition and
            elseif strcmp(ti.Operation{i}, 'mult')
                operation(i,1) = 3; % 1 for addition and
            end
        end
        
        
        
        result = ti.CorrectResult;
        presented_result = ti.PresResult;
        deviant = ti.Deviant;
        abs_deviant = ti.AbsDeviant;
        
        
        for i = 1:size(ti,1)
            if deviant(i) == 0
                deviant(i) = 100;
                abs_deviant(i) = 100;
            end
        end
        
        % Cross decade
        for i = 1:size(ti,1)
            max_tmp = num2str(operand_max(i));
            res_tmp = num2str(result(i));
            
            if length(res_tmp)==1
                cross_decade{i,1} = 'no_cross_decade';
            else
                if strcmp(max_tmp(1), res_tmp(1))
                    cross_decade{i,1} = 'no_cross_decade';
                else
                    cross_decade{i,1} = 'cross_decade';
                end
            end
        end
        
        % Smaller + larger or larger + smaller
        for i = 1:size(ti,1)
            if operand_1(i) > operand_2(i)
                ls_sl{i,1} = 'l+s';
            elseif operand_1(i) < operand_2(i)
                ls_sl{i,1} = 's+l';
            else
                ls_sl{i,1} = 'tie';
            end
        end
        
        % Digits ID
        for i = 1:size(ti,1)
            number_ids(i,1) = str2num([num2str(operand_1(i)) num2str(operand_2(i)) num2str(presented_result(i))]);
        end
        
        % Number of digits
        for i = 1:size(ti,1)
            number_of_digits(i,1) = length([num2str(operand_1(i)) num2str(operand_2(i)) num2str(presented_result(i))]);
        end
        
        
        %% Memory
        for i = 1:size(ti,1)
            memory_type{i, 1} = nan;
        end
        
        %% Behavioral performance
        for i = 1:size(ti,1)
            % Keys
            if isempty(ti.keys{i})
                keys(i,1) = nan;
            else
                if isempty(str2num(ti.keys{i}))
                    keys(i,1) = nan;
                else
                    keys(i,1) = str2num(ti.keys{i});
                end
            end
        end
        % RT
        RT = ti.RT;
        RT(RT == 0) = nan;
        
        % Accuracy
        accuracy = ti.accuracy;
        accuracy(accuracy == 0) = 2;
        
        
    case 'ReadNumWord'
        
        a = 1
        
    case 'VTCLoc'
        task_general_cond_name = ti.condNames;
        task_type = cellstr(repmat('active', size(ti,1), 1));
        oneback = ti.oneback;
        
        
    case 'Memoria'
        
        for i = 1:size(ti,1)
            if strcmp(ti.condNames{i}, 'math')
                task_general_cond_name{i,1} = 'calculation_sequential';
            else
                task_general_cond_name{i,1} = 'memory_sequential';
            end
        end        
        task_type = cellstr(repmat('active', size(ti,1), 1));
        condNames = ti.conds_all;

        %% Math
        % Number format
        for i = 1:size(ti,1)
            if strcmp(ti.mathtype{i}, 'digit')
                number_format{i,1} = 'digit';
            else
                number_format{i,1} = 'number_word';
            end
        end
        
        operand_1 = ti.Operand1;
        operand_2 = ti.Operand2;
        operand_min = ti.OperandMin;
        operand_max = ti.OperandMax;
        operation = ti.Operator; % 1 for addition and -1 for subtraction
        result = ti.CorrectResult;
        presented_result = ti.PresResult;
        deviant = ti.Deviant;
        abs_deviant = ti.AbsDeviant;
        for i = 1:size(ti,1)
            if deviant(i) == 0
                deviant(i) = 100;
                abs_deviant(i) = 100;
            end
        end
        
        % Cross decade
        for i = 1:size(ti,1)
            max_tmp = num2str(operand_max(i));
            res_tmp = num2str(result(i));
            
            if length(res_tmp)==1
                cross_decade{i,1} = 'no_cross_decade';
            else
                if strcmp(max_tmp(1), res_tmp(1))
                    cross_decade{i,1} = 'no_cross_decade';
                else
                    cross_decade{i,1} = 'cross_decade';
                end
            end
        end
        
        % Smaller + larger or larger + smaller
        for i = 1:size(ti,1)
            if operand_1(i) > operand_2(i)
                ls_sl{i,1} = 'l+s';
            elseif operand_1(i) < operand_2(i)
                ls_sl{i,1} = 's+l';
            else
                ls_sl{i,1} = 'tie';
            end
        end
        
        %% Memory
        memory_type = ti.condNames;
        
        for i = 1:size(ti,1)
            if ~strcmp(ti.condNames{i}, 'autobio')
                memory_type{i} = nan;
            else
            end
        end
        
        
        %% Behavioral performance
        for i = 1:size(ti,1)
            % Keys
            if isempty(ti.keys(i))
                keys(i,1) = nan;
            else
                if isempty(ti.keys(i))
                    keys(i,1) = nan;
                else
                    keys(i,1) = ti.keys(i);
                end
            end
        end
        % RT
        RT = ti.RT;
        RT(RT == 0) = nan;
        
        % Accuracy
        accuracy = ti.Accuracy;
        accuracy(accuracy == 0) = 2;
        
        
        
end


ti_copy = ti;
ti = table;
ti.block = double(categorical(ti_copy.block));
ti.task_general_cond_name = task_general_cond_name;
ti.task_type = task_type;

% Original timing info
ti.StimulusOnsetTime = ti_copy.StimulusOnsetTime;
ti.allonsets = ti_copy.allonsets;
ti.RT_lock = ti_copy.RT_lock;

switch project_name
    case 'MMR'
        % Unified trialinfo
        %% Add conditions general
        conditions = unique(ti.task_general_cond_name);
        for i = 1:length(conditions)
            ti.(conditions{i}) = double(strcmp(ti.task_general_cond_name, conditions{i}));
            
        end
        
        %% Add conditions specifics
        task_specific_cond_name = ti_copy.condNames;
        conditions = task_specific_cond_name;
        for i = 1:length(conditions)
            condition_tmp = strsplit(conditions{i}, '-');
            if length(condition_tmp) == 2
                condition_tmp = [condition_tmp{1} '_' condition_tmp{2}];
            else
                condition_tmp = condition_tmp{1};
            end
            ti.(condition_tmp) = double(strcmp(task_specific_cond_name, conditions{i}));
        end
        
        
        % Math
        ti.number_format = number_format;
        ti.operand_1 = operand_1;
        ti.operand_2 = operand_2;
        ti.operand_min = operand_min;
        ti.operand_max = operand_max;
        ti.operation = operation; % 1 for addition and -1 for subtraction
        ti.ls_sl = ls_sl;
        ti.result = result;
        ti.cross_decade = cross_decade;
        ti.presented_result = presented_result;
        % ti.deviant = deviant + 1; % just to avoid 0
        ti.abs_deviant = abs_deviant + 1;
        
        % Number
        ti.number_of_digits = number_of_digits;
        % ti.number_ids = number_of_digits;
        
        % Memory
        ti.memory_type = memory_type;
        
        % Behavioral performance
        ti.RT = RT;
        ti.accuracy = accuracy; % just to avoid 0;
        
        
        
        %% Convert trialinfo table to numerical matrix
        ti_string = ti;
        ti_n = ti;
        sc = struct;
        sc.task_type = {'active', 'passive'}';
        sc.task_general_cond_name = {'n_back', 'symbol_identification', 'symbol_reading', 'calculation_simultaneous', ...
            'calculation_sequential', 'memory_simultaneous', 'memory_sequential', 'rest', 'attention'}';
        sc.number_format = {'digit'}';
        sc.cross_decade = {'no_cross_decade', 'cross_decade'}';
        sc.ls_sl = {'l+s', 's+l', 'tie'}';
        sc.memory_type = {'autobio', 'other', 'self-external', 'self-internal'}';
        
    case 'VTCLoc'
        
        conditions = unique(ti.task_general_cond_name);
        for i = 1:length(conditions)
            ti.(conditions{i}) = double(strcmp(ti.task_general_cond_name, conditions{i}));
        end
        ti.oneback = ti_copy.oneback;

        
        ti_string = ti;
        ti_n = ti;
        sc = struct;
        sc.task_type = {'active', 'passive'}';
        sc.task_general_cond_name  = conditions;
        
    case 'Memoria'
        
        conditions = unique(ti.task_general_cond_name);
        for i = 1:length(conditions)
            ti.(conditions{i}) = double(strcmp(ti.task_general_cond_name, conditions{i}));
            
        end
        
        task_specific_cond_name = ti_copy.conds_all;
        conditions = task_specific_cond_name;
        for i = 1:length(conditions)
            if ~isempty(conditions{i})
                ti.(conditions{i}) = double(strcmp(task_specific_cond_name, conditions{i}));
            else
            end
            
        end
        
        % Math
        ti.number_format = number_format;
        ti.operand_1 = operand_1;
        ti.operand_2 = operand_2;
        ti.operand_min = operand_min;
        ti.operand_max = operand_max;
        ti.operation = operation; % 1 for addition and -1 for subtraction
        ti.ls_sl = ls_sl;
        ti.result = result;
        ti.cross_decade = cross_decade;
        ti.presented_result = presented_result;
        % ti.deviant = deviant + 1; % just to avoid 0
        ti.abs_deviant = abs_deviant + 1;
        
        % Number
        %         ti.number_of_digits = number_of_digits;
        % ti.number_ids = number_of_digits;
        
        % Memory
        ti.memory_type = memory_type;
        
        % Behavioral performance
        ti.RT = RT;
        ti.accuracy = accuracy; % just to avoid 0;
        
        ti_string = ti;
        ti_n = ti;
        sc = struct;
        sc.task_type = {'active', 'passive'}';
        sc.task_general_cond_name = {'n_back', 'symbol_identification', 'symbol_reading', 'calculation_simultaneous', ...
            'calculation_sequential', 'memory_simultaneous', 'memory_sequential', 'rest', 'attention'}';
        sc.number_format = {'digit', 'number_word', 'number_dot'}';
        sc.cross_decade = {'no_cross_decade', 'cross_decade'}';
        sc.ls_sl = {'l+s', 's+l', 'tie'}';
        sc.memory_type = {'autobio', 'other', 'self-external', 'self-internal'}';
        
        
end

sc_vars = fieldnames(sc);

tmp = table;
for i = 1:length(sc_vars)
    for ii = 1:size(ti,1)
        tmp_val = find(strcmp(ti.(sc_vars{i}){ii}, sc.(sc_vars{i})))-1;
        if ~isempty(tmp_val)
            tmp.(sc_vars{i})(ii,1) = tmp_val;
        else
            tmp.(sc_vars{i})(ii,1) = nan;
        end
    end
    ti_n.(sc_vars{i}) = tmp.(sc_vars{i});
end


%% merge back to original table
for i = 1:length(sc_vars)
    ti.(sc_vars{i}) = tmp.(sc_vars{i});
end

% Convert NaN to 0.
ti_names = ti.Properties.VariableNames;
for i = 1:length(ti_names)
    ti.(ti_names{i})(isnan(ti.(ti_names{i}))) = 0;
end



end

