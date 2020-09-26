function el_selectivity= simplify_selectivity(el_selectivity, task)

switch task
    
    case {'MMR', 'UCLA', 'Memoria'}
        
        for i = 1:size(el_selectivity)
            if contains(el_selectivity.elect_select{i}, 'math selective and')
                el_selectivity.elect_select{i} = 'math selective';
            elseif contains(el_selectivity.elect_select{i}, 'and math')
                el_selectivity.elect_select{i} = 'memory selective';
            elseif contains(el_selectivity.elect_select{i}, {'episodic only', 'autobio only'})
                el_selectivity.elect_select{i} = 'memory only';
            elseif  contains(el_selectivity.elect_select{i}, 'math and')
                el_selectivity.elect_select{i} = 'math and memory';
            else
            end
        end
        
end

