function p = permutation_unpaired(adata, bdata, reps)
% This function takes two datasets (adata, bdata) and computes the p-value 
% that two datasets come from the same underlying distribution by 
% permuting labels (reps = # of repetitions)

numa = length(adata);
numb = length(bdata);
numtot = numa+numb;

if (size(adata,1)>size(adata,2))
    data = vertcat(adata, bdata);
else
    data = horzcat(adata, bdata);
end

real_meandiff = nanmean(adata(:))-nanmean(bdata(:));

permdiff = NaN*ones(1,reps);
for r = 1:reps
    inds = randperm(numtot);
    % keep size of two datasets the same, but randomly shuffle
    indsa = inds(1:numa);
    indsb = inds(numa+1:end);
    permdiff(r) = nanmean(data(indsa))-nanmean(data(indsb));
end

% compute percentile of actual difference along distribution of permuted
% diffs
p = sum(real_meandiff>[permdiff real_meandiff])/(reps+1);
if (p == 0)
    p = 1/(reps+1);
end

% convert percentile to p-value
p = min(p,1-p)*2;

if sum(isnan(adata)) >= .8*length(adata) || sum(isnan(bdata)) >= .8*length(bdata)
    p = nan;
else
end

end
