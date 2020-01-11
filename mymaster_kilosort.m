function mymaster_kilosort(Server_folder, rootZ,SaveMat)
%% you need to change most of the paths in this block

addpath(genpath('C:\Users\Dell Workstation\Documents\GitHub\KiloSort2')) % path to kilosort folder
addpath('C:\Users\Dell Workstation\Documents\GitHub\npy-matlab') % for converting to Phy
if nargin<2
    rootZ = 'C:\Users\Dell Workstation\Documents\DataKilosort2'; % the raw data binary file is in this folder
end
if nargin<3
    SaveMat = 0;
end
rootH = fullfile(rootZ,'Temp'); % path to temporary binary file (same size as data, should be on fast SSD)
pathToYourConfigFile = 'C:\Users\Dell Workstation\Documents\GitHub\KiloSort2_Tetrode\configFiles'; % take from Github folder and put it somewhere else (together with the master_file)
% chanMapFile = 'Tetrodex4Default_kilosortChanMap.mat';
chanMapFile = 'Tetrodex4Co_kilosortChanMap.mat';


ops.trange = [0 Inf]; % time range to sort

run(fullfile(pathToYourConfigFile, 'configFile16.m'))
ops.fproc       = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD
if ~exist(rootH, 'dir')
    mkdir(rootH)
end
ops.chanMap = fullfile(pathToYourConfigFile, chanMapFile);

%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)


% find the binary file
fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
ops.fbinary = fullfile(rootZ, fs(1).name);

% Calculate the nmuber of channels in the recording
ops.NchanTOT = length(strfind(fs(1).name,'_'))-2;

% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);

% time-reordering as a function of drift
rez = clusterSingleBatches(rez);

% saving here is a good idea, because the rest can be resumed after loading rez
save(fullfile(rootZ, 'rez.mat'), 'rez', '-v7.3');

% main tracking and template matching algorithm
rez = learnAndSolve8b(rez);

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
mkdir(Server_folderSS)
[s(1),m,e]=copyfile(fullfile( rootZ, '*.npy'), Server_folderSS, 'f');
[s(2),m,e]=copyfile(fullfile( rootZ, '*.bin'), Server_folderSS, 'f');
[s(3),m,e]=copyfile(fullfile( rootZ, '*.tsv'), Server_folderSS, 'f');
[s(4),m,e]=copyfile(fullfile( rootZ, '*.mat'), Server_folderSS, 'f');
[s(5),m,e]=copyfile(fullfile( rootZ, '*.py'), Server_folderSS, 'f');
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
