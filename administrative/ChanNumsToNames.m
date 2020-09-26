function names = ChanNumsToNames(globalVar,nums)
%% INPUTS: 
% globalVar: globalVar structure
% nums: vector of channel numbers

names = globalVar.channame(nums);