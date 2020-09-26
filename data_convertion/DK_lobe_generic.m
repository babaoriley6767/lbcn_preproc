function elinfo = DK_lobe_generic(elinfo)
    
    for i = 1:size(elinfo)
       if contains(elinfo.DK_lobe{i}, 'White') || contains(elinfo.DK_lobe{i}, 'WM')
           elinfo.DK_lobe{i} = 'WM';
       elseif contains(elinfo.DK_lobe{i}, 'Hippocampus')
           elinfo.DK_lobe{i} = 'Subcortical';
       elseif contains(elinfo.DK_lobe{i}, 'Amygdala')
           elinfo.DK_lobe{i} = 'Subcortical';           
       elseif contains(elinfo.DK_lobe{i}, 'Putamen')
           elinfo.DK_lobe{i} = 'Subcortical';           
       elseif contains(elinfo.DK_lobe{i}, 'Hippocampus')
           elinfo.DK_lobe{i} = 'Subcortical';
       elseif contains(elinfo.DK_lobe{i}, 'vent') || contains(elinfo.DK_lobe{i}, 'Ventricle')
           elinfo.DK_lobe{i} = 'Ventricle';       
       elseif contains(elinfo.DK_lobe{i}, 'Caudate')
           elinfo.DK_lobe{i} = 'Subcortical';     
       elseif contains(elinfo.DK_lobe{i}, 'Putamen')
           elinfo.DK_lobe{i} = 'Subcortical';     
       elseif contains(elinfo.DK_lobe{i}, 'Pallidum')
           elinfo.DK_lobe{i} = 'Subcortical';     
       elseif contains(elinfo.DK_lobe{i}, 'Accumbens')
           elinfo.DK_lobe{i} = 'Subcortical';     
       elseif contains(elinfo.DK_lobe{i}, 'CC')
           elinfo.DK_lobe{i} = 'Subcortical';     
       elseif contains(elinfo.DK_lobe{i}, 'choroid-plexus')
           elinfo.DK_lobe{i} = 'Subcortical';     
       elseif contains(elinfo.DK_lobe{i}, 'Unknown') || contains(elinfo.DK_lobe{i}, 'undefined')
           elinfo.DK_lobe{i} = 'Undefined';             
       end
        
    end

%     
%     for i = 1:size(elinfo)
%         if contains(elinfo.DK_lobe{i}, 'White') || contains(elinfo.DK_lobe{i}, 'WM')
%             elinfo.DK_lobe{i} = 'WM';
%         elseif contains(elinfo.DK_lobe{i}, 'Hippocampus')
%             elinfo.DK_lobe{i} = 'Hippocampus';
%         elseif contains(elinfo.DK_lobe{i}, 'Amygdala')
%             elinfo.DK_lobe{i} = 'Amygdala';
%         elseif contains(elinfo.DK_lobe{i}, 'Putamen')
%             elinfo.DK_lobe{i} = 'Putamen';
%         elseif contains(elinfo.DK_lobe{i}, 'Hippocampus')
%             elinfo.DK_lobe{i} = 'Hippocampus';
%         elseif contains(elinfo.DK_lobe{i}, 'vent') || contains(elinfo.DK_lobe{i}, 'Ventricle')
%             elinfo.DK_lobe{i} = 'Ventricle';
%         elseif contains(elinfo.DK_lobe{i}, 'Caudate')
%             elinfo.DK_lobe{i} = 'Basal Ganglia';
%         elseif contains(elinfo.DK_lobe{i}, 'Putamen')
%             elinfo.DK_lobe{i} = 'Basal Ganglia';
%         elseif contains(elinfo.DK_lobe{i}, 'Pallidum')
%             elinfo.DK_lobe{i} = 'Basal Ganglia';
%         elseif contains(elinfo.DK_lobe{i}, 'Accumbens')
%             elinfo.DK_lobe{i} = 'Basal Ganglia';
%         elseif contains(elinfo.DK_lobe{i}, 'CC')
%             elinfo.DK_lobe{i} = 'Corpus Callosum';
%         elseif contains(elinfo.DK_lobe{i}, 'choroid-plexus')
%             elinfo.DK_lobe{i} = 'choroid Plexus';
%         elseif contains(elinfo.DK_lobe{i}, 'Unknown') || contains(elinfo.DK_lobe{i}, 'undefined')
%             elinfo.DK_lobe{i} = 'Undefined';
%         end
%         
%     end
    


end