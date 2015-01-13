% This script tests : 
% a) if the chosen viewpoint (theta, phi) leads to correct camera 
% location and the corresponding projection of 3d model,
% b) and the results are the same in XYZ (Y-up) and XZY (Z-up) coordinate system.
%
% Run this with different values of theta, phi and look at the visualizations.
%
% --Ankur
close all;
theta       = pi/3;   % angle from the vertical.
phi         = pi/6;   % angle is measure from the z-axis anti-clockwise.

%% First load the data.
FPS       = 24; % Render at 24 frames per second.
BASE_PATH = 'data/';

tic;
[imocap, ~] = load_imocap_seq( '12_02', BASE_PATH, FPS);
fprintf('%.4f seconds loading the file.\n', toc);

%% Create the bone surfaces.
point_density    = 20;
bone_properties  = define_limb_prop(); % parameters describing limb volumes

tic;
imocap = create_human_surfaces( imocap, bone_properties, point_density );
fprintf('%.4f seconds constructing the surfaces.\n', toc);

%% Move the cylinders to their corresponding positions in the 3d world.
tic;
model_surfaces = put_surfaces_in_place( imocap );
fprintf('%.4f seconds constructing the human model.\n', toc);

% Create a big matrix of all the points and norms.
bag_of_points = cell2mat( model_surfaces(1).pts3D' );


%% Project the surface points to 2d, and compute their visibilities.
D           = 100;
UP          = [0 1 0];                    % y-axis.
look_at     = imocap.trans{1}{1}(1:3, 4); % center of the body to center the camera.
HPRparam    = 3;

% Compute the camera matrix and position for the whole sequence.
[C, campos] = cam_matrix_theta_phi(theta, phi, D, look_at', UP);

[bone_loc, ~] = render_orthographic(bag_of_points, C);

%%
plot3(bag_of_points(1,:), bag_of_points(2,:), bag_of_points(3,:), 'r.');
title('3d model in the original coordinates (Y-up)');
axis equal;
hold on;
plot3(campos(1), campos(2), campos(3), 'ro');

figure;
plot(bone_loc(1, :), bone_loc(2, :), 'b.');
title('2d projection given the viewpoint (Y-up)');
axis equal;


%% Now convert them to xyz coordinate and test again.
UP           = [0 0 1];                    % y-axis.
tr_look_at   = xzy2xyz(look_at);
tr_bop       = xzy2xyz(bag_of_points);

% Compute the camera matrix and position for the whole sequence.
[C, campos]      = cam_matrix_theta_phi(theta, phi, D, tr_look_at', UP);
[bone_loc, rect] = render_orthographic(tr_bop, C);
%%
figure;
plot3(tr_bop(1,:), tr_bop(2,:), tr_bop(3,:), 'r.');
hold on;
plot3(campos(1), campos(2), campos(3), 'ro', 'MarkerSize', 10);
title('3d model in the new coordinates (Z-up) with camera.');
hold off;
axis equal;

figure;
plot(bone_loc(1, :), bone_loc(2, :), 'b.');
title('2d projection given the viewpoint (Z-up)');
axis equal;