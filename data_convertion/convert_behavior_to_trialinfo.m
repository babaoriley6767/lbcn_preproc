%%
function convert_behavior_to_trialinfo(sbj_name,project_name, block_names, dirs)

%% Convert berhavioral data to trialinfo
switch project_name
    case 'Calculia_SingleDigit'
        %         OrganizeTrialInfoMMR(sbj_name, project_name, block_names, dirs) %%% FIX TIMING OF REST AND CHECK ACTUAL TIMING WITH PHOTODIODE!!! %%%
        OrganizeTrialInfoCalculia(sbj_name, project_name, block_names, dirs) %%% FIX ISSUE WITH TABLE SIZE, weird, works when separate, loop clear variable issue
    case 'UCLA'
        OrganizeTrialInfoUCLA(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds? INCLUDE REST!!!
    case 'MMR'
        OrganizeTrialInfoMMR_rest(sbj_name, project_name, block_names, dirs) %%% FIX ISSUE WITH TABLE SIZE, weird, works when separate, loop clear variable issue
    case 'Memoria'
        language = 'english'; % make this automnatize by sbj_name
        OrganizeTrialInfoMemoria(sbj_name, project_name, block_names, dirs, language)
    case {'Calculia_China', 'Calculia_letter'}
        OrganizeTrialInfoCalculiaChina(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
    case 'Calculia_production'
        OrganizeTrialInfoCalculia_production(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
    case 'Calculia_production_stim'
        OrganizeTrialInfoCalculia_production(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
        
    case 'Number_comparison'
        OrganizeTrialInfoNumber_comparison(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
    case 'MFA'
        OrganizeTrialInfoMFA(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
    case 'Calculia'
        OrganizeTrialInfoCalculia_combined(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
    case 'Context'
        OrganizeTrialInfoContext(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
    case 'EglyDriver'
        OrganizeTrialInfo_EglyDriver(sbj_name, project_name, block_names, dirs) % FIX 1 trial missing from K.conds?
        
    case 'VTCLoc'
        OrganizeTrialInfoVTC(sbj_name, project_name, block_names, dirs)
        
end

