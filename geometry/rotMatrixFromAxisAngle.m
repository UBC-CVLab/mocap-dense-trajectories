function R = rotMatrixFromAxisAngle(u, theta)
% ROTMATRIXFROMAXISANGLE Calculate rotation matrix from axis angle
s = sin(theta);
c = cos(theta);
t = 1 - c;

n = u/norm(u);

x = n(1);
y = n(2);
z = n(3);
R = [ ...
     t*x*x + c,    t*x*y - s*z,  t*x*z + s*y; ...
     t*x*y + s*z,  t*y*y + c,    t*y*z - s*x; ...
     t*x*z - s*y,  t*y*z + s*x,  t*z*z + c ...
    ];

end