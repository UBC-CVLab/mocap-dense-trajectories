function display_3D_points(model_surfaces, frame_number, show_norms)
%DISPLAY3DPOINTS Visualize a mocap sequence as a bunch of points in 3d.
%
% Input
%   model_surfaces : See CONSTRUCT_HUMAN_MODELS.
%   frame_number   : Integer. The number of the frame to visualize.
%   show_norms     : Integer. Flag to display normals. [DEFAULT: 0]
% Output
%   None. You will see the visualization.
%
% --
% Ankur, Julieta
if nargin < 3,
    show_norms = 0;
end

hold on;

fid = find([model_surfaces(:).fNum] == frame_number);

if ~isempty(fid),
    hold on;
    % Put all the points into one big array ...
    pts = cell2mat( model_surfaces(fid).pts3D' );
    norms = cell2mat( model_surfaces(fid).norms3D' );
    % ... and plot them.
    if ~isempty(pts)        
        plot3(pts(1,:), pts(2,:), pts(3,:), 'r+');        
        if show_norms,
            quiver3(pts(1,:), pts(2,:), pts(3,:) , norms(1,:), norms(2,:), norms(3,:), 0.5);
        end
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
    end
    
    axis normal
    axis equal;
    hold off;
    
end
end

