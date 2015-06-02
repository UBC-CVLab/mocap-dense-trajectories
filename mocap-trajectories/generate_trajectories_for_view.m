function [all_traj, thetas, phis, rectangles, all_traj_ids] = generate_trajectories_for_view( ... 
    model_surfaces, imocap, camTheta, camPhi, d, look_at, up, HPRparam, ...
    lenTraj, personSize, id_data)
% GENERATE_TRAJECTORIES_FOR_VIEW Generates trajectories using a virtual
%   camera.
% 
% Input
%   model_surfaces : see the output of PUT_SURFACES_IN_PLACE.
%   imocap         : see the output of LOAD_IMOCAP_SEQ.
%   camTheta       : Float. Angle that the camera position makes with the 
%                       vertical in the range [0 pi).
%   camPhi         : Float. Angle that the projection of camera position on
%                       the horizontal plane makes with the x-axis in the 
%                       range[0 2pi).
%   d              : Float. Distance from the lookat.
%   lookAt         : 3-long vector. Where camera is facing.
%   up             : 3-long vector. It defines the camera's up direction.
%   HPRparam       : Float. It sets the radius in the direct visibility of 
%                       points method by Katz et al. Optional, default is 3
%   lenTraj        : Integer. The number of frames that a trajectory takes
%   personSize     : Integer. Estimated person size in pixels. This is used
%                       to remove small trajectories.
%
% Output
%   all_traj   : n-long cell array, where n is the number of entries in
%                model_surfaces. Each entry is an n-by-2*(lenTraj+1) 
%                matrix, and each row is a set of x-y coordinates that 
%                correspond to a trajectory in 2d that ends in such frame.
%   thetas     : n-long-vector. The thetas of the camera wrt the vertical,
%                for each frame.
%   phis       : n-long-vector. The phis of the camera wrt the vertical, for
%                each frame.
%   rectangles : n-by-4 matrix. Each row is [xmin, xmax, ymin, ymax]; i.e.
%                the rectangle surrouding the person in each frame.
%
% ---
% Ankur & Julieta
if nargin <11
    id_data = [];
end

%% Compute the camera matrix and position for the entire sequence.
[C, campos] = cam_matrix_theta_phi(camTheta, camPhi, d, look_at', up);

%% Compute the azimuthal (phis) and polar (thetas) angles for each frame.
% Theta is constant for the entire sequence.
thetas = repmat( camTheta, [numel(model_surfaces), 1] );
% Phis do have to be computed per frame.
phis   = compute_phis( imocap, campos);

%% Project the 3d points.
projs2d         = project_surface_points(model_surfaces, look_at', C, campos, HPRparam);
max_frame_index = numel(model_surfaces);
if ~isempty(id_data)
    flattened_ids   = cell2mat( id_data.pt_ids' );
end
%% Compute the person's height in 3d-world coordinates.
first_frame_points = projs2d(1).pts2d;
person_height      = max(first_frame_points(2, :)) - min(first_frame_points(2, :));

%% Create the output structure.
all_traj           = cell(1, max_frame_index - (lenTraj+2) + 1);
rectangles         = zeros(max_frame_index - (lenTraj+2) + 1, 4);
all_traj_ids       = cell(1, max_frame_index - (lenTraj+2) + 1);

% Loop through all the frames that we want.
for frm_i = lenTraj+2:max_frame_index       

    % If the frame number is smaller than the trajectory lenght, we cannot
    % generate trajectories yet.
    if frm_i < lenTraj,
        all_traj{frm_i} = [];
        return;
    end
    
    % Find the trajectories of the frame number.
    fid = find([projs2d(:).fNum]==frm_i);
    if isempty(fid),
        error('Frame number does not exist.');
    end
    
    % Get the rect for this frame.
    maxes = max( projs2d( fid ).pts2d, [], 2 );
    minis = min( projs2d( fid ).pts2d, [], 2 );
    %       [ xmin, ymin, W, H];
    rectangles(frm_i, :) = [minis(1), minis(2), maxes(1) - minis(1), maxes(2) - minis(2)];

    % Stack all the entries of 2d_points and visible points in a lenTraj
    % time window.
    bag_of_visible = cell2mat( {projs2d(fid: -1: fid-lenTraj).visPts}');
    points_2d      = cell2mat( {projs2d(fid: -1: fid-lenTraj).pts2d}');
    
    % Keep only the points that are visible for lenTraj frames.
    traj_inds   = all( bag_of_visible, 1 );
    traj        = points_2d( :, traj_inds)';
   
    % Now filter based on standard dev. This is taken verbatim from the
    % code of dense trajectories by Wang et al.
    minStd = sqrt(3)*person_height/personSize;
    
    % Get the std for each trajectory.
    stdXY = [std(traj(:, 1:2:end),0,2) std(traj(:, 2:2:end),0,2)];
    valid_size_inds = stdXY(:, 1) > minStd | stdXY(:, 2) > minStd;
    
    traj = traj(valid_size_inds, :);    
    
    % Put the trajectories in the return structure.
    all_traj{frm_i} = traj;
    if ~isempty(id_data)
        traj_id     = flattened_ids(traj_inds);
        all_traj_ids{frm_i} = traj_id(valid_size_inds);
    end
end

end