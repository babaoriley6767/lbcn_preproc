function plot_ROL_scatter(ROL, ROL_var, elecs, cond_names, sort_type, colum_sort, col)


twin = [0.05 1];
figure('units', 'normalized', 'outerposition', [0 0 0.3 0.5])

for ic = 1:length(cond_names)
    for iri = 1:length(ROL_var)
        subplot(1,length(ROL_var),iri)
        ROL_tmp = vertcat(ROL.(cond_names{ic}).(ROL_var{iri}){elecs})';
        if strcmp(ROL_var, 'onsets')
            ROL_tmp(ROL_tmp < twin(1) | ROL_tmp > twin(2)) = nan;
        else
            ROL_tmp(ROL_tmp < twin(1)) = nan;
        end
        
        if strcmp(sort_type, 'by one column')
            ROL_tmp = ROL_tmp(~isnan(ROL_tmp(:,colum_sort)),:);
            ROL_tmp = sortrows(ROL_tmp, colum_sort, 'descend');
        elseif strcmp(sort_type, 'each column separately')
             for i = 1:length(elecs)
                 ROL_tmp(:,i) = sort(ROL_tmp(:,i), 'descend');
             end
        end
            
        for i = 1:length(elecs)
            ROL_tmp_tmp = ROL_tmp(:,i);
            ROL_tmp_tmp(ROL_tmp_tmp < twin(1) | ROL_tmp_tmp > twin(2)) = nan;
            h(i) = plot(ROL_tmp_tmp, 1:length(ROL_tmp_tmp),'.','Color',col(i,:),'LineWidth',1, 'MarkerSize', 30);
            hold on
        end
        xlabel('ROL (s)')
        if strcmp(ROL_var{iri}, 'onsets')
            xlim([0 twin(2)])
        else
            xlim([0 max(ROL_tmp_tmp(:))])
        end

        ylim([0 size(ROL_tmp_tmp,1)])
        ylabel('Trials')
        set(gca,'fontsize',16)
        title(ROL_var{iri})    
        set(gcf,'color', 'w')
    end
    
end





% fn_out = sprintf('%s/%s_%s_%s_ROL2_fig.png',dir_out,sbj_name,subjVar.labels_EDF{elec_inspect},project_name);%


end

