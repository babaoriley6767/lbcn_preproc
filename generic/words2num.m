function [num,spl] = words2num(str,opts,varargin)
% Convert a string of numbers in English words to their numeric values (GB/US).
%
% (c) 2017 Stephen Cobeldick
%
% WORDS2NUM detects in the input string any numbers written as words and
% converts them to numeric values, e.g. 'one hundred and one' -> 101.
% It also returns the input string parts split by the number substrings.
%
%%% Syntax:
%  num = words2num(str)
%  num = words2num(str,opts)
%  num = words2num(str,<name-value pairs>)
% [num,spl] = words2num(...)
%
% The number format is based on: http://www.blackwasp.co.uk/NumberToWords.aspx
% The number recognition can be controlled by options such as the character
% case, requiring or excluding 'and', '-' or ',' from the numbers, a leading
% sign, the class of the output numeric, etc.: see the section "Options" below.
% If no number is identified in the string then the output <num> will be empty.
%
% Note 1: Common multiplier spelling variants are accepted, e.g.: Do|Duo,
%   Tre|Tres, Quin|Quinqua, Ses|Sex, Sept|Septem|Septen, Octocto|Octoocto.
% Note 2: Decimal digits may be given as the last digits, following the word 'point'.
% Note 3: Infinity and Not-a-Number must be spelled out in full, not 'Inf' or 'NaN'.
% Note 4: Converts number strings up to realmax('double'), larger not specified.
%
% See also NUM2WORDS SIP2NUM BIP2NUM STR2DOUBLE STR2NUM NATSORT CELLFUN
%
%% Options %%
%
% The options may be supplied either
% 1) in a scalar structure, or
% 2) as a comma-separated list of name-value pairs.
%
% Field names and string values are case-insensitive. The following
% field names and values are permitted as options (*=default value):
%
% Field  | Permitted  |
% Name:  | Values:    | Description (example string or regular expression):
% =======|============|====================================================
% class  |'double'   *| The class of the output <num>. Note that information
%        |'single'    | may be lost during conversion from the string number/s.
%        |'int8'|'int16'|'int32'|'int64'|'uint8'|'uint16'|'uint32'|'uint64'
% -------|------------|----------------------------------------------------
% scale  |'short'    *| Short scale, modern English   (1e9->'one billion')
%        |'long'      | Long scale, B.E. until 1970's (1e9->'one thousand million')
%        |'peletier'  | Most other European languages (1e9->'one milliard')
%        |'rowlett'   | Russ Rowlett's Greek-based    (1e9->'one gillion')
%        |'knuth'     | Donald Knuth's logarithmic    (1e9->'ten myllion')
% -------|------------|----------------------------------------------------
% case   |'ignore'   *| Any case allowed  ('oNe tHouSAnd AnD TWENtY-FoUR')
%        |'lower'     | Lowercase number  ('one thousand and twenty-four')
%        |'upper'     | Uppercase number  ('ONE THOUSAND AND TWENTY-FOUR')
%        |'title'     | Titlecase number  ('One Thousand and Twenty-Four')
% -------|------------|----------------------------------------------------
% mult   |'simple'   *| Multiplier must be simple   ('one trillion')
%        |'compound'  | Multipliers may be compound ('one million million')
% -------|------------|----------------------------------------------------
% hyphen | []        *| Optional hyphen between tens and ones ('twenty(-| )four')
%        | true       | Require hyphen between tens and ones  ('twenty-four')
%        | false      | Exclude hyphen between tens and ones  ('twenty four')
% -------|------------|----------------------------------------------------
% comma  | []        *| Optional comma separator ('one million,? one thousand')
%        | true       | Require comma separator  ('one million, one thousand')
%        | false      | Exclude comma separator  ('one million one thousand')
% -------|------------|----------------------------------------------------
% and    | []        *| Optional 'and' before tens/ones ('one hundred (and )?one)
%        | true       | Require 'and' before tens/ones  ('one hundred and one')
%        | false      | Exclude 'and' before tens/ones  ('one hundred one')
% -------|------------|----------------------------------------------------
% space  | []        *| Optional space character ('one ?hundred')
%        | true       | Require space character  ('one hundred')
%        | false      | Exclude space character  ('onehundred')
% -------|------------|----------------------------------------------------
% sign   | []        *| Optional sign prefix ('(negative )?twenty-four')
%        | true       | Require sign prefix  ('positive twenty-four')
%        | false      | Exclude sign prefix  ('twenty-four')
% -------|------------|----------------------------------------------------
% white  | ' '       *| A vector of characters, any one of which can be the
%        |            | whitespace between words, e.g. '-' or char([9,32]).
% -------|------------|----------------------------------------------------
% prefix | ''        *| A regular expression that precedes each number substring.
% -------|------------|----------------------------------------------------
% suffix | ''        *| A regular expression that follows each number substring.
% -------|------------|----------------------------------------------------
%
% Note 5: The <scale> 'knuth' ignores the options <mult>, <comma> and <and>.
%
%% Examples %%
%
% words2num('zero')
%  ans = 0
%
% words2num('One Thousand and TWENTY-four')
%  ans = 1024
% words2num('One_Thousand_and_TWENTY-four', 'white','_')
%  ans = 1024
% words2num('One Thousand and TWENTY-four', 'case','lower')
%  ans = 4
% words2num('One Thousand and TWENTY-four', 'case','upper')
%  ans = 20
% words2num('One Thousand and TWENTY-four', 'case','title')
%  ans = 1000
% words2num('One Thousand and TWENTY-four', 'hyphen',false)
%  ans = [1020,4]
% words2num('One Thousand and TWENTY-four', 'and',false)
%  ans = [1000,24]
% words2num('One Thousand and TWENTY-four', 'suffix','-')
%  ans = 1020
%
% [num,spl] = words2num('Negative thirty-two squared is one thousand and twenty-four.')
%  num = [-32,1024]
%  spl = {'',' squared is ','.'}
%
% [num,spl] = words2num('one hundred and twenty-three pounds and forty-five pence')
%  num = [123,45]
%  spl = {'',' pounds and ',' pence'}
%
% [num,spl] = words2num('pi=threepointonefouronefiveninetwosixfivethreefiveeight')
%  num = 3.14159265358
%  spl = {'pi=',''}
%
% [num,spl] = words2num('One Hundred and One Dalmatians')
% num = 101
% spl = {'',' Dalmatians'}
%
% words2num('one hundred and seventy-nine uncentillion')
%  ans = 1.79e+308
% words2num('one hundred and eighty uncentillion') % >realmax
%  ans = Inf
% words2num('one hundred and eighty uncentillion', 'class','int64')
%  ans = 9223372036854775807
% words2num(num2words(intmin('int64')),'class','int64')
%  ans = -9223372036854775808
%
% words2num('one point zero zero two zero zero three trillion')
%  ans = 1002003000000
% words2num('one trillion, two billion three million')
%  ans = 1002003000000
% words2num('one million million, two thousand million, three million', 'mult','compound')
%  ans = 1002003000000
% words2num('one trillion, two billion three million', 'comma',true, 'and',true)
%  ans = [1002000000000,3000000]
% words2num('one trillion, two billion three million', 'comma',false)
%  ans = [1000000000000,2003000000]
%
% words2num('one billion', 'scale','short')
%  ans = 1000000000
% words2num('one thousand million', 'scale','long')
%  ans = 1000000000
% words2num('one milliard', 'scale','peletier')
%  ans = 1000000000
% words2num('one gillion', 'scale','rowlett')
%  ans = 1000000000
% words2num('ten myllion', 'scale','knuth')
%  ans = 1000000000
%
% words2num('Negative Infinity')
%  ans = -Inf
% words2num('Not-a-Number')
%  ans = NaN
%
%% Input and Output Arguments %%
%
%%% Inputs:
%  str  = Character Vector, possibly containing number words to convert to numeric.
%  opts = Structure Scalar, with optional fields and values as per 'Options' above.
%  OR
%  <name-value pairs> = a comma separated list of names and associated values.
%
%%% Outputs:
%  num = Numeric Vector, the numeric values of number substrings in <str>.
%  spl = Cell of Strings, the parts of <str> split by the detected number substrings.
%
% [num,spl] = words2num(str,*opts)
% [num,spl] = words2num(str,*<name-value pairs>)

%% Input Wrangling %%
%
assert(ischar(str)&&ismatrix(str)&&size(str,1)<2,'First input <str> must be a 1xN char.')
%
% Default option values:
dfar = struct('space',[], 'sign',[], 'hyphen',[], 'comma',[], 'and',[],...
	'case','ignore', 'class','double', 'scale','short', 'mult','simple',...
	'white',char(32), 'prefix','', 'suffix','');
%
% Check any supplied option fields and values:
switch nargin
	case 1 % no options
		%dfar.iss = false;
	case 2 % options in a struct
		assert(isstruct(opts)&&isscalar(opts),'Second input <opts> can be a scalar struct.')
		dfar = w2nOptions(dfar,opts);
	otherwise % options as <name-value> pairs
		opts = struct(opts,varargin{:});
		assert(isscalar(opts),'Invalid <name-value> pairs: cell array values are not permitted.')
		dfar = w2nOptions(dfar,opts);
end
%
%% Digit and Multiplier Names %%
%
% Helper Functions:
% fSein: []->'X?', false->'', true->'X'
fSein = @(f,c)[c{isempty(dfar.(f))||dfar.(f)},char(63*ones(1,isempty(dfar.(f))))];
% f1oo3: []->{1}, false->{2}, true->{3}
f1oo3 = @(f,c)c{1+isscalar(dfar.(f))+(isscalar(dfar.(f))&&dfar.(f))};
%
% Punctuation:
dfar.white = regexptranslate('escape',dfar.white);
pSpa = fSein('space', {sprintf('[%s]',dfar.white)});
pAnd = fSein('and',   {sprintf('(and%s)',pSpa)});
pCom = sprintf('%s%s',fSein('comma',{','}),pSpa);
pSig = sprintf('((Posi|Nega)tive%s)',pSpa);
pSig = f1oo3('sign',  {sprintf('%s?',pSig),'()',pSig});
pHyp = f1oo3('hyphen',{sprintf('(-|%s)',pSpa),pSpa,'-'});
%
% Ones, Teens and Tens:
cOne  = {'One','Two','Three','Four','Five','Six','Seven','Eight','Nine'};
cTen  = {'Ten','Eleven','Twelve'};
cTeen = {'Thir','Four','Fif','Six','Seven','Eigh','Nine'};%teen
cTy   = {'Twen','Thir','For','Fif','Six','Seven','Eigh','Nine'};%ty
%
% Strings for defining regular expression:
sOne  = w2nJoin(cOne);
sTen  = w2nJoin(cTen);
sTeen = w2nJoin(cTeen);
sTy   = w2nJoin(cTy);
%
% Common regular expressions:
rEdg = sprintf('Not%sa%sNumber|Infinity',pHyp,pHyp); % NaN|Inf
rDec = sprintf('(%sPoint(%s(Zero|%s))+)',pSpa,pSpa,sOne); % decimal fraction
rToO = sprintf('((%s)ty(%s(%s))?|(%s)teen|%s|%s)',sTy,pHyp,sOne,sTeen,sTen,sOne); % T&|O
%
% Cell-of-strings for identifying digits:
cTy  = [{'XXX'},strcat('^',cTy,'ty')];
cOT = strcat([cOne,cTen,strcat(cTeen,'teen')],'$');
%
% Multipliers:
switch dfar.scale
	case 'knuth'
		[num,spl] = w2nKnuth(str,dfar,rEdg,rDec,rToO,pSpa,pSig,cTy,cOT,cOne);
		return
	case 'rowlett'
		cMlt = {'M','G','Tetr','Pent','Hex','Hept','Okt','Enn','Dek','Hendek','Dodek','Trisdek','Tetradek','Pentadek','Hexadek','Heptadek','Oktadek','Enneadek','Icos','Icosihen','Icosid','Icositr','Icositetr','Icosipent','Icosihex','Icosihept','Icosiokt','Icosienn','Triacont','Triacontahen','Triacontad','Triacontatr','Triacontatetr','Triacontapent','Triacontahex','Triacontahept','Triacontaokt','Triacontaenn','Tetracont','Tetracontahen','Tetracontad','Tetracontatr','Tetracontatetr','Tetracontapent','Tetracontahex','Tetracontahept','Tetracontaokt','Tetracontaenn','Pentacont','Pentacontahen','Pentacontad','Pentacontatr','Pentacontatetr','Pentacontapent','Pentacontahex','Pentacontahept','Pentacontaokt','Pentacontaenn','Hexacont','Hexacontahen','Hexacontad','Hexacontatr','Hexacontatetr','Hexacontapent','Hexacontahex','Hexacontahept','Hexacontaokt','Hexacontaenn','Heptacont','Heptacontahen','Heptacontad','Heptacontatr','Heptacontatetr','Heptacontapent','Heptacontahex','Heptacontahept','Heptacontaokt','Heptacontaenn','Oktacont','Oktacontahen','Oktacontad','Oktacontatr','Oktacontatetr','Oktacontapent','Oktacontahex','Oktacontahept','Oktacontaokt','Oktacontaenn','Enneacont','Enneacontahen','Enneacontad','Enneacontatr','Enneacontatetr','Enneacontapent','Enneacontahex','Enneacontahept','Enneacontaokt','Enneacontaenn','Hect','Hectahen','Hectad'};
	otherwise % short, long, peletier
		cMlt = {'M','B','Tr','Quadr','Quint','Sext','Sept','Oct','No(n|ve[nm]t)','Dec','Undec','Du?odec','Tredec','Quattuordec','Quin(qua)?dec','Se[sx]?dec','Sept(e[mn])?dec','Octodec','Nove[mn]dec','Vigint','Unvigint','Du?ovigint','Tres?vigint','Quattuorvigint','Quin(qua)?vigint','Se[sx]vigint','Sept(e[mn])?vigint','Octovigint','Nove[mn]vigint','Trigint','Untrigint','Du?otrigint','Tres?trigint','Quattuortrigint','Quin(qua)?trigint','Se[sx]trigint','Sept(e[mn])?trigint','Octotrigint','Nove[mn]trigint','Quadragint','Unquadragint','Du?oquadragint','Tres?quadragint','Quattuorquadragint','Quin(qua)?quadragint','Se[sx]quadragint','Sept(e[mn])?quadragint','Octoquadragint','Nove[mn]quadragint','Quinquagint','Unquinquagint','Du?oquinquagint','Tres?quinquagint','Quattuorquinquagint','Quin(qua)?quinquagint','Se[sx]quinquagint','Sept(e[mn])?quinquagint','Octoquinquagint','Nove[mn]quinquagint','Sexagint','Unsexagint','Du?osexagint','Tres?sexagint','Quattuorsexagint','Quin(qua)?sexagint','Se[sx]?sexagint','Sept(e[mn])?sexagint','Octosexagint','Nove[mn]sexagint','Septuagint','Unseptuagint','Du?oseptuagint','Tres?septuagint','Quattuorseptuagint','Quin(qua)?septuagint','Se[sx]?septuagint','Sept(e[mn])?septuagint','Octoseptuagint','Nove[mn]septuagint','Octogint','Unoctogint','Du?o?octogint','Tres?octogint','Quattuoroctogint','Quin(qua)?octogint','Se[sx]octogint','Sept(e[mn])?octogint','Octo?octogint','Nove[mn]octogint','Nonagint','Unnonagint','Du?ononagint','Tres?nonagint','Quattuornonagint','Qui(n(qua)?)?nonagint','Se[sx]?nonagint','Sept(e[mn]?)?nonagint','Octononagint','Nove[mn]?nonagint','Cent','Uncent'};
		if any(strcmp(dfar.scale,{'peletier','long'}))
			cMlt = cMlt(1:ceil(numel(cMlt)/2));
		end
end
%
sMlt = w2nUpLo(w2nJoin(cMlt),dfar.case);
sTho = w2nUpLo('Thousand',   dfar.case);
%
nMlt = [0,cumsum(1+cellfun('length',cMlt))];
if strcmp(dfar.scale,'peletier')
	nMlt = nMlt([1,1],:);
	nMlt = nMlt(:).';
	cMlt(2,:) = strcat('^',cMlt(1,:),'illiard');
	cMlt(1,:) = strcat('^',cMlt(1,:),'illion');
	cMlt = cMlt(:)';
	sSfx = 'illi(on|ard)';
else % short, long, rowlett
	cMlt = strcat('^',cMlt,'illion');
	sSfx = 'illion';
end
%
%% Multiplier Indices %%
%
nPrv =  0; %#ok<NASGU>
bTmp = []; %#ok<NASGU>
xTmp = []; %#ok<NASGU>
bMlt = {}; % multiplier begin index
xMlt = {}; % multiplier index number
rSet = '(?@bTmp=[];xTmp=[];)'; % reset at the start of each regex match
rCat = '(?@bMlt{end+1}=bTmp;xMlt{end+1}=xTmp;)'; % save at the end of match
rMlt = [pSpa,'(?@nPrv=numel($&);)'... % the length of the parsed string
	'(??@fMatch(xTmp))'... % dynamically create a multiplier regex.
	'(?@[bTmp,xTmp]=fIndex($&,bTmp,nPrv,xTmp);)']; % identify the multiplier
fMatch = @(x)w2nMatch(x, nMlt, sMlt, sSfx,... % create a multiplier regex
	strcmp(dfar.scale,'peletier'), strcmp(dfar.mult,'compound')); %#ok<NASGU>
fIndex = @(s,b,n,x)w2nIndex(s,b,n,x, cMlt, strcmp(dfar.mult,'compound')); %#ok<NASGU>
%
%% Create Regular Expression %%
%
rTho = sprintf('%s%s',pSpa,sTho);%M
rHun = sprintf('(%s)%sHundred',sOne,pSpa);%H
raTO = sprintf('(%s%s%s)?',pSpa,pAnd,rToO);%(&TO)?
rcoa = sprintf('(%s%s)?%s',pCom,rHun,raTO);%(,H)?(&TO)?
rHTO = sprintf('(%s%s|%s)',rHun,raTO,rToO);%H(&TO)?|(TO)
if strcmp(dfar.mult,'compound')
	rEin = sprintf('(%s|~~)*',rTho);%(M|I)*
	rIns = sprintf('(%s|~~)+',rTho);%(M|I)+
	rGrp = sprintf('%s%s(%s%s%s)*%s%s?',rHTO,rIns,pCom,rHTO,rIns,rcoa,rDec);
else
	if strcmp(dfar.scale,'long')
		rEin = sprintf('(%s)?(~~)?',rTho);%(M)?(I)?
		rLng = sprintf('(%s%s)?',rTho,rcoa);%(M(,H)?(&TO)?)?
	else
		rEin = sprintf('(%s|~~)?',rTho);%(M|I)?
		rLng = '';
	end
	rIns = sprintf('(%s%s%s~~)*(%s%s%s)?',pCom,rHTO,rLng,pCom,rHTO,rTho);%(HTOI)*(HTOM)?
	rGrp = sprintf('%s(%s~~%s|%s)%s%s?',rHTO,rLng,rIns,rTho,rcoa,rDec);%HTO(I(Opt)?|M)D?
end
rLow = sprintf('(Zero|%s)%s?%s',rHTO,rDec,rEin);%(Z|HTO)D?I?
rExp = sprintf('%s(%s|%s|%s)',pSig,rEdg,rGrp,rLow);%(Sgn)(NaN|Inf|Grp|Low)
%
[rExp,igma] = w2nCase(dfar,rExp);
rExp = strrep(rExp,'~~',rMlt);
rExp = sprintf('(?:(%s))%s%s(?:(%s))%s', dfar.prefix, rSet, rExp, dfar.suffix, rCat);
%
%% Locate any Number Substrings in String %%
%
[cTok,spl] = regexp(str,rExp, 'tokens','split', igma);
%
if isempty(cTok) % no numbers found
	num = zeros(0,0,dfar.class);
	return
end
%
cTok = vertcat(cTok{:});
nEnd = regexpi(cTok(:,2),sSfx,'end');
[mBeg,mEnd] = regexpi(cTok(:,2),'Thousand');
vSgn = 1-2*strncmpi(cTok(:,1),'Negative',8);
%
%% Convert Number Substrings to Numeric %%
%
num = zeros(1,size(cTok,1),dfar.class);
idi = strcmpi(cTok(:,2),'Infinity');
idn = strncmpi(cTok(:,2),'Not',3);
num(idi) = vSgn(idi)*Inf;
num(idn) = vSgn(idn)*NaN;
%
% Regular expression to split number strings (:,_)(H_)(:&_)(Z|TO)(_D)(:_)
rgx = sprintf('(?:,?%s)(%s%s)?(?:and%s)?(Zero|%s)?%s?(?:%s)',...
	pSpa, rHun, pSpa, pSpa, rToO, rDec, pSpa);
%
for m = find(~(idi|idn)')
	% Determine positions of multipliers:
	psn = [bMlt{m}-numel(cTok{m,1}),nEnd{m}];
	[psn,idz] = sort([psn,mBeg{m}-1,mEnd{m}]);
	idd = diff([0,psn,numel(cTok{m,2})]);
	idy = idz(2:2:end)>2*numel(bMlt{m});
	% Convert to digits and multipliers to numeric:
	num(m) = w2nConvN(dfar,rgx,vSgn(m),cTok{m,2},xMlt{m},cOne,cTy,cOT,idd,idy);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%words2num
function dfar = w2nOptions(dfar,opts)
% Options check: only supported fieldnames with suitable option values.
%
cFld = fieldnames(opts);
idx = ~cellfun(@(f)any(strcmpi(f,fieldnames(dfar))),cFld);
if any(idx)
	error('Unsupported field name/s:%s\b.',sprintf(' <%s>,',cFld{idx})) %#ok<SPERR>
end
%
% Logical options:
dfar = w2nLgc(dfar,opts,cFld,'and');
dfar = w2nLgc(dfar,opts,cFld,'comma');
dfar = w2nLgc(dfar,opts,cFld,'hyphen');
dfar = w2nLgc(dfar,opts,cFld,'space');
dfar = w2nLgc(dfar,opts,cFld,'sign');
%
% String options:
tmp = {'int8','int16','int32','int64','uint8','uint16','uint32','uint64'};
dfar = w2nStr(dfar,opts,cFld,'class','double','single',tmp{:});
dfar = w2nStr(dfar,opts,cFld,'case','ignore','upper','lower','title');
dfar = w2nStr(dfar,opts,cFld,'scale','short','long','peletier','rowlett','knuth');
dfar = w2nStr(dfar,opts,cFld,'mult','simple','compound');
%
% Literal options:
dfar = w2nLit(dfar,opts,cFld,'prefix');
dfar = w2nLit(dfar,opts,cFld,'suffix');
dfar = w2nLit(dfar,opts,cFld,'white');
num = numel(dfar.white);
assert(num==numel(unique(dfar.white)),'The characters in <white> must be unique.');
assert(num>0,'The <white> string cannot be empty.')
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nOptions
function idx = w2nCmpi(cFld,sFld)
% Options check: throw an error if more than one fieldname match.
idx = strcmpi(cFld,sFld);
if nnz(idx)>1
	error('Duplicated field names:%s\b.',sprintf(' <%s>,',cFld{idx})); %#ok<SPERR>
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nCmpi
function dfar = w2nLgc(dfar,opts,cFld,sFld)
% Options check: logical scalar.
idx = w2nCmpi(cFld,sFld);
if any(idx)
	tmp = opts.(cFld{idx});
	assert((islogical(tmp)&&isscalar(tmp))||(isnumeric(tmp)&&isempty(tmp)),...
		'The <%s> value must be a scalar logical or an empty numeric.',sFld)
	dfar.(sFld) = tmp;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nLgc
function dfar = w2nLit(dfar,opts,cFld,sFld)
% Options check: literal.
idx = w2nCmpi(cFld,sFld);
if any(idx)
	tmp = opts.(cFld{idx});
	assert(ischar(tmp)&&(isrow(tmp)||all(size(tmp)<2)),...
		'The <%s> value must be a 1xN character vector.',sFld)
	dfar.(sFld) = tmp;
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nLit
function dfar = w2nStr(dfar,opts,cFld,sFld,varargin)
% Options check: string.
idx = w2nCmpi(cFld,sFld);
if any(idx)
	tmp = opts.(cFld{idx});
	if ~ischar(tmp)||~isrow(tmp)||~any(strcmpi(tmp,varargin))
		error('The <%s> value must be one of:%s\b.',sFld,sprintf(' ''%s'',',varargin{:}));
	else
		dfar.(sFld) = lower(tmp);
	end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nStr
function str = w2nUpLo(str,uplo)
switch uplo
	case 'upper'
		str = upper(str);
	case 'lower'
		str = lower(str);
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nUpLo
function str = w2nJoin(inp)
% Concatenate all strings from a cell array, separated by '|'.
str = sprintf('|%s',inp{:});
str = str(2:end);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nJoin
function [rExp,igma] = w2nCase(dfar,rExp)
% Adjust the case of the regular expression.
switch dfar.case
	case 'title'
		rExp = strrep(rExp,'(and','([Aa]nd');
		igma = 'matchcase';
	case 'upper'
		rExp = upper(rExp);
		igma = 'matchcase';
	case 'lower'
		rExp = lower(rExp);
		igma = 'matchcase';
	otherwise
		igma = 'ignorecase';
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nCase
function num = w2nDec(str,odr,cOne)
% Convert decimal fraction string into a numeric vector of digits.
%
pmt = regexpi(str,[{'Zero'},cOne]);
[~,idx] = sort([pmt{:}]);
pmt = arrayfun(@(n,d)n*ones(1,d),0:9,cellfun('length',pmt),'UniformOutput',false);
vec = [pmt{:}];
len = numel(vec);
vec = vec(idx) .* 10.^(len-1:-1:0);
num = (odr * sum(vec)) / 10^len;
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nDec
function num = w2nConvN(dfar,rgx,sgn,str,mlt,cOne,cTy,cOT,idd,idy)
% Convert a short/long/rowlett/peletier number string into a numeric scalar.
%
spl = mat2cell(str,1,idd(1:end-(idd(end)==0)));
tok = regexpi(spl(1:2:end),rgx,'tokens','once');
tok(cellfun('isempty',tok)) = {{'','',''}};
tok = vertcat(tok{:});
N = size(tok,1);
%spl(end+1:2*N) = {''}
%
frc = zeros(N,1,dfar.class); one=frc; ten=frc; hun=frc;
% E-notation has better precision than using 10^N:
vec = [1e0;1e3;1e6;1e9;1e12;1e15;1e18;1e21;1e24;1e27;1e30;1e33;1e36;1e39;1e42;1e45;1e48;1e51;1e54;1e57;1e60;1e63;1e66;1e69;1e72;1e75;1e78;1e81;1e84;1e87;1e90;1e93;1e96;1e99;1e102;1e105;1e108;1e111;1e114;1e117;1e120;1e123;1e126;1e129;1e132;1e135;1e138;1e141;1e144;1e147;1e150;1e153;1e156;1e159;1e162;1e165;1e168;1e171;1e174;1e177;1e180;1e183;1e186;1e189;1e192;1e195;1e198;1e201;1e204;1e207;1e210;1e213;1e216;1e219;1e222;1e225;1e228;1e231;1e234;1e237;1e240;1e243;1e246;1e249;1e252;1e255;1e258;1e261;1e264;1e267;1e270;1e273;1e276;1e279;1e282;1e285;1e288;1e291;1e294;1e297;1e300;1e303;1e306;1e309];
%
% Order of all multipliers:
pwr(idy) = 1; % pwr==3
if strcmp(dfar.scale,'long')
	pwr(~idy) = 2+2*(mlt-1); % pwr>3
else
	pwr(~idy) = 1+mlt; % pwr>3
end
pwr(end+1:ceil(nnz(idd)/2)) = 0; % pwr<3
%
for n = N:-1:1 % reverse order is required for long scale and compound multipliers
	% Hundreds:
	tmp = find(~cellfun('isempty',regexpi(tok{n,1},cOne,'once')));
	hun(n,~isempty(tmp)) = tmp;
	% Tens:
	tmp = find(~cellfun('isempty',regexpi(tok{n,2},cTy,'once')));
	ten(n,~isempty(tmp)) = tmp;
	% Ones:
	tmp = find(~cellfun('isempty',regexpi(tok{n,2},cOT,'once')));
	one(n,~isempty(tmp)) = tmp;
	% Power:
	if n<N && (pwr(n)==1 || isempty([tok{n+1,:}]))% long scale & compound
		pwr(n) = pwr(n)+pwr(n+1);
	end
	odr(n,1) = vec(1+pwr(n));
	% Decimal Digits:
	if ~isempty(tok{n,3})
		frc(n) = w2nDec(tok{n,3},odr(n),cOne);
	end
end
%
num = sum(sgn*frc+sgn*(100*hun+10*ten+one).*cast(odr,dfar.class),'native');
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nConvN
function out = w2nMatch(idx,nMlt,sMlt,sSfx,isp,isc)
% Return the regular expression string for the remaining multipliers.
%
if isempty(idx) || isc % all multipliers
	out = sprintf('(%s)%s',sMlt,sSfx);
elseif idx(end)<2 % matched 'million'
	out = '(?!)'; % force failure
elseif isp % peletier
	idy = idx(end);
	if rem(idy,2) % eg: (M|B|Tr)illi(on|ard)
		out = sprintf('(%s)%s',sMlt(1:nMlt(idy)-1),sSfx);
	else % eg: Trillion
		out = sprintf('%sillion',sMlt(nMlt(idy)+1:nMlt(idy+1)-1));
		if idy>3 % eg: Trillion|(M|B)illi(on|ard)
			out = sprintf('%s|(%s)%s',out,sMlt(1:nMlt(idy)-1),sSfx);
		end
	end
else % eg: (M|B|Tr)illion
	out = sprintf('(%s)%s',sMlt(1:nMlt(idx(end))-1),sSfx);
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nMatch
function [nNew,xNew] = w2nIndex(s,nOld,n,xOld,cMlt,isc)
% Identify the most recently parsed multiplier, return its index.
%
% Identify only multipliers < previously matched multipliers (faster):
if ~isc && numel(xOld)
	cMlt = cMlt(1:xOld-1);
end
x = [find(~cellfun('isempty',regexpi(s(1+n:end),cMlt,'once')),1,'first'),0];
%
xNew = [xOld,x(1)];
nNew = [nOld,n];
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nIndex
function [num,spl] = w2nKnuth(str,dfar,rEdg,rDec,rToO,pSpa,pSig,cTy,cOT,cOne)
%
cMlt = {'M','B','Tr','Quadr','Quint','Sext'};%yllion
%
%% Create Regular Expression %%
%
% Normal:
rHun = sprintf('%s(%sHundred(%s%s)?)?',rToO,pSpa,pSpa,rToO);
rMyr = sprintf('%s(%sMyriad(%s%s)?)?', rHun,pSpa,pSpa,rHun);
rMyl = sprintf('%s(%sMyllion(%s%s)?)?',rMyr,pSpa,pSpa,rMyr);
rByl = sprintf('%s(%sByllion(%s%s)?)?',rMyl,pSpa,pSpa,rMyl);
rTry = sprintf('%s(%sTryllion(%s%s)?)?',rByl,pSpa,pSpa,rByl);
rQua = sprintf('%s(%sQuadryllion(%s%s)?)?',rTry,pSpa,pSpa,rTry);
rQui = sprintf('%s(%sQuintyllion(%s%s)?)?',rQua,pSpa,pSpa,rQua);
rSex = sprintf('%s(%sSextyllion(%s%s)?)?',rQui,pSpa,pSpa,rQui);
% Highest:
rDgt = sprintf('(Zero%s?|%s%s)',rDec,rToO,rDec);%ZD?|(TO)D
rMlt = sprintf(sprintf('(%s%%syllion)?',pSpa),cMlt{:});
rHig = sprintf('(%s(%sHundred)?(%sMyriad)?%s)',rDgt,pSpa,pSpa,rMlt);
%
rExp = sprintf('%s(%s|%s|%s%s?)',pSig,rEdg,rHig,rSex,rDec);
%
[rExp,igma] = w2nCase(dfar,rExp);
rExp = sprintf('(?:(%s))%s(?:(%s))', dfar.prefix, rExp, dfar.suffix);
%
%% Locate any Number Substrings in String %%
%
[cTok,spl] = regexp(str,rExp, 'tokens','split', igma);
%
if isempty(cTok) % no numbers found
	num = zeros(0,0,dfar.class);
	return
end
%
cTok = vertcat(cTok{:});
[bMlt,nEnd] = regexpi(cTok(:,2),sprintf('(Hundred|Myriad|(%s)yllion)',w2nJoin(cMlt)));
vSgn = 1-2*strncmpi(cTok(:,1),'Negative',8);
%
%% Convert Number Substrings to Numeric %%
%
num = zeros(1,size(cTok,1),dfar.class);
idi = strcmpi(cTok(:,2),'Infinity');
idn = strncmpi(cTok(:,2),'Not',3);
num(idi) = vSgn(idi)*Inf;
num(idn) = vSgn(idn)*NaN;
%
rgx = sprintf('()%s?%s?',rToO,rDec);
%
cMlt = [{'Hundred','Myriad'},strcat(cMlt,'yllion')];
%
for m = find(~(idi|idn)')
	ids = [0,nEnd{m};bMlt{m}-1,numel(cTok{m,2})];
	num(m) = w2nConvK(dfar,rgx,vSgn(m),cTok{m,2},cMlt,cTy,cOT,cOne,diff(ids(:)));
end
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nKnuth
function num = w2nConvK(dfar,rgx,sgn,str,cMlt,cTy,cOT,cOne,idd)
% Convert a knuth number string into a numeric scalar.
%
spl = mat2cell(str,1,idd(1:end-(idd(end)==0)));
tok = regexpi(spl(1:2:end),rgx,'tokens','once');
tok(cellfun('isempty',tok)) = {{'','',''}};
tok = vertcat(tok{:});
N = size(tok,1);
spl(end+1:2*N) = {''};
%
frc = zeros(N,1,dfar.class); one=frc; ten=frc; pwr=[];
% E-notation has better precision than using 10^N:
vec = [1e0;1e2;1e4;1e8;1e16;1e32;1e64;1e128;1e256];
%
for n = N:-1:1 % Reverse order is required for all multipliers
	% Tens:
	tmp = find(~cellfun('isempty',regexpi(tok{n,2},cTy,'once')));
	ten(n,~isempty(tmp)) = tmp;
	% Ones:
	tmp = find(~cellfun('isempty',regexpi(tok{n,2},cOT,'once')));
	one(n,~isempty(tmp)) = tmp;
	% Power:
	tmp = find(~cellfun('isempty',regexpi(spl{2*n},cMlt,'once')));
	if ~isempty(tmp)
		pwr(pwr<tmp) = [];
		pwr = [tmp,pwr]; %#ok<AGROW>
	end
	odr(n,1) = prod(vec(1+pwr));
	% Decimal Digits:
	if ~isempty(tok{n,3})
		frc(n) = w2nDec(tok{n,3},odr(n),cOne);
	end
end
%
num = sum(sgn*frc+sgn*(10*ten+one).*cast(odr,dfar.class),'native');
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%w2nConvK