% ops.chanMap             = 'C:\Users\Dell Workstation\Documents\GitHub\KiloSort2_Tetrode\configFiles\Tetrodex4Default_kilosortChanMap.mat';
% ops.chanMap = 1:ops.Nchan; % treated as linear probe if no chanMap file

% sample rate
ops.fs = 25000;  

% frequency for high pass filtering (150)
ops.fshigh = 400;   

% minimum firing rate on a "good" channel (0 to skip)
ops.minfr_goodchannels = 0.1; % set to 0.1 by default 

% threshold on projections (like in Kilosort1, can be different for last pass like [10 4])
ops.Th = [4 2]; % [10 4] 

% how important is the amplitude penalty (like in Kilosort1, 0 means not used, 10 is average, 50 is a lot) 
ops.lam = 10;  

% splitting a cluster at the end requires at least this much isolation for each sub-cluster (max = 1)
ops.AUCsplit = 0.8; 

% minimum spike rate (Hz), if a cluster falls below this for too long (5 batches) it gets removed
ops.minFR = 1/100; 

% number of samples to average over (annealed from first to second value) 
ops.momentum = [20 400]; 

% spatial constant in um for computing residual variance of spike, criteria
% for collecting new potential templates at each iterations
ops.sigmaMask = 50; 

% threshold crossings for pre-clustering (in PCA projection space)
ops.ThPre = 6; % used to be 8
%% danger, changing these settings can lead to fatal errors
% options for determining PCs
ops.spkTh           = -3;      % spike threshold in standard deviations (-6)
ops.reorder         = 1;       % whether to reorder batches for drift correction. 
ops.nskip           = 25;  % how many batches to skip for determining spike PCs

ops.GPU                 = 1; % has to be 1, no CPU version yet, sorry
% ops.Nfilt               = 1024; % max number of clusters
ops.nfilt_factor        = 4; % max number of clusters per good channel (even temporary ones)Dflt:4
ops.ntbuff              = 64;    % samples of symmetrical buffer for whitening and spike detection
ops.NT                  = 64*1024+ ops.ntbuff; % must be multiple of 32 + ntbuff. This is the batch size (try decreasing if out of memory).Was 64*1024+ ops.ntbuff corresponding to roughly 2s, increasing to 6s for better drift correction (enough spikes)
ops.whiteningRange      = 7; % number of channels to use for whitening each channel, used to be 32, but the code in get_whitening_matrix takes min(Nchannels,ops.whiteningRange). Then whitening local takes the Nrange closest neighbors including the target channel (neighbor calculated as euuclidian distance from channel map)
ops.nSkipCov            = 25; % compute whitening matrix from every N-th batch, was 25, set to 10 to accomodate for bigger batch sizes
ops.scaleproc           = 200;   % int16 scaling of whitened data
ops.nPCs                = 3; % how many PCs to project the spikes into
ops.useRAM              = 0; % not yet available

%%
% kcoords is used to forcefully restrict templates to channels in the same
% channel group. An option can be set in the master_file to allow a fraction 
% of all templates to span more channel groups, so that they can capture shared 
% noise across all channels. This option is

% ops.criterionNoiseChannels = 2;  %% THIS OPTION DOES NOT EXIST IN
% KILOSORT2, I CANNOT FIND ANY REFERENCE TO THIS PARAMEETR IN THE CODE

% if this number is less than 1, it will be treated as a fraction of the total number of clusters

% if this number is larger than 1, it will be treated as the "effective
% number" of channel groups at which to set the threshold. So if a template
% occupies more than this many channel groups, it will not be restricted to
% a single channel group.