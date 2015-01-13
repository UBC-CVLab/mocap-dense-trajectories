%% Calculate IDs and distance between points. This needs to be done only once.
FPS       = 24; % Render at 24 frames per second.
BASE_PATH = 'data/';
VISUALIZE = 1;

tic;
[imocap, ~] = load_imocap_seq( '12_02', BASE_PATH, FPS);
% Create the bone surfaces.
point_density = 20;
bone_properties  = define_limb_prop(); % parameters describing limb volumes

[ imocap, cyl_params]  = create_human_surfaces( imocap, bone_properties, point_density );

% Move the cylinders to their corresponding positions in the 3d world.
[~, id_data] = put_surfaces_in_place( imocap );
fprintf('Done getting all the point ids and distances. %.4f  sec.\n', toc);


%% IMP: For all other files you just need to pass the cyl_params same as 
% calculated above to maintain consistency for IDs
tic;
[imocap, ~] = load_imocap_seq( '12_02', BASE_PATH, FPS);
% Create the bone surfaces.
point_density = 20;
bone_properties  = define_limb_prop(); % parameters describing limb volumes

imocap  = create_human_surfaces( imocap, bone_properties, [], cyl_params );

% Move the cylinders to their corresponding positions in the 3d world.
[model_surfaces] = put_surfaces_in_place( imocap );
fprintf('Time taken witout distance computation. %.4f sec .\n', toc);


%% Now rest of the pipeline is very similar to demo_trajectory_generation_2
% except we pass id_data to traj generation and it returns id of the point
% where each trajectory ends.
theta       = pi/2;
phi         = pi/3;
D           = 100;
UP          = [0 1 0];                    % y-axis.
look_at     = imocap.trans{1}{1}(1:3, 4); % center of the body to center the camera.
HPRparam    = 3;

% Generate the trajectories.
lenTraj    = 15;
personSize = 200;
tic;
[all_traj, thetas, phis, rectangles, all_traj_ids] = generate_trajectories_for_view( ...
    model_surfaces, imocap, theta, phi, D, look_at, UP, HPRparam, lenTraj, ...
    personSize, id_data);
fprintf('%.4f seconds to compute trajectories.\n', toc);

%% Calculate semantic features
tic;
[semantic_features] = ...
    generate_semantic_features_for_trajs(all_traj, imocap, theta, phi, D, look_at, UP);
fprintf('%.4f seconds to compute semantic features.\n', toc);


%% Visualize the trajectories
if VISUALIZE,
    visualize_physical_trajectories(all_traj, rectangles, lenTraj);
end

