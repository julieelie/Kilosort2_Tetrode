function mymaster_kilosort_HR(Server_folder, rootZ,SaveMat)
%% you need to change most of the paths in this block

addpath(genpath('C:\Users\Dell Workstation\Documents\GitHub\KiloSort2_Tetrode')) % path to kilosort2 folder
addpath('C:\Users\Dell Workstation\Documents\GitHub\npy-matlab') % for converting to Phy
if nargin<2
    rootZ = 'C:\Users\Dell Workstation\Documents\DataKilosort2'; % the raw data binary file is in this folder
end
if nargin<3
    SaveMat = 0;
end
rootH = fullfile(rootZ,'Temp'); % path to temporary binary file (same size as data, should be on fast SSD)
pathToYourConfigFile = 'C:\Users\Dell Workstation\Documents\GitHub\KiloSort2_Tetrode\configFiles'; % take from Github folder and put it somewhere else (together with the master_file)



ops.trange = [0 Inf]; % time range to sort

run(fullfile(pathToYourConfigFile, 'configFile4Array.m'))
ops.fproc       = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD
if ~exist(rootH, 'dir')
    mkdir(rootH)
end


%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)

% find the binary file
fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
ops.fbinary = fullfile(rootZ, fs(1).name);
BIRDID = fs(1).name(1:7);
Date = fs(1).name(9:14);

% Calculate the nmuber of channels in the recording
ops.NchanTOT = 7;

% Find the good map for tetrodes XXX ALSO SOMETHING YOU WANT TO CHECK FOR
% YOUR DATA!!!XXX
if ops.NchanTOT==16
    chanMapFile = 'Tetrodex4Default_kilosortChanMap.mat';
elseif ops.NchanTOT==15 && strcmp(fs(1).name(1:5), '11689') % This is Hodor, who missed channel 11 (12th channel)
    chanMapFile = 'Tetrodex4Ho_kilosortChanMap.mat';
elseif ops.NchanTOT==4
    chanMapFile = 'Electrodex4_kilosortChanMap.mat';
else
    chanMapFile = sprintf('ElectrodeArray%dChannels_kilosortChanMap.mat', ops.NchanTOT);
end
if ~exist(fullfile(pathToYourConfigFile, chanMapFile),'file')
    chanMapFile = input('Indicate the name of the matfile for your channel map in C:\Users\Dell Workstation\Documents\GitHub\Kilosort2_Tetrode\configFiles:\n','s');
end
ops.chanMap = fullfile(pathToYourConfigFile, chanMapFile);

try
    % preprocess data to create temp_wh.dat
    rez = preprocessDataSub(ops);
    
    % plot the whitening matrix
    figure();imagesc(rez.Wrot)
    colorbar()
    title(sprintf('Whitening matrix %s %s', BIRDID, Date))
    saveas(gcf, fullfile(rootZ,'WhiteningMatrix'),'epsc')
catch % lower the threshold for spike detection !
    ops.spkTh           = -5;      % spike threshold in standard deviations (-6)
    % preprocess data to create temp_wh.dat
    rez = preprocessDataSub(ops);
    
    % plot the whitening matrix
    figure();imagesc(rez.Wrot)
    colorbar()
    title(sprintf('Whitening matrix %s %s', BIRDID, Date))
    saveas(gcf, fullfile(rootZ,'WhiteningMatrix'),'epsc')
end

% time-reordering as a function of drift
rez = clusterSingleBatches(rez);

% saving here is a good idea, because the rest can be resumed after loading rez
save(fullfile(rootZ, 'rez.mat'), 'rez', '-v7.3');

% main tracking and template matching algorithm
rez = learnAndSolve8b(rez);

% OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
% See issue 29: https://github.com/MouseLand/Kilosort/issues/29
rez = remove_ks2_duplicate_spikes(rez);

% final merges
rez = find_merges(rez, 1);

% final splits by SVD
rez = splitAllClusters(rez, 1);

% final splits by amplitudes
rez = splitAllClusters(rez, 0);

% decide on cutoff
rez = set_cutoff(rez);

fprintf('found %d good units \n', sum(rez.good>0))

% write to Phy
fprintf('Saving results to Phy  \n')
rezToPhy(rez, rootZ);

%% Transfer data back on the server
% Bring data back on the server
fprintf(1,'Transferring data from the local computer %s\n to the server %s\n', rootZ, Server_folder);
Server_folderSS = fullfile(Server_folder, 'spikesorted');
if exist(Server_folderSS, 'dir')
    rmdir(Server_folderSS, 's')
end
mkdir(Server_folderSS)
[s(1),m,e]=copyfile(fullfile( rootZ, '*.npy'), Server_folderSS, 'f');
[s(2),m,e]=copyfile(fullfile( rootZ, '*.bin'), Server_folderSS, 'f');
[s(3),m,e]=copyfile(fullfile( rootZ, '*.tsv'), Server_folderSS, 'f');
[s(4),m,e]=copyfile(fullfile( rootZ, '*.mat'), Server_folderSS, 'f');
[s(5),m,e]=copyfile(fullfile( rootZ, '*.py'), Server_folderSS, 'f');
[s(6),m,e]=copyfile(fullfile( rootZ, '*.eps'), Server_folderSS, 'f');
if any(~s)
    m %#ok<NOPRT>
    e %#ok<NOPRT>
    error('File transfer did not occur correctly from %s to %s\n', rootZ, Server_folderSS);
    s
else
    fprintf(1, 'All Done!\n')
end

%% if you want to save the results to a Matlab file...
if SaveMat
    % discard features in final rez file (too slow to save)
    rez.cProj = [];
    rez.cProjPC = [];
    
    % save final results as rez2
    fprintf('Saving final results in rez2  \n')
    fname = fullfile(rootZ, 'rez2.mat');
    save(fname, 'rez', '-v7.3');
end
end
