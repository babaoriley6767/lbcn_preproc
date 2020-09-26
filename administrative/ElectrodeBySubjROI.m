function [elec_names,elec_nums] = ElectrodeBySubjROI(sbj,region)

switch region
    case 'PMC'
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {'LP2';'LP3';'LPI12';'LPI13';'LPS1';'LPS3';};
                elec_nums =[34:35 43 44 53 55];
            case 'S16_99_CJ'
                elec_names = {'LRS2';'LRS3';'LRS4';'LRS5'};
                elec_nums =[52:55];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {'LPC1';'LPC2'};
                elec_nums =[51 52];
            case 'S17_112_EA'
                elec_names ={'LPCI1';'LPCI2';'LPCI3';'LPCI4'};
                elec_nums =[45 46 47 48];
            case 'S17_116'
                elec_names={'RPT1'};
                elec_nums =[113];
            case {'S17_118_TW','S17_118'}
                elec_names ={'LRSC1';'LRSC2';'LRSC3'};%;
                elec_nums =[51 52 53];
            case {'S18_119_AG','S18_119'}
                %                 elec_names ={'LCINP1';'LCINP2';'LCINP3';'RCINP1'};%;'RCINP2';'RCINP3'};
                elec_names ={'LRSC1';'LRSC2';'LRSC3';'RRSC1'};
                elec_nums = [71:73 111];%111:113];
            case {'S18_124_JR2','S18_124'}
                elec_names= {'LDP1';'LDP2';'LDP3';'RDP1'};
                elec_nums = [77 78 79 107];
            case 'S18_125'
                elec_names ={'RPC1';'RPC2'};
                elec_nums =[47 48];
            case 'S18_126'
                elec_names ={};
                elec_nums =[];
            case 'S18_127'
                elec_names ={'LPC1';'LPC2';'LPC3'};
                elec_nums =[51 52 53];
            case {'S18_128_CG','S18_128'}
                elec_names ={'LPOC1';'LPOC2';'LPOC3';'LPOC4'};
                elec_nums =[41:44];
            case 'S18_129'
                elec_names = {};
                elec_nums=[];
            case {'S18_130_RH','S18_130'}
                elec_names = {'LCIN10'};
                elec_nums=[40];
            case 'S18_131'
                elec_names = {'LPC2','LPC3','LPC4','RPC1','RPC2','RPC3','RPC4','RPC5'};
                elec_nums=[55:57 44:48];
                
            case 'S13_47_JT2'
                elec_names ={'51','52','53','54','55','56','57','58','59','60','61','62'};
                elec_nums =[51:62 11 ];
            case 'S12_42_NC'
                elec_names ={'73','74','75','76','81','82','83','84','85'};
                elec_nums =[73:76 81:85];
            case 'S12_38_LK'
                elec_names ={'65','66','67','68','69','70','71','72','73','74','81','82','83','84','85','86','87','88','89'};
                elec_nums =[65:74 81:89];
            case 'S12_33_DA'
                elec_names ={'65','66','67','68','69','70','73','74','81','82','83','84','85','86','87'};
                elec_nums =[65:70 81:87];
                
                
        end
        
    case 'mPFC'
        
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {'LOF1';'LOF2'};
                elec_nums =[21 22];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {'RIF1','RSF1','RSF2'};
                elec_nums =[89 97 98];
            case 'S17_110_SC'
                elec_names = {'LOF1';'LOF2'};
                elec_nums =[1 2];
            case 'S17_112_EA'
                elec_names ={'LACI1'};
                elec_nums =[35];
            case 'S17_116'
                elec_names={};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={'LOFCa2','LOFCp1'};
                elec_nums =[32 41];
            case {'S18_119_AG','S18_119'}
                %                 elec_names ={'LOF1','LOF2'};
                elec_names ={'LaORB1','LaORB2'};
                elec_nums = [51 52];
            case {'S18_124_JR2','S18_124'}
                elec_names ={};
                elec_nums = [];
            case 'S18_125'
                elec_names ={''};
                elec_nums =[];
            case 'S13_47_JT2'
                elec_names ={'16','17','18','19','20'};
                elec_nums =[16:20];
            case 'S12_42_NC'
                elec_names ={'65','66','67','68','69','70','71','72'};
                elec_nums =[65:72];
            case 'S12_38_LK'
                elec_names ={'97','98','99','100','101','102','103','104'};
                elec_nums =[97:104];
            case 'S12_33_DA'
                elec_names ={'97','98','99','100','101','102','103','104','105','106'};
                elec_nums =[97:106];
            case 'S18_126'
                elec_names ={};
                elec_nums =[];
                
            case 'S18_127'
                elec_names ={};
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={};
                elec_nums =[];
            case 'S18_129'
                elec_names = {};
                elec_nums=[];
                
            case {'S18_130_RH','S18_130'}
                elec_names ={'LOFL6','LOFL7'};%,
                elec_nums =[6 7];
                
            case 'S18_131'
                elec_names = {'LAC1','LAC2','LAC3','LAC4','LAC5','LAC6','LAC7','LAC8','LAC9','RAC1','RAC2','RAC3'};
                elec_nums=[99:107 30:32];
                
        end
        
    case 'OFC'
        
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {'LOF1';'LOF2'};
                elec_nums =[21 22];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {};
                elec_nums =[];
            case 'S17_112_EA'
                elec_names ={'LACI1'};
                elec_nums =[35];
            case 'S17_116'
                elec_names={};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={'LOFCp1'};
                elec_nums =[];
            case {'S18_119_AG','S18_119'}
                elec_names ={'LaORB1','LaORB2'};
                elec_nums = [51 52];
            case {'S18_124_JR2','S18_124'}
                elec_names ={};
                elec_nums = [];
            case 'S18_125'
                elec_names ={''};
                elec_nums =[];
                
            case 'S18_126'
                elec_names ={};
                elec_nums =[];
                
            case 'S18_127'
                elec_names ={};
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={};
                elec_nums =[];
            case 'S18_129'
                elec_names = {};
                elec_nums=[];
                
            case {'S18_130_RH','S18_130'}
                elec_names ={'LOFL6','LOFL7'};%,
                elec_nums =[6 7];
                
            case 'S18_131'
                elec_names = {};
                elec_nums=[];
                
        end
        
    case 'vmPFC'
        
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {};
                elec_nums =[];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {};
                elec_nums =[];
            case 'S17_112_EA'
                elec_names ={};
                elec_nums =[];
            case 'S17_116'
                elec_names={};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={'LOFCa2'};
                elec_nums =[];
            case {'S18_119_AG','S18_119'}
                elec_names ={};
                elec_nums = [];
            case {'S18_124_JR2','S18_124'}
                elec_names ={};
                elec_nums = [];
            case 'S18_125'
                elec_names ={''};
                elec_nums =[];
                
            case 'S18_126'
                elec_names ={};
                elec_nums =[];
                
            case 'S18_127'
                elec_names ={};
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={};
                elec_nums =[];
            case 'S18_129'
                elec_names = {};
                elec_nums=[];
                
            case {'S18_130_RH','S18_130'}
                elec_names ={};%,
                elec_nums =[];
                
            case 'S18_131'
                elec_names = {};
                elec_nums=[];
                
        end
        
    case 'dmPFC'
        
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {};
                elec_nums =[];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {'RIF1','RSF1','RSF2'};
                elec_nums =[89 97 98];
            case 'S17_110_SC'
                elec_names = {};
                elec_nums =[];
            case 'S17_112_EA'
                elec_names ={'LACI1'};
                elec_nums =[35];
            case 'S17_116'
                elec_names={};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={'LOFCa2','LOFCp1'};
                elec_nums =[32 41];
            case {'S18_119_AG','S18_119'}
                elec_names ={};
                elec_nums = [];
            case {'S18_124_JR2','S18_124'}
                elec_names ={};
                elec_nums = [];
            case 'S18_125'
                elec_names ={''};
                elec_nums =[];
            case 'S18_126'
                elec_names ={};
                elec_nums =[];
                
            case 'S18_127'
                elec_names ={};
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={};
                elec_nums =[];
            case 'S18_129'
                elec_names = {};
                elec_nums=[];
                
            case {'S18_130_RH','S18_130'}
                elec_names ={};%,
                elec_nums =[6 7];
                
            case 'S18_131'
                elec_names = {'LAC1','LAC2','LAC3','LAC4','LAC5','LAC6','LAC7','LAC8','LAC9','RAC1','RAC2','RAC3'};
                elec_nums=[99:107 30:32];
                
        end
        
    case 'Hipp' %hippocampus
        switch sbj
            
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {'LHH2','LHH3'};
                elec_nums =[12 13 ];
            case 'S16_100_AF'
                elec_names = {'LAH1','LAH2','RAH2'};
                elec_nums =[11:12 122];
            case 'S17_105_TA'
                elec_names = {};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {'RH1','RH2','LH1','LH2','LH3'};
                elec_nums =[71 72 21:23];
            case 'S17_112_EA'
                elec_names ={'RAH1','RAH2','RAH3','RAH4'};%
                elec_nums =[55 56 57 58];%55
            case 'S17_116'
                elec_names={};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={'RAH1','RAH2'};
                elec_nums =[98 99];
            case {'S18_119_AG','S18_119'}
                %                 elec_names ={'LHT22','LHT23','LHT24'};%,'RHIP2','RHIP3'};
                elec_names ={'LaHIP2','LaHIP3','LaHIP4'};
                elec_nums = [32 33 34];%92 93];
            case {'S18_124_JR2','S18_124'}
                elec_names ={'LHA1','LHA2','LHA3','LMH1','LMH2','LMH3','LPH2','LPH3'};
                elec_nums = [7 8 9 17 18 19 28 29];
            case 'S18_125'
                elec_names ={'RPH2','RPH3'};
                elec_nums =[2 3];
            case 'S13_47_JT2'
                elec_names ={};
                elec_nums =[];
            case 'S12_42_NC'
                elec_names ={};
                elec_nums =[];
            case 'S12_38_LK'
                elec_names ={};
                elec_nums =[];
            case 'S12_33_DA'
                elec_names ={};
                elec_nums =[];
            case 'S18_126'
                elec_names ={'LMH1','LMH2','LMH3','LMH4','LPH1','LPH4','RMH2','RPH2'};
                elec_nums =[19:22 27 66 74];
                
            case 'S18_127'
                elec_names ={'LH1','LH2','LH3'};%,'RH1','RH2'
                elec_nums =[11:13];% 81 82
            case {'S18_128_CG','S18_128'}
                elec_names ={};
                elec_nums =[];
            case 'S18_129'
                elec_names = {'RHI2','RHI3','RPHI3','RPHI4'};
                elec_nums=[];
                
            case {'S18_130_RH','S18_130'}
                %                 elec_names ={'LAMY2','LAMY3','LAMY4'};% ,'RPMT2','RPMT3','RAMY2','RAMY3','RAMY4','RAMY5'
                elec_names ={'LAMY3','LAMY4'};
                %                 elec_nums =[22 23 24];% 93 94 83:86
                elec_nums =[23 24];
                
            case 'S18_131'
                elec_names = {'LAH1'};%,'RAHb1'
                elec_nums=[1];% 65
        end
    case 'Vis' % general visual/attn
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {'LP6','LP7','LP8','LP9'};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {};
                elec_nums =[];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {'RLG31','RLG38','RLG41','RLG44','ROC5'};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {'LTP2','LTP3','LTP4','LTP5','LTP6','LTP7','LTP8','RO4','RO5','RO6','RO7','RO8','RO9','RP5','RP6','RP7','RP8'}; % 'RAC8','RAC9','RAC10','LIN1','LIN2',,'RMC10'
                elec_nums =[];
            case 'S17_112_EA'
                elec_names ={'LPCI6','LSTG7','LSTG8'};
                elec_nums =[];
            case 'S17_116'
                elec_names={};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={'LINSa7','LINSa8','RCINm3','RINSa7','RINSa8','RINSa9','RINSa10'};%;
                elec_nums =[];
            case {'S18_119_AG','S18_119'}
                elec_names ={'LRSC8','LRSC9'};
                elec_nums = [];%111:113];
            case {'S18_124_JR2','S18_124'}
                elec_names= {'LDP6','LDP7','LDP8'};
                elec_nums = [];
            case 'S18_125'
                elec_names ={};
                elec_nums =[];
            case 'S18_126'
                elec_names ={}; % none
                elec_nums =[];
            case 'S18_127'
                elec_names ={}; % 'LPC8'?
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={}; % none
                elec_nums =[];
            case 'S18_129'
                elec_names = {}; % none
                elec_nums=[];
            case {'S18_130_RH','S18_130'}
                elec_names = {}; % none
                elec_nums=[];
            case 'S18_131'
                elec_names = {}; % none
                elec_nums=[];
                
            case 'S13_47_JT2'
                elec_names ={};
                elec_nums =[];
            case 'S12_42_NC'
                elec_names ={};
                elec_nums =[];
            case 'S12_38_LK'
                elec_names ={};
                elec_nums =[];
            case 'S12_33_DA'
                elec_names ={};
                elec_nums =[];
                
        end
    case 'Par'
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {'LLP7','LLP8','LPI35','LPI36','LPI37','LPI38','LPI46','LPI47','LPI48','LP6','LP7','LP8','LP9','LP10',...
                    'LPI16','LPI17','LPI18','LPI19','LPI110','LPS6','LPS7','LPS8','LPS9','LPS10','LPI26','LPI27'};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {'LRS10'};
                elec_nums =[];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {'RLG1','RLG2','RLG3','RLG9','RLG10','RLG11','RLG17','RLG18'};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {'RP8','RP9','LPC7','LPC8','LPC9'};
                elec_nums =[];
            case 'S17_112_EA'
                elec_names ={'LPCIN8','LPCIN9','LPCIN10'};
                elec_nums =[];
            case 'S17_116'
                elec_names={'RPG1','RPG2','RPG3','RPG9','RPG10','RPG11','RPG17','RPG18','RPG19','RPG20'};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={};%;
                elec_nums =[];
            case {'S18_119_AG','S18_119'}
                elec_names ={'LCINP8','LCINP9','LCINP10','RCINP6'};%,'LRS'};
                elec_nums = [78 79 80 116];%92 93];
            case {'S18_124_JR2','S18_124'}
                elec_names ={'LDP6','LDP7','LDP8'};
                elec_nums = [82 83];
            case 'S18_126'
                elec_names ={''};
                elec_nums =[];
            case 'S18_127'
                elec_names ={''};
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={''};
                elec_nums =[];
            case {'S18_129'}
                 elec_names ={'RPCI8','RPCI9','RPCI10'};
                 elec_nums =[];
            case {'S18_130_RH','S18_130'}
                elec_names ={''};
                elec_nums =[];
            case 'S18_131'
                elec_names = {''};
                elec_nums=[];
        end
    case 'Occ'
        switch sbj
            case {'S14_69_RTb','S14_69b_RT'}
                elec_names = {};
                elec_nums =[];
            case 'S16_99_CJ'
                elec_names = {};
                elec_nums =[];
            case 'S16_100_AF'
                elec_names = {};
                elec_nums =[];
            case 'S17_105_TA'
                elec_names = {'ROC1','ROC2','ROC3','ROC4','ROC5','ROC6','RLG49',',RLG50','RLG57','RLG58'};
                elec_nums =[];
            case 'S17_110_SC'
                elec_names = {'RO1','RO2','RO6','RO7','RO8','RO9'};
                elec_nums =[];
            case 'S17_112_EA'
                elec_names ={};
                elec_nums =[];
            case 'S17_116'
                elec_names={'RO1','RO2','RO3','RO4','RO5','RO6','RO7','RO8','RO9','RO10','RO11','RO12','RO13','RO14','RO15','RO16'};
                elec_nums =[];
            case {'S17_118_TW','S17_118'}
                elec_names ={};%;
                elec_nums =[];
            case {'S18_119_AG','S18_119'}
                elec_names ={''};%,'LRS'};
                elec_nums = [];%92 93];
            case {'S18_124_JR2','S18_124'}
                elec_names ={''};
                elec_nums = [];
            case 'S18_126'
                elec_names ={''};
                elec_nums =[];
            case 'S18_127'
                elec_names ={''};
                elec_nums =[];
            case {'S18_128_CG','S18_128'}
                elec_names ={''};
                elec_nums =[];
                case {'S18_129'}
                 elec_names ={''};
                 elec_nums =[];
            case {'S18_130_RH','S18_130'}
                elec_names ={''};
                elec_nums =[];
            case 'S18_131'
                elec_names = {''};
                elec_nums=[];
        end
        
        
end
