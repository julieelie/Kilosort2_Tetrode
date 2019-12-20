function createChannelMapFileTetrode(SubjCoordx, SubjCoordy, OutputPath)
if nargin<3
    OutputPath = 'C:\Users\Dell Workstation\Documents\GitHub\Kilosort2_Tetrode\configFiles';
end
if nargin==0
    %     % Cooper's coordinates
    %     SubjCoordx = [3600 3200 3200 3600]-3200;
    %     SubjCoordy = [11000 10700 10300 10700]-10300;
    SubjCoordx = [0 0 0 0];
    SubjCoordy = [0 25 50 75];
end
%  create a channel map file for 4 tetrode
Nchannels = 16;

xcoords   = repmat(10*[1 2 1 2]', 1, Nchannels/4) + SubjCoordx.*ones(4,1);
xcoords   = xcoords(:); % a column vector
ycoords   = repmat(10*[2 2 1 1]', 1, Nchannels/4) + SubjCoordy.*ones(4,1);
ycoords   = ycoords(:); % a column vector
kcoords   = [1 2 3 4].*ones(Nchannels/4,1); % grouping of channels (i.e. tetrode groups), column vector
kcoords = kcoords(:);
% Cooper has no channel 11 (12th channel)
xcoords(12) =[];
ycoords(12) =[];
kcoords(12) =[];

connected = true(Nchannels-1, 1);
chanMap   = 1:(Nchannels-1); % a row vector)
chanMap0ind = chanMap - 1; % a row vector

fs = 31250; % sampling frequency of Deuteron
save(fullfile(OutputPath, 'Tetrodex4Co_kilosortChanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')


%% General map
if nargin==0
    % General coordinates
    SubjCoordx = [0 0 0 0];
    SubjCoordy = [0 25 50 75];
end
%  create a channel map file for 4 tetrode
Nchannels = 16;
connected = true(Nchannels, 1);
chanMap   = 1:Nchannels; % a row vector)
chanMap0ind = chanMap - 1; % a row vector
xcoords   = repmat(10*[1 2 1 2]', 1, Nchannels/4) + SubjCoordx.*ones(4,1);
xcoords   = xcoords(:); % a column vector
ycoords   = repmat(10*[2 2 1 1]', 1, Nchannels/4) + SubjCoordy.*ones(4,1);
ycoords   = ycoords(:); % a column vector
kcoords   = [1 2 3 4].*ones(Nchannels/4,1); % grouping of channels (i.e. tetrode groups), column vector
kcoords = kcoords(:);

fs = 31250; % sampling frequency of Deuteron
save(fullfile(OutputPath, 'Tetrodex4Default_kilosortChanMap.mat'), ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')

%% Map for 1 tetrode

Nchannels = 4;
connected = true(Nchannels, 1);
chanMap   = 1:Nchannels;
chanMap0ind = chanMap - 1;

ycoords   = repmat([1 2 3 4]', 1, Nchannels/4);
ycoords   = ycoords(:);
xcoords   = repmat(1:Nchannels/4, 4, 1);
xcoords   = xcoords(:);
kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)

fs = 31250; % sampling frequency (Hz) of Deuteron

save(fullfile(OutputPath,'Tetrodex1_kilosortChanMap.mat'), ...
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