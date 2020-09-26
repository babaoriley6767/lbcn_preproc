% old_str = {'AA','BB','CC','DD','EE','FF','GG','HH'};
% new_str = {'AC','P','PI1','PI3','LP','PI4','PS','PI2'};
old_str = {'RPIH','RAIH','RTS'};
new_str = {'RPI','RAI','RST'};

% old_names = new_names;
old_names = subjVar.elect_names;
new_names = old_names;

for i = 1:length(old_str)
    inds = find(contains(old_names,old_str{i}));
    new_names(inds)=strrep(old_names(inds),old_str{i},new_str{i});
end

