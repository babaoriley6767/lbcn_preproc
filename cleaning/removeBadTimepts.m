function dataNew = removeBadTimepts(data,noise_fields)
% returns new data structure where noisy timepoints of data
% (wave and/or phase fields) are set to NaN


nd = ndims(data.wave); % determine if spectral data or timecourse
ntrials = size(data.wave,nd-1);
if isempty(noise_fields) 
    noise_fields = {'bad_inds'};
end

bad_inds = cell(ntrials,1);
for i = 1:length(noise_fields)
    bad_inds = cellfun(@union,bad_inds,data.trialinfo.(noise_fields{i}),'UniformOutput',false);
end

datafields = {'phase','wave'}; % remove bad time pts from these fields (if exist)
datafields = intersect(fieldnames(data),datafields);
otherfields = setdiff(fieldnames(data),datafields);


for fi = 1:length(datafields)
    dataNew.(datafields{fi}) = data.(datafields{fi});
end

% bfields = {'bad_inds','badinds'}; % was named slightly differently for different sbjs
% bfield = intersect(bfields,fieldnames(data.trialinfo));

% replace bad timepts in each trial with NaN
for ti = 1:ntrials
%     bad_inds = data.trialinfo.(bfield{1}){ti};
    bad_inds{ti} = setdiff(bad_inds{ti},0);
    if ~isempty(bad_inds{ti})
        for fi = 1:length(datafields)
            if (nd == 3) % spectral data
                dataNew.(datafields{fi})(:,ti,bad_inds{ti})=NaN;
            else % timecourse data
                dataNew.(datafields{fi})(ti,bad_inds{ti})=NaN;
            end
        end
    end
end

% keep other fields from data
for fi = 1:length(otherfields)
    dataNew.(otherfields{fi})=data.(otherfields{fi});
end




