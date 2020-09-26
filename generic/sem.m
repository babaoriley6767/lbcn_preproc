function out=sem(data,dim)
%   function out=sem(data); --Standard Error of the mean
%
%   Standard Error of the mean- this will calculate the standard error of
%   the mean down the first dimension of teh input array data. I really 
%   only write this program so I don't have to remember the formula for it.
%
%   Note- this is the standard error of the mean regardless of the
%   underlying distribution... 
%
%   BUT if the underlying distribution is normal, then a 95% conf Int. of 
%   the mean  is:   mean +/- 1.96 * sem
%
%   The entire program is: out=std(data)/sqrt(size(data,1));

if nargin<2 || isempty(dim);        dim=1;      end

out=nanstd(data,[],dim)./sqrt( sum(~isnan(data),dim) );