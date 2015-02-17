function [pts2d, rect] = render_orthographic(pts, C)
% RENDER_ORTHOGRAPHIC Renders the 3d points under orthographic projection.
%
% Input
%    pts : (3xn) 3D points
%    C   : camera matrix 3x4
%
% Output
%    pts2d : (2xn) 2D points
%    rect  : bounding box for 2D points (xmin, ymin, xmax, ymax)
%
pts2d       = C*[pts; ones(1,size(pts,2))];
pts2d(2, :) = -pts2d(2, :); % Reverse Y.
% Ignoring the z: orthographic
pts2d(3,:)= [];
rect = [min(pts2d(1,:)) min(pts2d(2,:)) max(pts2d(1,:)) max(pts2d(2,:))];
end