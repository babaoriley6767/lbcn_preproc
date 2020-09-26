function phaseRT = phaseRTCorrAll(sbj_name, project_name, block_names, dirs,locktype,elecs)


 % time within a trial at which to correlate 
% 
% Load globalVar
fn = sprintf('%s/originalData/%s/global_%s_%s_%s.mat',dirs.data_root,sbj_name,project_name,sbj_name,block_names{1});
load(fn,'globalVar');

dir_out = [dirs.result_root,'/',project_name,'/',sbj_name,'/allblocks'];
if ~exist(dir_out)
    mkdir(dir_out)
end

dir_in = [dirs.data_root,'/SpecData/',sbj_name,'/',block_names{1},'/EpochData'];
load(sprintf('%s/SpeciEEG_%slock_%s_%.2d.mat',dir_in,locktype,block_names{1},elecs(1)))
nfreqs = length(data.freqs);
goodTrials = find(strcmp(data.trialinfo.condNotAfterMtn,'city') & ~isnan(data.trialinfo.RT));

phaseRT.rho = nan(globalVar.nchan,nfreqs,length(data.time));
phaseRT.p = nan(globalVar.nchan,nfreqs,length(data.time));
phaseRT.rho_norm = nan(globalVar.nchan,nfreqs,length(data.time)); % first normalize RTs within each block
phaseRT.p_norm = nan(globalVar.nchan,nfreqs,length(data.time)); % first normalize RTs within each block
phaseRT.time = data.time;
phaseRT.freqs = data.freqs;
phaseRT.channame = globalVar.channame;
% phaseRTCorr = nan(globalVar.nchan,nfreqs);
% phaseRTpval = nan(globalVar.nchan,nfreqs);

for ei = 1:length(elecs)
    el = elecs(ei);
    data_tmp.phase = [];
    data_tmp.RT = [];
    data_tmp.RT_norm = [];
    for bi = 1:length(block_names)
        bn = block_names{bi};
        dir_in = [dirs.data_root,'/SpecData/',sbj_name,'/',bn,'/EpochData'];
        bn = block_names{bi};
        load(sprintf('%s/SpeciEEG_%slock_%s_%.2d.mat',dir_in,locktype,bn,el))
        goodTrials = find(strcmp(data.trialinfo.condNotAfterMtn,'city') & ~isnan(data.trialinfo.RT));
        data_tmp.phase = cat(2,data_tmp.phase,data.phase(:,goodTrials,:));
        data_tmp.RT = [data_tmp.RT; data.trialinfo.RT(goodTrials)];
        data_tmp.RT_norm = [data_tmp.RT_norm; zscore(data.trialinfo.RT(goodTrials))];
    end
    for fi = 1:nfreqs
        for ti = 1:length(data.time)
            [phaseRT.rho(el,fi,ti),phaseRT.p(el,fi,ti)]=circ_corrcl(data_tmp.phase(fi,:,ti),data_tmp.RT);
            [phaseRT.rho_norm(el,fi,ti),phaseRT.p_norm(el,fi,ti)]=circ_corrcl(data_tmp.phase(fi,:,ti),data_tmp.RT_norm);
        end
    end
    disp(['Elec ',num2str(el)])
end
