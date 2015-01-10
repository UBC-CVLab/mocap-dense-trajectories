w = which(mfilename());
thisDir = fileparts(w);
cd(thisDir);
addpath(thisDir);

% function to add directories and all its subdirectories to the paths
include  = @(d)addpath(genpath(d));

%% Load the data.
include(fullfile(thisDir, 'data'));

%% Load different util functions.
include(fullfile(thisDir, 'geometry'));
include(fullfile(thisDir, 'mocap'));
include(fullfile(thisDir, 'mocap-trajectories'));
include(fullfile(thisDir, 'visualization'));
include(fullfile(thisDir, 'semantic-representation'));

%% Third-party
include(fullfile(thisDir, 'third-party/'));
include(fullfile(thisDir, 'third-party/bvh-reader'));
include(fullfile(thisDir, 'third-party/hidden-point-removal'));
