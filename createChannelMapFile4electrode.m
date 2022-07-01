function createChannelMapFile4electrode(OutputPath)
if nargin<1
    OutputPath = 'C:\Users\Dell Workstation\Documents\GitHub\Kilosort2_Tetrode\configFiles';
end

%% Map for Nchannels electrodes

Nchannels = 7;
connected = true(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;

ycoords   = 250.*(1:Nchannels)';
ycoords   = ycoords(:);
xcoords   = ones(Nchannels,1);
xcoords   = xcoords(:);
kcoords   = 1:Nchannels; %ones(Nchannels,1); % grouping of channels (i.e. tetrode groups) No grouping for electrode arrays

fs = 25000; % sampling frequency (Hz)

save(fullfile(OutputPath,sprintf('ElectrodeArray%dChannels_kilosortChanMap.mat', Nchannels)), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
%%

% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 0.2; 

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group. 