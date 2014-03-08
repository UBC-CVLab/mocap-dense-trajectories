function display_3D_points(model_surfaces, frame_number)
%DISPLAY3DPOINTS Visualize a mocap sequence as a bunch of points in 3d.
%
% Input
%   model_surfaces : See CONSTRUCT_HUMAN_MODELS.
%   frame_number   : Integer. The number of the frame to visualize.
%
% Output
%   None. You will see the visualization.
%
% --
% Ankur, Julieta

hold on;

fid = find([model_surfaces(:).fNum] == frame_number);

if ~isempty(fid),
    % Put all the points into one big array ...
    pts = cell2mat( model_surfaces(fid).pts3D' );
    
    % ... and plot them.
    if ~isempty(pts)
        plot3(pts(1,:), pts(2,:), pts(3,:), 'r+');
        xlabel('X');
        ylabel('Y');
        zlabel('Z');
    end
    
    axis normal
    axis equal;
    hold off;
    
end
end

