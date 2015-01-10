function pts = xzy2xyz(pts)
% XZY2XYZ Converts points to mocap coordinate system to image system.
%
% Input
%   pts - 3xNumPoints in xzy coordinates.
%
% --
% Ankur
buff      = pts(2, :);
pts(2, :) = - pts(3, :);
pts(3, :) = buff;
end

