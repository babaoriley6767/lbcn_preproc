function trialinfo = UpdateTrialinfoParams(trialinfo,project_name)

% Specifics of each project
switch project_name
    case 'Calculia'
        trialinfo.keys = [];
        for i = 1:size(trialinfo,1)
            if trialinfo.isActive(i) == 1
                trialinfo.condNames(i) = {[trialinfo.condNames{i} '_active']};
            else
                trialinfo.condNames(i) = {[trialinfo.condNames{i} '_passive']};
            end
        end
        
    case 'Context'
        trialinfo.condNames2 = trialinfo.condNames;
        trialinfo.condNamesBasic = trialinfo.condNames;
        for i = 1:size(trialinfo,1)
            if trialinfo.isActive(i) == 1
                trialinfo.condNames(i) = {[trialinfo.condition{i} '_active']};
                trialinfo.condNamesBasic(i) = {'active'};
            else
                trialinfo.condNames(i) = {[trialinfo.condition{i} '_passive']};
                trialinfo.condNamesBasic(i) = {'passive'};
            end
        end
        
    case 'EglyDriver'
        %             interval_tmp = discretize(trialinfo.int_cue_targ_time, 5);
        %             trialinfo.condNames_interval = cellstr(num2str(interval_tmp));
        for i = 1:size(trialinfo,1)
            if trialinfo.cue_pos(i) == 1 || trialinfo.cue_pos(i) == 2
                trialinfo.CondNamesCueLoc{i} = [trialinfo.CondNames{i} '_left'];
            else
                trialinfo.CondNamesCueLoc{i} = [trialinfo.CondNames{i} '_right'];
            end
        end
        
    case 'EglyDriver_stim'
        for i = 1:size(trialinfo,1)
            if trialinfo.TTL(i,3) == 128
                trialinfo.CondNames{i} = [trialinfo.CondNames{i} '_stim'];
            else
                trialinfo.CondNames{i} = [trialinfo.CondNames{i} '_nostim'];
            end
        end
        
    case 'Calculia_China'
        trialinfo.operator = trialinfo.operator_inv.*-1;
        
        for i = 1:size(trialinfo,1)
            if trialinfo.operator(i) == 1
                trialinfo.condNames{i,1} = 'Addition';
            elseif trialinfo.operator(i) == -1
                trialinfo.condNames{i,1} = 'Subtraction';
            end
        end
        
    case 'MMR'
        for ii = 1:size(trialinfo,1)
            % Add cross decade
            maxstr = num2str(trialinfo.OperandMax(ii));
            resstr = num2str(trialinfo.CorrectResult(ii));
            if strcmp(maxstr(1), resstr(1)) & ~strcmp('0', resstr(1))
                trialinfo.CrossDecade(ii) = 1 ;
            else
                trialinfo.CrossDecade(ii) = 0;
            end
            % Add SL or LS
            if num2str(trialinfo.Operand1(ii)) > num2str(trialinfo.Operand2(ii))
                trialinfo.OpOrder{ii} = 'L+S' ;
            else
                trialinfo.OpOrder{ii} = 'S+L' ;
            end
        end
end


end

