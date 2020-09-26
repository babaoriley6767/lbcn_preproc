function pval = circular_p(itc, n)

%% Inputs
% itc:  matrix of itc values (can have any dimensions); output will have same dimensions
% n:    # of samples used to calculate itcs
%   Computes Rayleigh test for non-uniformity of circular data.
%   H0: the population is uniformly distributed around the circle
%   HA: the populatoin is not distributed uniformly around the circle
%   Assumption: the distribution has maximally one mode and the data is 
%   sampled from a von Mises distribution!
%
% References:
%   Statistical analysis of circular data, N. I. Fisher
%   Topics in circular statistics, S. R. Jammalamadaka et al. 
%   Biostatistical Analysis, J. H. Zar
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html


% compute Rayleigh's R (equ. 27.1)
R = n*itc;

% compute p value using approxation in Zar, p. 617
pval = exp(sqrt(1+4*n+4*(n^2-R.^2))-(1+2*n));

% outdated version:
% compute the p value using an approximation from Fisher, p. 70
% pval = exp(-z);
% if n < 50
%   pval = pval * (1 + (2*z - z^2) / (4*n) - ...
%    (24*z - 132*z^2 + 76*z^3 - 9*z^4) / (288*n^2));
% end









