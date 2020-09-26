function [elecInfo_table, elecCoord]=sub2AvgBrainCustom_leptovox(cfg, dirs, sbj_name, fsDir_local)
%function [avgCoords, elecNames, isLeft, avgVids, subVids]=sub2AvgBrain(subj,cfg)
%
% This function maps electrodes from patient space to the FreeSurfer average
% brain. For subdural electrodes, it takes RAS "pial" coordinates (snapped 
% to the pial surface) and maps it to the corresponding location on the pial 
% surface of FreeSurfer's average brain. Depth electrodes are mapped to
% MNI305 space with an affine transformation; these coordinates too can be
% visualized on the FreeSurfer average brain.
%
% Input:
%   subj = FreeSurfer subject name
%
% Optional Inputs: passed as fields in a configuration structure
%   plotEm = 1 or 0.  If nonzero, a figure is created illustrating
%            electrode locations on subject and average pial surface.
%            Click on electrodes to see names. Depth electrodes are not
%            shown. {default: 1}
%   elecCoord = N-by-3 numeric array with RAS electrode coordinates. 
%               {default: not used; the function looks into the subject's 
%               Freesurfer folder for electrode coordinate file instead}
%   elecNames = cell array of strings with electrode names, corresponding
%               to the rows of elecCoord. This argument is required 
%               if elecCoord is used. {default: not used; the function
%               looks into the subject's Freesurfer folder for electrode
%               name file instead}
%   isLeft    = N-dimensional binary vector where N is the # of electrodes.
%               0 indicates that an electrode is on/in the right hemisphere.
%               1 indicates a left hemisphere location. This argument is
%               required if elecCoord is used. Otherwise this information
%               is read from the participant's electrodeNames file.
%   isSubdural= N-dimensional binary vector where N is the # of electrodes.
%               0 indicates that an electrode is a depth electrode. 1
%               indicates a subdural electrode. This argument is only used
%               if elecNames is used. Otherwise this information is read
%               from the participant's electrodeNames file {default:
%               all electrodes are assumed to be subdural}
%   rmDepths = 1 or 0. If nonzero, depth electrodes are ignored. {default: 0}
%
% Outputs:
%   avgCoords = Electrode coordinates on FreeSurfer avg brain pial surface
%                (RAS coordinates)
%   elecNames = Channel names with the participant's name appended to the
%               beginning (e.g., PT001-Gd1)
%   isLeft    = N-dimensional binary vector where N is the # of electrodes.
%               0 indicates that an electrode is on/in the right hemisphere.
%               1 indicates a left hemisphere location.
%   avgVids   = Index of subject pial surface vertices corresponding to each electrode
%   subVids   = Index of average pial surface vertices corresponding to each electrode
%
%
% Author:
% David Groppe
% Mehtalab
% March, 2012
%

% History
% 2015-6 Made compatible with Yang brain shift correction algorithm

% parse input parameters in cfg structure and set defaults
if  ~isfield(cfg,'plotEm'),         plotEm = 1;     else    plotEm = cfg.plotEm;            end
if  ~isfield(cfg,'elecCoord'),      elecCoord = []; else    elecCoord = cfg.elecCoord;      end
if  ~isfield(cfg,'elecNames'),      elecNames = []; else    elecNames = cfg.elecNames;      end
if  ~isfield(cfg,'isLeft'),        isLeft = [];   else    isLeft = cfg.isLeft;      end
if  ~isfield(cfg,'isSubdural'),     isSubdural = [];   else    isSubdural = cfg.isSubdural;      end
if  ~isfield(cfg,'rmDepths'),       rmDepths = 0;   else    rmDepths = cfg.rmDepths;      end
% checkCfg(cfg,'sub2AvgBrain.m');


% FreeSurfer Subject Directory
subDir = dirs.freesurfer;
subj = dir(subDir);
subj=subj(~ismember({subj.name},{'.','..', '.DS_Store'}) & horzcat(subj.isdir) == 1);
subj = subj.name;
subDir = [subDir subj];
avgDir=fsDir_local;
% subDir=fullfile(fsDir,subj);


if ~exist(avgDir,'dir')
    error('Folder for fsaverage is not present in FreeSurfer subjects directory (%s). Download it from here https://osf.io/qe7pz/ and add it.', ...
        fsDir);
end
if ~exist(subDir,'dir')
    error('Folder for %s is not present in FreeSurfer subjects directory (%s).',subj,fsDir);
end


% Take care of electrode names, hemisphere, and type
if isempty(elecNames)
    % Import electrode names
    elecFname=fullfile(subDir,'elec_recon',[subj '.electrodeNames']);
    elecInfo=csv2Cell(elecFname,' ',2);
    elecInfo_table = table(elecInfo(:,1), elecInfo(:,2), elecInfo(:,3));
    elecInfo_table.Properties.VariableNames = {'Name', 'Depth_Strip_Grid', 'Hem'};
    elecNames=elecInfo(:,1);
    nElec=size(elecInfo,1);
    isLeft=zeros(nElec,1);
    isSubdural=zeros(nElec,1);
    for a=1:nElec,
        if ~strcmpi(elecInfo{a,2},'D')
            isSubdural(a)=1;
        end
        if strcmpi(elecInfo{a,3},'L')
            isLeft(a)=1;
        end
    end
else
    nElec=length(elecNames);
    if isempty(isLeft)
        error('You need to specify cfg.isLeft when using cfg.elecNames');
    else
        if length(isLeft)~=nElec,
            error('elecNames and isLeft do not have the same # of electrodes.');
        end
    end
    if isempty(isSubdural),
        % assume all electrodes are subdural
        isSubdural=ones(nElec,1);
    else
        if length(isSubdural)~=nElec,
            error('isSubdural and isLeft do not have the same # of electrodes.');
        end
    end
end


% Take care of electrode coordinates in participant space
if isempty(elecCoord) % no electrode coordinates have been passed in the function call:
    % Import electrode PIAL coordinates
    coordFname=fullfile(subDir,'elec_recon',[subj '.LEPTOVOX']);
    coordCsv=csv2Cell(coordFname,' ',2);
    elecCoord=zeros(nElec,3);
    for a=1:nElec,
        for b=1:3,
            elecCoord(a,b)=str2double(coordCsv{a,b});
        end
    end
else
    if size(elecCoord,1)~=nElec,
        error('Electrode coordinates need to have the same number of rows as electrode names.');
    end
end


%% Add subject name as prefix to electrode names:
for a=1:nElec,
   elecNames{a}=[subj '-' elecNames{a}];
end