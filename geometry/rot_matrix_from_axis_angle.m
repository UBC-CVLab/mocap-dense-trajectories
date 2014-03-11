function R = rot_matrix_from_axis_angle(u, theta)
% ROT_MATRIX_FROM_AXIS_ANGLE Calculate rotation matrix from axis-angle.
%
% Input
%   u     : 1x3 Double. 3D vector representing the axis.
%   theta : Double. Angle in radians to rotate w.r.t. to axis.
%
% Output
%   R     : 3x3 Double. Rotation matrix representation of the rotation.

sn = sin(theta);
cs = cos(theta);
t  = 1 - cs;

n = u/norm(u);

x = n(1);
y = n(2);
z = n(3);
R = [ ...
     t*x*x + cs,    t*x*y - sn*z,  t*x*z + sn*y; ...
     t*x*y + sn*z,  t*y*y + cs,    t*y*z - sn*x; ...
     t*x*z - sn*y,  t*y*z + sn*x,  t*z*z + cs ...
    ];
end