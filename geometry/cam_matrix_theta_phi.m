function [cameraMatrix, cameraPosition] = cam_matrix_theta_phi(theta, phi, d, lookat, up)
% Generates 3x4 camera mat given camera location in (d, theta, phi) coords.
%
% Works under orthographic projection. There is no focal length.
%
% Input:
%    theta  : Angle camera pos vector makes with the vertical [0 pi)
%    phi    : Angle camera pos vector's projection on the horizontal plane
%              makes with the z-axis (in xzy) and with -y-axis (in xyz system) [0 2pi)
%    d      : Distance from the lookat [default 1]
%    lookAt : Optional parameter describing where camera is facing [default origin]
%    up     : 1 - z-up , 0 - y-up
%
% Output:
%    cameraMatrix   : Camera matrix (3x4)
%    cameraPosition : Camera location (1x3)
%
% IMP ASSUMPTIONS:
% 1) Y- is vertical (default), however you can set the variable 'up'
% 2) There is no camera roll.
%
% --
% Ankur, refactored by Julieta.

%% Set default parameter values.
DEFAULT_LOOK_AT = [0 0 0];
DEFAULT_D       = 1;
DEFAULT_UP      = 0; %[0 1 0];  assuming y is vertical.

if nargin<5
    up = DEFAULT_UP;
    if nargin < 4;
        lookat = DEFAULT_LOOK_AT;
        if nargin < 3,
            d = DEFAULT_D;
        end
    end
end
% z_up = norm(cross_product(up, [0 0 1]))==0;
% y_up = norm(cross_product(up, [0 1 0]))==0;
if up, % for z-up
    cameraPosition = single([lookat(1) + d*sin(theta)*sin(phi), ...
        lookat(2)  - d*sin(theta)*cos(phi), ...
        lookat(3)  + d*cos(theta)]);
    up_vec     = single([0 0 1]);
else  % for y-up
    cameraPosition = single([lookat(1) + d*sin(theta)*sin(phi), ...
        lookat(2) + d*cos(theta), ...
        lookat(3) + d*sin(theta)*cos(phi)]);
    up_vec     = single([0 1 0]);
end

% Now we calculate the new z-vector. This vector has the same direction
% as the camera look direction, but it must be normalized to get the length = 1.
forward = lookat - cameraPosition;
forward = forward/norm(forward);
% The third vector can be calculated by the cross-product of up and
% forward. It'll result in a vector pointing to the right of our screen,
% or - speaking in our new coordinate system - to the positive x-axis.
% Normalize this vector, since it's not guaranteed that up and forward
% are collinear
right = cross_product(forward, up_vec);
% normalize_vector (right);
right = right/norm(right);
% We're almost finished now... But there is still one thing: It's not
% guaranteed that the up-vector and the direction-vector are colinear.
% (think about a camera that'll look at the sky). To avoid distortion we
% have to recalculate the up vector again:
up_vec = cross_product(right, forward);
up_vec = up_vec/norm(up_vec);

% Set up the rotation matrix.
R = [right(1),     right(2),     right(3);
    up_vec(1),        up_vec(2),       up_vec(3);
    -forward(1), - forward(2), - forward(3)];

%
T = [eye(3, 'single'), -cameraPosition'; 0 0 0 1];

cameraMatrix = T*[R [0 0 0]'; 0 0 0 1];
cameraMatrix = cameraMatrix(1:3, :);

