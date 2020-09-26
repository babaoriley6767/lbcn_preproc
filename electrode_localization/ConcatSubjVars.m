function subjVar_all = ConcatSubjVars(subjects, dirs, vars)

subjVar_all = table;
for is = 1:length(subjects)
    load([dirs.original_data filesep  subjects{is} filesep 'subjVar_'  subjects{is} '.mat']);
    subjVar_tmp = subjVar.elinfo(:, contains(subjVar.elinfo.Properties.VariableNames, vars));
    subjVar_tmp.sbj_name = repmat({subjects{is}},size(subjVar_tmp,1),1);

    subjVar_all = [subjVar_all; subjVar_tmp];
    
    
end

if sum(contains(vars, 'DK_lobe')) > 0
    subjVar_all.DK_lobe_generic = DK_lobe_generic(subjVar_all);
else
end

end

