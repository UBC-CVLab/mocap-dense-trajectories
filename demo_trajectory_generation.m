% This demo shows how to call a functions that calls trajectory generation
% as a black-box function. If you want to see more details of it, see
% DEMO_TRAJECTORY_GENERATION_2.
%
% --
% Julieta


%% First load the data.
FPS       = 24; % Render at 24 frames per second.
BASE_PATH = 'data/';

tic;
[imocap, ~] = load_imocap_seq( '12_02', FPS, BASE_PATH );
fprintf('%.4f seconds loading the file.\n', toc);

%% Define parameters of the trajectory generation.
theta         = pi/2;
phi           = pi/3;
point_density = 20;
d             = 100;
look_at       = imocap.trans{1}{1}(1:3, 4); % center of the body. Used to center the camera
up            = [0 1 0];                    % y-axis
HPRparam      = 3;
lenTraj       = 15;
person_size   = 500;


%% Get the features!
tic;
[traj_feats, relative_thetas, relative_phis,rectangles ] = ...
    imocap2trajectories( imocap, theta, phi, point_density, d, look_at, up, HPRparam, lenTraj, person_size );
fprintf('%.4f seconds computing trajectories.\n', toc);
