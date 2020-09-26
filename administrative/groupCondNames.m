function grouped_condnames = groupCondNames(conds,groupall)

if (groupall)
    nconds = 1;
else
    nconds = length(conds);
end
grouped_condnames = cell(1,nconds);
for ci = 1:nconds

    % if grouping multiple conditions together
    if iscell(conds{ci}) && length(conds{ci})>1
        cond_tmp = conds{ci};
        condname_tmp = [];
        for cii = 1:length(cond_tmp)
            condname_tmp = [condname_tmp cond_tmp{cii},'+'];
        end
        grouped_condnames{ci} = condname_tmp(1:end-1);
    elseif ~iscell(conds{ci}) && length(conds)>1 && groupall
        condname_tmp = [];
        for cii = 1:length(conds)
            condname_tmp = [condname_tmp conds{cii},'+'];
        end
        grouped_condnames{ci} = condname_tmp(1:end-1);
    else
        if iscell(conds{ci})
            grouped_condnames{ci} = conds{ci}{1};
        else
            grouped_condnames{ci} = conds{ci};
        end
    end
end