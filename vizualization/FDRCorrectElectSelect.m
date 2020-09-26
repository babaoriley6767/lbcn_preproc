function elinfo = FDRCorrectElectSelect(elinfo, conds)
%% elinfo with all channels and subjects concated. 

% FDR correction
sc1c2_FDR_all = mafdr(elinfo.sc1c2_Pperm, 'BHFDR', true);
sc1b1_FDR_all = mafdr(elinfo.sc1b1_Pperm, 'BHFDR', true);
sc2b2_FDR_all = mafdr(elinfo.sc2b2_Pperm, 'BHFDR', true);

for ii = 1:size(elinfo,1)
    if sc1c2_FDR_all(ii) <0.05 && elinfo.sc1c2_tstat(ii) > 0 && sc1b1_FDR_all(ii) <0.05 && elinfo.sc1b1_tstat(ii) > 0 && sc2b2_FDR_all(ii) > 0.05
        elect_select_FDR_all{ii,1} = [conds{1} ' only'];
    elseif sc1c2_FDR_all(ii) <0.05 && elinfo.sc1c2_tstat(ii) > 0 && sc1b1_FDR_all(ii) <0.05 && elinfo.sc1b1_tstat(ii) > 0 && sc2b2_FDR_all(ii) < 0.05 && elinfo.sc2b2_tstat(ii) > 0
        elect_select_FDR_all{ii,1} = [conds{1} ' selective and ' conds{2} ' act'];
    elseif sc1c2_FDR_all(ii) <0.05 && elinfo.sc1c2_tstat(ii) > 0 && sc1b1_FDR_all(ii) <0.05 && elinfo.sc1b1_tstat(ii) > 0 && sc2b2_FDR_all(ii) < 0.05 && elinfo.sc2b2_tstat(ii) < 0
        elect_select_FDR_all{ii,1} = [conds{1} ' selective and ' conds{2} ' deact'];
    
    elseif sc1c2_FDR_all(ii) > 0.05 && sc1b1_FDR_all(ii) <0.05 && elinfo.sc1b1_tstat(ii) > 0 && sc2b2_FDR_all(ii) < 0.05 && elinfo.sc2b2_tstat(ii) > 0
        elect_select_FDR_all{ii,1} = [conds{1} ' and ' conds{2}];
        
    elseif sc1c2_FDR_all(ii) <0.05 && elinfo.sc1c2_tstat(ii) < 0 && sc1b1_FDR_all(ii) > 0.05 && sc2b2_FDR_all(ii) < 0.05 && elinfo.sc2b2_tstat(ii) > 0
        elect_select_FDR_all{ii,1} = [conds{2} ' only'];
    elseif sc1c2_FDR_all(ii) <0.05 && elinfo.sc1c2_tstat(ii) < 0 && sc1b1_FDR_all(ii) < 0.05 && elinfo.sc1b1_tstat(ii) > 0 && sc2b2_FDR_all(ii) < 0.05 && elinfo.sc2b2_tstat(ii) > 0
        elect_select_FDR_all{ii,1} = [conds{2} ' selective and ' conds{1} ' act'];
    elseif sc1c2_FDR_all(ii) <0.05 && elinfo.sc1c2_tstat(ii) < 0 && sc1b1_FDR_all(ii) < 0.05 && elinfo.sc1b1_tstat(ii) < 0 && sc2b2_FDR_all(ii) < 0.05 && elinfo.sc2b2_tstat(ii) > 0
        elect_select_FDR_all{ii,1} = [conds{2} ' selective and ' conds{1} ' deact'];    
                
    else
        elect_select_FDR_all{ii,1} = 'no selectivity';
    end
    
end


% organize output in a sinlge table
el_selectivity = table(elect_select_FDR_all, sc1c2_FDR_all, sc1b1_FDR_all, sc2b2_FDR_all);
elinfo = [elinfo el_selectivity];

end

