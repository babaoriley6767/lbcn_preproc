function elec_select = concat_selectivity_tasks(sinfo, tasks, vars, dirs)
switch tasks
    case 'calc_simultaneous'

        task = 'MMR';    
        sinfo_MMR = sinfo(strcmp(sinfo.task, task),:);    
        el_selectivity_MMR = concat_elect_select(sinfo_MMR.sbj_name, task, dirs, vars);
        task = 'UCLA';    
        sinfo_UCLA = sinfo(strcmp(sinfo.task, task),:);    
        el_selectivity_UCLA = concat_elect_select(sinfo_UCLA.sbj_name, task, dirs, vars);

        elec_select = [el_selectivity_MMR;el_selectivity_UCLA];
        elec_select = elec_select(strcmp(elec_select.WMvsGM, 'GM') | strcmp(elec_select.WMvsGM, 'WM'), :);
        elec_select = elec_select(~strcmp(elec_select.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);

    case 'MMR'
        
        task = 'MMR';
        sinfo_MMR = sinfo(strcmp(sinfo.task, task),:);    
        elec_select = concat_elect_select(sinfo_MMR.sbj_name, task, dirs, vars);
        elec_select = elec_select(strcmp(elec_select.WMvsGM, 'GM') | strcmp(elec_select.WMvsGM, 'WM'), :);
        elec_select = elec_select(~strcmp(elec_select.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);

        
        
    case 'calc_sequential'
        task = 'Memoria';    
        sinfo_Memoria = sinfo(strcmp(sinfo.task, task),:);    
        elec_select = concat_elect_select(sinfo_Memoria.sbj_name, task, dirs, vars);
        elec_select = elec_select(strcmp(elec_select.WMvsGM, 'GM') | strcmp(elec_select.WMvsGM, 'WM'), :);
        elec_select = elec_select(~strcmp(elec_select.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);


        
        
    case 'all_calc'
        task = 'MMR';    
        sinfo_MMR = sinfo(strcmp(sinfo.task, task),:);    
        el_selectivity_MMR = concat_elect_select(sinfo_MMR.sbj_name, task, dirs, vars);
        task = 'UCLA';    
        sinfo_UCLA = sinfo(strcmp(sinfo.task, task),:);    
        el_selectivity_UCLA = concat_elect_select(sinfo_UCLA.sbj_name, task, dirs, vars);
        task = 'Memoria';    
        sinfo_Memoria = sinfo(strcmp(sinfo.task, task),:);    
        el_selectivity_Memoria = concat_elect_select(sinfo_Memoria.sbj_name, task, dirs, vars);
        
      
        strcmp(el_selectivity_MMR_Memoria.elect_select, el_selectivity_Memoria_MMR.elect_select)
  
  
        elec_select = [el_selectivity_MMR;el_selectivity_UCLA; el_selectivity_Memoria];
        elec_select = elec_select(strcmp(elec_select.WMvsGM, 'GM') | strcmp(elec_select.WMvsGM, 'WM'), :);
        elec_select = elec_select(~strcmp(elec_select.Yeo7, 'FreeSurfer_Defined_Medial_Wall'),:);
        
        
       

end

