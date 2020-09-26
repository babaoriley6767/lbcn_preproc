function [maxConsec,maxind] = getMaxConsec(vect)

% maxConsec: max number of consecutive non-zero elements in vect
% maxind: index (in vect) of first element in longest non-zero sequence

if sum(logical(vect))>0 % if at least one non-zero element
    vect = vect(:)'; % turn into row vector
    
    zpos = find(~[0 vect 0]);
    [~,grpidx]= max(diff(zpos));
    
    maxConsec = zpos(grpidx+1)-zpos(grpidx)-1;
    maxind = zpos(grpidx);
else
    maxConsec = 0;
    maxind = NaN;
end