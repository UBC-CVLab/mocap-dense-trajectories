function [traj_feats, relative_thetas, relative_phis, rectangles] = ...
    imocap2trajectories( imocap, theta, phi, point_density, d, look_at, up, ...
    HPRparam, lenTraj, person_size)
%IMOCAP2TRAJECTORIES Computes dense trajectories for a given mocaps 
%sequence.
% Input
%   imocap         : see the output of LOAD_IMOCAP_SEQ.
%   camTheta       : Float. Angle that the camera position makes with the 
%                       vertical in the range [0 pi).
%   camPhi         : Float. Angle that the projection of camera position on
%                       the horizontal plane makes with the x-axis in the 
%                       range[0 2pi).
%   point_density  : Float. Number of points per area unit in the person's
%                       model.
%   d              : Float. Distance from the lookat.
%   look_at         : 3-long vector. Where camera is facing.
%   up             : 3-long vector. It defines the camera's up direction.
%   HPRparam       : Float. It sets the radius in the direct visibility of 
%                       points method by Katz et al.
%   lenTraj        : Integer. The number of frames that a trajectory takes
%   personSize     : Integer. Estimated person size in pixels. This is used
%                       to remove small trajectories.
%
%  Output
%   traj_feats      : n-by-37 matrix. n is the number of trajectories 
%                       generated. The output is equivalent to the dense
%                       trajectories of Wang et al.
%   relative_thetas : m-long vector. m is the number of frames. The angle 
%                       of the vertical with the camera, per frame.
%   relative_phis   : m-long vector. m is the number of frames. The angle 
%                       of the person's hip heading direction with the 
%                       camera, per frame.
%   rectangles      : m-by-4 matrix. m is the number of frames. Each row is
%                       a rectangle around the person define as 
%                       [xmin, xmax, ymin, ymax]. Useful if you want to
%                       encode the trajectories enforcing geometrical 
%                       consistency (i.e. a spatial pyramid).
%
% --     
% Julieta

%% Create the bone surfaces.
bone_properties  = define_limb_prop(); % Parameters describing limb volumes.
imocap = create_human_surfaces( imocap, bone_properties, point_density );

%% Move the cylinders to their corresponding positions in the 3d world.
model_surfaces = put_surfaces_in_place(imocap );

%% Obtain trajectories for this viewpoint.
[ptraj, relative_thetas, relative_phis, rectangles] = ...
    generate_trajectories_for_view(model_surfaces, imocap, theta, phi, d, look_at, up, HPRparam, lenTraj, person_size);

traj_ends = cell(1, numel( ptraj ));
traj      = cell(1, numel( ptraj ));
%% Convert the trajectories to features.
for k=1:numel( ptraj ),
    [traj{k}, traj_ends{k}] = physical_traj2traj_features( ptraj{k}, model_surfaces(k).fNum, lenTraj );
end

%% Convert the trajectories and ends to matrices.
traj_feats = cell2mat( traj' );
if ~isempty(traj_feats),
    frame_inds = unique( traj_feats(:, 1) );
    % Remove all the zero rows.
    rectangles = rectangles( frame_inds, : );
else
    rectangles = [];
end

