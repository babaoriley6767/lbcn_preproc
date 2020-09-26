function data = sort_tabulate(data, order)
    tmp = tabulate(data);
    count = vertcat(tmp{:,2});
    percentage = vertcat(tmp{:,3});
    [~, idx] = sort(count, order);
    value = tmp(idx, 1);
    count = count(idx);
    percentage = percentage(idx);
    data = table(value, count, percentage);
   
end