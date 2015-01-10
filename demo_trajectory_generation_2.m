% This demo shows the trajectory generation process more in detail, should
% you want to see some of the nuts and bolts of it. It also has some pretty
% visualizations.
% 
% --
% Julieta

VISUALIZE = true;

%% First load the data.
FPS       = 24; % Render at 24 frames per second.
BASE_PATH = 'data/';

tic;
[imocap, ~] = load_imocap_seq( '12_02', FPS, BASE_PATH );
fprintf('%.4f seconds loading the file.\n', toc);

%% Create the bone surfaces.
point_density = 20;
bone_properties  = define_limb_prop(); % parameters describing limb volumes

tic;
imocap = create_human_surfaces( imocap, bone_properties, point_density );
fprintf('%.4f seconds constructing the surfaces.\n', toc);


%% Move the cylinders to their corresponding positions in the 3d world.
tic;
model_surfaces = put_surfaces_in_place( imocap );
fprintf('%.4f seconds constructing the human model.\n', toc);

%% Visualize the points without culling
if VISUALIZE,
    for i=1:numel(model_surfaces)
        clf;
        display_3D_points(model_surfaces, i);
        pause(1/FPS);
    end
end

%% Project the surface points to 2d, and compute their visibilities.
theta       = pi/3;
phi         = pi/3;
D           = 1000;
UP          = [0 1 0];                    % y-axis.
look_at     = imocap.trans{1}{1}(1:3, 4); % center of the body to center the camera.
HPRparam    = 3;

% Compute the camera matrix and position for the whole sequence.
[C, campos] = cam_matrix_theta_phi(theta, phi, D, look_at', UP);

tic;
projs2d = project_surface_points(model_surfaces, look_at', C, campos, HPRparam);
fprintf('%.4f seconds projecting the points to 2D.\n', toc);

%% Display the projected points.
if VISUALIZE,
    for i=1:numel(projs2d)
		clf;
        plot( projs2d(i).pts2d( 1, projs2d(i).visPts ), projs2d(i).pts2d( 2, projs2d(i).visPts ), 'r+');
        axis equal;
        set(gca,'YDir','Reverse'); % Consistent with the image coordiates.
        pause(1/FPS);
    end
end

%% Generate the trajectories.
lenTraj    = 15;
personSize = 200;
tic;
[all_traj, thetas, phis, rectangles] = generate_trajectories_for_view(model_surfaces, imocap, theta, phi, D, look_at, UP, HPRparam, lenTraj, personSize);
fprintf('%.4f seconds to compute trajectories.\n', toc);

%% Visualize the trajectories
if VISUALIZE,
    clf;
    % Showing generated trajectories.
    visualize_physical_trajectories(all_traj, rectangles, lenTraj);
end

%% Convert to feature trajectories.
tic;
all_traj_feats = cell(1, numel(all_traj));
traj_ends      = cell(1, numel(all_traj));
for i=1:numel(all_traj),
    [all_traj_feats{i}, traj_ends{i}] = physical_traj2traj_features( all_traj{i}, model_surfaces(i).fNum, lenTraj );
end
fprintf('%.4f seconds to convert the trajectories to features.\n', toc);

%% Convert back to physical trajectories and visualize -- just to check 
% that nothing was lost in the feature convertion process.
tic;
for i=1:numel(all_traj),
    all_traj{i} = traj_features2physical_traj( all_traj_feats{i}(:, 2:end), lenTraj );
end
fprintf('%.4f seconds to convert back to physical trajectories.\n', toc);

%% Visualize again.
if VISUALIZE,
    visualize_physical_trajectories(all_traj, rectangles, lenTraj);
end
