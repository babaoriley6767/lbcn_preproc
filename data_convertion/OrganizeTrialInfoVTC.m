function OrganizeTrialInfoVTC(sbj_name, project_name, block_names, dirs)

warning('off','all')

for ci = 1:length(block_names)
    %second block always starts at the 420 point and third block always
    %starts at the 840 point; this is resolved using the OrganizeTrialInfoVTCExceptions
    %Note there are multiple versions of VTC that have been run in the lab
    
    bn = block_names{ci};
    
    %% Load globalVar
    load(sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,bn));
    
    % Load behavioral file
    soda_name = dir(fullfile(globalVar.psych_dir, 'sodata*.mat'));
    K = load([globalVar.psych_dir '/' soda_name.name]);
    
    
    % start trialinfo
    trialinfo = table;
%     ntrials = K.trial;
%     [K,ntrials] = OrganizeTrialInfoVTCExceptions(sbj_name,bn,K,ntrials);
    K.theData = K.theData(K.starttrial:K.endtrial);
    ntrials = (K.endtrial - K.starttrial) +1;
    
    for i = 1:ntrials
        
        
        if isfield(K.theData(i), 'red') %for older patients
            trialinfo.isActive(i) = 0;
            if ~isempty(K.theData(i).red.RT) %only get key when there is a reaction time
                trialinfo.RT(i,1) = K.theData(i).red.RT;
                
                temp_key = num2str(K.theData(i).red.keys);
                switch temp_key
                    case 'DownArrow'
                        K.theData(i).red.keys='2';
                    case 'End'
                        K.theData(i).red.keys='1';
                    case 'noanswer'
                        K.theData(i).red.keys='NaN';
                    case '2@'
                        K.theData(i).red.keys='2';
                    case '1!'
                        K.theData(i).red.keys='1';
                end
                trialinfo.keys(i) = str2num(K.theData(i).red.keys);
            else
                trialinfo.RT(i)=NaN;
                trialinfo.keys(i)=NaN;
            end
            
        else %for newer patients
            trialinfo.isActive(i) = 1;
            if ~isempty(K.theData(i).keys)
                temp_key = char(K.theData(i).keys(1));
                switch temp_key
                    case 'noanswer'
                        K.theData(i).keys = 'NaN';
                end
                trialinfo.keys{i}=K.theData(i).keys(1);
            else
                trialinfo.keys{i}={NaN};
            end
            
            if K.theData(i).RT==0
                trialinfo.RT(i)=NaN;
            else
                trialinfo.RT(i) = K.theData(i).RT(1);
            end
            
        end
        
        
        trialinfo.StimulusOnsetTime(i) = K.theData(i).flip.StimulusOnsetTime;
        trialinfo.stimlist(i) = K.stimlist(i)';
        temp = extractBefore(trialinfo.stimlist(i), '.png');
        if contains(temp, ' copy')
            temp = extractBefore(trialinfo.stimlist(i), ' copy');
        else
        end
        length_temp = strlength(temp);
        stim_temp = extractBefore(temp, length_temp-1);
        num_temp = string(regexp(temp, '\d+', 'match'));
        num = str2num(num_temp);
        %going to use this for the number part of it
        
        
        %newer version of VTC
        if 1071<=num && num<=1080
            trialinfo.condNames_long{i} = 'bird_bodies';
            trialinfo.condNames{i} = 'bodies';
        elseif 1061<=num && num<=1070
            trialinfo.condNames_long{i} = 'bird_bodies';
            trialinfo.condNames{i} = 'bodies';
        elseif 1121<=num && num<=1130
            trialinfo.condNames_long{i} = 'buildings';
            trialinfo.condNames{i} = 'buildings_scenes';
        elseif 1101<=num && num<=1110
            trialinfo.condNames_long{i} = 'cars_from_front';
            trialinfo.condNames{i} = 'objects';
        elseif 1141<=num && num<=1150
            trialinfo.condNames_long{i} = 'cars_from_side';
            trialinfo.condNames{i} = 'objects';
        elseif 1151<=num && num<=1160
            trialinfo.condNames_long{i} = 'chairs';
            trialinfo.condNames{i} = 'objects';
        elseif 1101<=num && num<=1110
            trialinfo.condNames_long{i} = 'cars_from_front';
            trialinfo.condNames{i} = 'objects';
        elseif 1211<=num && num<=1220
            trialinfo.condNames_long{i} = 'Chinese_false_fonts';
            trialinfo.condNames{i} = 'falsefonts';
        elseif 1201<=num && num<=1210
            trialinfo.condNames_long{i} = 'Chinese_pseudowords';
            trialinfo.condNames{i} = 'falsefonts';
        elseif 1191<=num && num<=1200
            trialinfo.condNames_long{i} = 'Chinese_words';
            trialinfo.condNames{i} = 'words';
        elseif 1161<=num && num<=1170
            trialinfo.condNames_long{i} = 'false_fonts';
            trialinfo.condNames{i} = 'falsefonts';
        elseif 1171<=num && num<=1180
            trialinfo.condNames_long{i} = 'hands';
            trialinfo.condNames{i} = 'bodies';
        elseif 1091<=num && num<=1100
            trialinfo.condNames_long{i} = 'human_bodies';
            trialinfo.condNames{i} = 'bodies';
        elseif 1081<=num && num<=1090
            trialinfo.condNames_long{i} = 'human_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1111<=num && num<=1120
            trialinfo.condNames_long{i} = 'logos';
            trialinfo.condNames{i} = 'logos';
        elseif 1081<=num && num<=1090
            trialinfo.condNames_long{i} = 'human_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1051<=num && num<=1060
            trialinfo.condNames_long{i} = 'mammal_bodies';
            trialinfo.condNames{i} = 'bodies';
        elseif 1081<=num && num<=1090
            trialinfo.condNames_long{i} = 'human_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1041<=num && num<=1050
            trialinfo.condNames_long{i} = 'mammal_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1181<=num && num<=1190
            trialinfo.condNames_long{i} = 'natural_scenes';
            trialinfo.condNames{i} = 'buildings_scenes';
        elseif 1031<=num && num<=1040
            trialinfo.condNames_long{i} = 'numbers';
            trialinfo.condNames{i} = 'numbers';
        elseif 1221<=num && num<=1230
            trialinfo.condNames_long{i} = 'primate_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1011<=num && num<=1020
            trialinfo.condNames_long{i} = 'pseudowords';
            trialinfo.condNames{i} = 'words';
        elseif 1081<=num && num<=1090
            trialinfo.condNames_long{i} = 'human_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1231<=num && num<=1253
            trialinfo.condNames_long{i} = 'scrambled_images';
            trialinfo.condNames{i} = 'scrambled_images';
        elseif 1131<=num && num<=1140
            trialinfo.condNames_long{i} = 'shapes';
            trialinfo.condNames{i} = 'shapes';
        elseif 1081<=num && num<=1090
            trialinfo.condNames_long{i} = 'human_faces';
            trialinfo.condNames{i} = 'faces';
        elseif 1021<=num && num<=1030
            trialinfo.condNames_long{i} = 'tools';
            trialinfo.condNames{i} = 'objects';
        elseif 1001<=num && num<=1010
            trialinfo.condNames_long{i} = 'words';
            trialinfo.condNames{i} = 'words';
            
            %old version of VTC
        elseif 28<=num && num<=36
            trialinfo.condNames_long{i} = 'animals';
            trialinfo.condNames{i} = 'animals';
        elseif 37<=num && num<=45
            trialinfo.condNames_long{i} = 'faces';
            trialinfo.condNames{i} = 'faces';
        elseif 19<=num && num<=27
            trialinfo.condNames_long{i} = 'falsefonts';
            trialinfo.condNames{i} = 'falsefonts';
        elseif 55<=num && num<=63
            trialinfo.condNames_long{i} = 'animals';
            trialinfo.condNames{i} = 'animals';
        elseif 55<=num && num<=63
            trialinfo.condNames_long{i} = 'animals';
            trialinfo.condNames{i} = 'animals';
        elseif 01<=num && num<=09
            trialinfo.condNames_long{i} = 'numbers';
            trialinfo.condNames{i} = 'numbers';
        elseif 46<=num && num<=54
            trialinfo.condNames_long{i} = 'places';
            trialinfo.condNames{i} = 'places';
        elseif 64<=num && num<=72
            trialinfo.condNames_long{i} = 'spanish_words';
            trialinfo.condNames{i} = 'words';
        elseif 10<=num && num<=18
            trialinfo.condNames_long{i} = 'words';
            trialinfo.condNames{i} = 'words';
        else
        end
        
        
        %decode the numbers
        if strcmp(trialinfo.condNames{i}, 'numbers')
            if num==1031
                trialinfo.stim{i} = '179';
            elseif num==1032
                trialinfo.stim{i} = '258';
            elseif num==1033
                trialinfo.stim{i} = '339';
            elseif num==1034
                trialinfo.stim(i) = "362";
            elseif num==1035
                trialinfo.stim{i} = '406';
            elseif num==1036
                trialinfo.stim{i} = '504';
            elseif num==1037
                trialinfo.stim{i} = '587';
            elseif num==1038
                trialinfo.stim{i} = '610';
            elseif num==1039
                trialinfo.stim{i} = '841';
            elseif num==1032
                trialinfo.stim{i} = '972';
                
                %for older version
            elseif num==01
                trialinfo.stim{i} = '135';
            elseif num==02
                trialinfo.stim{i} = '242';
            elseif num==03
                trialinfo.stim{i} = '329';
            elseif num==04
                trialinfo.stim{i} = '474';
            elseif num==05
                trialinfo.stim{i} = '563';
            elseif num==06
                trialinfo.stim{i} = '687';
            elseif num==07
                trialinfo.stim{i} = '725';
            elseif num==08
                trialinfo.stim{i} = '892';
            else
            end
        else
            trialinfo.stim(i) = strcat(trialinfo.condNames{i},'_',num_temp);
        end
        
        
        %Earlier version of VTC was passive
        if isfield(K.theData, 'oneback') == 1
            if ~isempty(K.theData(i).oneback)
                trialinfo.oneback(i) = K.theData(i).oneback;
            else
                trialinfo.oneback(i) = NaN;
            end
            %Correct - if oneback & pressed is 1
            if ~isempty(K.theData(i).oneback)
                if K.theData(i).oneback==0 && strcmp(K.theData(i).keys, 'NaN')
                    trialinfo.isCorrect(i)=1;
                elseif  K.theData(i).oneback==1 && strcmp(K.theData(i).keys(1), '1')
                    trialinfo.isCorrect(i)=1;
                else
                    trialinfo.isCorrect(i)=0;
                end
            else
                trialinfo.isCorrect(i)=0;
            end
        else
            trialinfo.oneback(i) = NaN;
            trialinfo.isCorrect(i) = NaN;
        end
        
        %patient pressed paused so shortened trial
        if strcmp(sbj_name, 'S18_125_LU') && strcmp(project_name, 'VTCLoc') && strcmp(bn,'E18-542_0003')
            trialinfo(381:end,:) = [];
        else
        end
        
        
    end
    save([globalVar.psych_dir '/trialinfo_', bn '.mat'], 'trialinfo');
end
end

