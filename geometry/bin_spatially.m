function bin_ids = bin_spatially(traj_head, rect_dim, x_div, y_div)
% SPATIAL_BINS_FOR_TRAJ Generate bin indices for all physical trajectories.
%
% Input
%   traj_begin: num_traj x 2 (x, y) location of the head of the trajectory.
%   rect : [xmin xmax ymin ymax]
%   xDiv : Integer. Number of divisions along width of rectangle.
%   yDiv : Integer. Number of divisions along height of the rectangle.
%
% Output
%   bin_ids : n x 1 Integer in range {1, 2, 3, ..., xDiv x yDiv}.
%             Indices start from left top corner, go right then bottom.
%             Image coordinate system: origin at the left top corner.
%
% ----
% Ankur

xmin = rect_dim(1);
xmax = rect_dim(2);
ymin = rect_dim(3);
ymax = rect_dim(4);

wid  = xmax - xmin;
hgt  = ymax - ymin;

bin_ids = zeros(size(traj_head, 1), 1);
for i=1:x_div
    for j=1:y_div        
        % find the coordinates of the current bin
        x_lo = xmin + wid/x_div * (i-1);
        x_hi = xmin + wid/x_div * i;
        y_lo = ymin + hgt/y_div * (j-1);
        y_hi = ymin + hgt/y_div * j;
        
        space_constraint_x = (traj_head(:, 1) > x_lo) & (traj_head(:, 1) <= x_hi);
        space_constraint_y = (traj_head(:, 2) > y_lo) & (traj_head(:, 2) <= y_hi);
        bin_ids(space_constraint_x & space_constraint_y) = (j-1)*x_div + i; 
    end
end