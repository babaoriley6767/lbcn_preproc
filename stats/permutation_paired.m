function p = permutation_paired(adata, bdata, reps)
% This function takes two datasets (adata, bdata) that are the same length
% and are linked (e.g. data from the same row in each dataset comes from 
% same subject) and computes the p-value that two datasets come from the
% same underlying distribution by permuting labels (reps = # of
% repetitions)

if length(adata) ~= length(bdata)
    error('Cmon dawg, two datasets must be same size...aight??')
end

numa = length(adata);

real_meandiff = nanmean(adata(:))-nanmean(bdata(:));

permdiff = NaN*ones(1,reps);
for r = 1:reps
    % randomly swap data between two conditions in a subset of rows
    inds = find(rand(1,numa)>0.5); 
    tempa = adata;
    tempb = bdata;
    tempa(inds) = bdata(inds);
    tempb(inds) = adata(inds);
    permdiff(r) = nanmean(tempa)-nanmean(tempb);
end

% compute percentile of actual difference along distribution of permuted
% diffs

p = sum(real_meandiff>[permdiff real_meandiff])/(reps+1);
if (p == 0)
    p = 1/(reps+1);
end

% convert percentile to p-value
p = min(p,1-p)*2;

end
