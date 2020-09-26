function normsig = normMinMax(sig,varargin)

% normalize input signal (sig) between min and max (0-1)
% optional 2nd input: dimension along which to normalize (if sig > 1D)

ndimssig = ndims(sig);
if ndimssig>1
    if ~isempty(varargin) % if specified dimension
        normdim = varargin{1};
        sigdims = size(sig);
        repdims = ones(1,ndimssig);
        repdims(normdim)=sigdims(normdim);
        minsig = nanmin(sig,[],normdim);
        minsig = repmat(minsig,repdims);
        maxsig = nanmax(sig,[],normdim);
        maxsig = repmat(maxsig,repdims);
        normsig = (sig-minsig)./(maxsig-minsig);
    else % otherwise normalize with respect to min/max of entire array
        normsig = (sig-nanmin(sig(:)))/(nanmax(sig(:))-nanmin(sig(:)));
    end
else
    normsig = (sig-nanmin(sig))/(nanmax(sig)-nanmin(sig));
end