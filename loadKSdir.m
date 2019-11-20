function spikeStruct = loadKSdir(ksDir, varargin)
% ksDir: directory containing the spike sorting results
% optional iput: a strcture with potential fields 'excludeNoise' (a logical
% value) and 'loadPCs' (logical value)
if ~isempty(varargin)
    params = varargin{1};
else
    params = [];
end

if ~isfield(params, 'excludeNoise')
    params.excludeNoise = true;
end
if ~isfield(params, 'loadPCs')
    params.loadPCs = false;
end

% load spike data

spikeStruct = loadParamsPy(fullfile(ksDir, 'params.py'));

ss = readNPY(fullfile(ksDir, 'spike_times.npy')); % detected events position is # of samples int16
% st = double(ss)/spikeStruct.sample_rate; % detected events times in s
spikeTemplates = readNPY(fullfile(ksDir, 'spike_templates.npy')) +1 ; % note: zero-indexed so adding 1 to get 1 indexed

if exist(fullfile(ksDir, 'spike_clusters.npy'),'file')
    clu = readNPY(fullfile(ksDir, 'spike_clusters.npy')) +1; % note: zero-indexed so adding 1 to get 1 indexed
else
    clu = spikeTemplates;
end

tempScalingAmps = readNPY(fullfile(ksDir, 'amplitudes.npy'));

if params.loadPCs
    pcFeat = readNPY(fullfile(ksDir,'pc_features.npy')); % nSpikes x nFeatures x nLocalChannels
    pcFeatInd = readNPY(fullfile(ksDir,'pc_feature_ind.npy')); % nTemplates x nLocalChannels
else
    pcFeat = [];
    pcFeatInd = [];
end

cgsFile = '';
if exist(fullfile(ksDir, 'cluster_groups.csv'),'file') 
    cgsFile = fullfile(ksDir, 'cluster_groups.csv');
end
if exist(fullfile(ksDir, 'cluster_group.tsv'),'file') 
   cgsFile = fullfile(ksDir, 'cluster_group.tsv');
end 
if ~isempty(cgsFile)
    [cids, cgs] = readClusterGroupsCSV(cgsFile);% cids: cluster ID number; cgs: cluster group or label (noise = 0, mua = 1, good =2, unsorted =3)

    if params.excludeNoise
        noiseClusters = cids(cgs==0);

        % st = st(~ismember(clu, noiseClusters));% get rid of detected events that correspond to noise cluster
        ss = ss(~ismember(clu, noiseClusters));% get rid of detected events that correspond to noise cluster
        spikeTemplates = spikeTemplates(~ismember(clu, noiseClusters));
        tempScalingAmps = tempScalingAmps(~ismember(clu, noiseClusters));        
        
        if params.loadPCs
            pcFeat = pcFeat(~ismember(clu, noiseClusters), :,:);
            %pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
        end
        
        clu = clu(~ismember(clu, noiseClusters));
        cgs = cgs(~ismember(cids, noiseClusters));
        cids = cids(~ismember(cids, noiseClusters));
        
        
    end
    
else
    clu = spikeTemplates;
    
    cids = unique(spikeTemplates);
    cgs = 3*ones(size(cids));
end
    

coords = readNPY(fullfile(ksDir, 'channel_positions.npy'));
ycoords = coords(:,2); xcoords = coords(:,1);
temps = readNPY(fullfile(ksDir, 'templates.npy'));

winv = readNPY(fullfile(ksDir, 'whitening_mat_inv.npy'));

% spikeStruct.st = st; % spike times in s
spikeStruct.ss = ss; % spike position in the original vector CSC file
spikeStruct.spikeTemplates = spikeTemplates; % template ID of each spike, this vector indexes in temps for retrieving the template shape
spikeStruct.clu = clu; % cluster ID of each spike
spikeStruct.tempScalingAmps = tempScalingAmps; % scaling factor of the template of each spike
spikeStruct.cgs = cgs; % label of each cluster ID (1: MUA; 2: Good; 3: unsorted), same size as cids
spikeStruct.cids = cids; % Cluster IDs same size as cgs
spikeStruct.xcoords = xcoords; % x coordinates of each channel as entered in kilosort2
spikeStruct.ycoords = ycoords;% y coordinates of each channel as entered in kilosort2
spikeStruct.temps = temps; % Ntemplates x template length x N channels, shape of all templates detected by kilosort2, indexed in by spikeTemplates for each spike
spikeStruct.winv = winv; % inverse whitening matrix
spikeStruct.pcFeat = pcFeat; % if requested (params.loadPCs = true), weigths in the PC space of each channel for each spike
spikeStruct.pcFeatInd = pcFeatInd;