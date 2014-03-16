function [TRI, X, Y, Z ] = triangulated_cylinder( R, N )
% Creates a cylinder and its surface triangulation. E.g.
% [tri, x, y, z] = triangulated_cylinder(1:20, 10);
% trisurf(tri, x, y, z);
% 
% Input
%   R and N. Homologous to the input of MATLAB's native CYLINDER function.
%
% Output
%   TRI     : mtri-by-3 matrix of triangles that define the cylinder's
%             surface.
%   X, Y, Z : See cylinder.
%
% --
% Julieta

if nargin < 2,
    N = 20; 
end

if nargin < 1,
    R = [1, 1];
end

% Create the cylinder from matlab.
[X, Y, Z] = cylinder(R, N);

% Get the number of layers.
layers = numel(R);

% Do the triangulation for a pair of rings.
tri_template             = zeros(N * 2, 3);
tri_template(1:N, 1)     = 1:N;
tri_template(N+1:N*2, 1) = 1:N;
tri_template(1:N, 2)     = (1:N) + N + 1;
tri_template(N+1:N*2, 2) = (1:N) + N + 2;
tri_template(1:N, 3)     = (1:N) + N + 2;
tri_template(N+1:N*2, 3) = (1:N) + 1;

% Repeat for the number of rings passed.
TRI = cell(layers + 1, 1);
for i=1:layers-1;    
    TRI{i} = tri_template + ((N + 1) * (i-1) );
end

% Add the taps. Delaunay is more beautiful (and perhaps more stable) than
% having all of them share an origin (like a fan).
TRI{end-1} = delaunay(X(1,1:end-1), Y(1,1:end-1));
TRI{end}   = TRI{end-1} + (layers-1)*( N+1 );

TRI = cell2mat(TRI);

% Transpose the matrices, to match the triangulation.
X = X';
Y = Y';
Z = Z';

end

