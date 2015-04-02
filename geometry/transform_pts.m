function trpts = transform_pts( pts, transform )
% TRANSFORM_PTS Apply transformation to homogeneous point representation.
%
% Input
%   pts       : 3-by-n matrix. Each row is the x,y,z points to be transformed.
%   transform : 3-by-3 or 4-by-4 matrix. The transformation to apply to pts.
%
% Output
%   trpts : The transformed points.
%
% NOTE: This code takes care of homogeneous transformations automatically.

% Ankur & Julieta.

% If the data comes in homogeneous coordinates, modify the transform accordingly.
if size(transform, 2) == 4
    trpts      = transform * [pts;ones(1,size(pts, 2))];
    trpts(4,:) = [];
else
    % Else just apply the transformation directly.
    trpts = transform*pts;
end