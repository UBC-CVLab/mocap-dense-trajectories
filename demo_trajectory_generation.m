% This demo shows how to generate dense trajectories from a mocap file
% as a black-box function. If you want to see more details of the 
% process, check DEMO_TRAJECTORY_GENERATION_2.
%
% --
% Julieta

%% First load the data.
FPS       = 24; % Render at 24 frames per second.
BASE_PATH = 'data/';

tic;
[imocap, ~] = load_imocap_seq( '12_02', FPS, BASE_PATH );
fprintf('%.4f seconds loading the mocap file.\n', toc);

%% Define parameters of the trajectory generation.
theta         = pi/2;  % Angle of the camera with the vertical.
phi           = pi/3;  % Angle of the camera with the person's hip heading.
point_density = 20;    % How many points to track per unit area.
d             = 100;   % Distance from the person to the camera.
look_at       = imocap.trans{1}{1}(1:3, 4); % Center of the body.
up            = [0 1 0]; % Up vector for the camera. The y axis for convention.
HPRparam      = 3;     % Parameter passed to the code of Katz et al for Hidden Point Removal.
lenTraj       = 15;    % Trajectories will be this number of frames long.
person_size   = 500;   % Used to remove very short trajectories.

%% Get the features!
tic;
[traj_feats, relative_thetas, relative_phis, rectangles ] = ...
    imocap2trajectories( imocap, theta, phi, point_density, d, look_at, up, HPRparam, lenTraj, person_size );
fprintf('%.4f seconds computing trajectories.\n', toc);
