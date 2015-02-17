function projs2d = project_surface_points(model_surfaces, look_at, C, campos, HPRparam)
% PROJECT_SURFACE_POINTS Takes 3d surfaces and viewpoint parameters, and
% returns the 2d projection of the points after accounting for occlussions.
% 
% Input
%   model_surfaces : see the output of CONSTRUCT_HUMAN_MODELS.
%   look_at        : 3-long vector. Where camera is facing.
%   C              : 
%   campos         : 
%   HPRparam       : Float. It sets the radius in the direct visibility of 
%                    points method by Katz et al. Optional, defaults to 3.
%
% Output
%   projs2d : Array of structures. It has the same number of entries as
%             model_surfaces. Each entry has all the projected points of 
%             the 3d surfaces defined by model_surfaces, and contains the 
%             following fields:
%               fNum  : Integer. The frame number.
%               pts2d : 2-by-n matrix. Each column is the [x y] coordinates
%                       of the projected 2d point.
%              visPts : 1-by-n logical vector. The visibility of the points
%                       in pts2d.
%               theta : Float. Angle that the camera position makes with
%                       the vertical.
%                 phi : Float. Angle that the person's hip makes with the
%                       camera.
%
% --
% Ankur & Julieta

if nargin < 5
    HPRparam = 3;
end

pointDir = look_at - campos;

num_frames = numel(model_surfaces);
fd_struct  = struct( 'fNum', [], 'pts2d', [], 'visPts', [] );
projs2d    = repmat( fd_struct, 1, num_frames );

% Loop over all the frames.
for i=1:num_frames
    
    % Save the frame number.
    projs2d(i).fNum = model_surfaces(i).fNum;
    
    % Create a big matrix of all the points and norms.
    bag_of_points = cell2mat( model_surfaces(i).pts3D' );
    bag_of_norms  = cell2mat( model_surfaces(i).norms3D' );
    
    % Compute the projection of the points.
    [Xp, ~] = render_orthographic(bag_of_points, C);        
    projs2d(i).pts2d = [Xp(1,:); Xp(2,:)];
           
    % Find the visible points...
   
    % ... 1. Backface culling.
    dotproduct  = pointDir * bag_of_norms;
    keep_idx    = dotproduct > 0 ;
    
    bag_of_points = bag_of_points(:, keep_idx);
    
    old_idx = 1:numel(keep_idx);
    new_idx = old_idx( keep_idx );
    
    % ... 2. Occlusion culling.
    if ~isempty(bag_of_points)
        visPts = HPR(bag_of_points', campos, HPRparam);
    end
    
    logicalPts = zeros( 1, numel( keep_idx ));
    logicalPts( new_idx( visPts ) ) = 1;
    
    projs2d(i).visPts = logical(logicalPts);
    
end

end

