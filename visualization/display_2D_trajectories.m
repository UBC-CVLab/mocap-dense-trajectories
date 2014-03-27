function h = display_2D_trajectories(XY, FI, bd_box, frac_to_display)
% DISPLAY_2D_TRAJECTORIES Displays rendered trajectories for a frame.
% Input:
%  XY              - N x 16 Double. Physical trajectories visible in the frame.
%  FI              - N x 1 Integer. First index of the trajectory that is visible in this frame.
%                     For example, for trajectories ending in this frame the
%                     value would be 1, for trajectories ending in the next
%                     frame the value woule be 2 and so on.
%  bd_box          - Person bounding box.  [xmin xmamx ymin ymax] (optional)
%  frac_to_display - Fraction of trajectories to display (0-1] (optiona)
%   
% Output:
%   h              - Figure handle to the current figure
% --
% Ankur

DEFAULT_COLOR = 'g-';
if nargin < 4
    frac_to_display = 1;    
end
if nargin < 3
    bd_box = [];
end
if nargin < 2 || isempty(FI)
    FI = ones(1, size(XY, 1));
end

numTraj = size(XY,1);
r = randperm(numTraj);
randInds = r(1:floor(frac_to_display*numTraj));
hold on;
for i=randInds
    % Plot the head of the trajectory.
    plot(XY(i,2*FI(i)-1), XY(i,2*FI(i)), 'r*', 'MarkerSize',6,'LineWidth',1.5);
    X = XY(i,2*FI(i)-1:2:end);
    Y = XY(i,2*FI(i):2:end);
    plot(X, Y, DEFAULT_COLOR, 'LineWidth',1.5);
    % line_with_gradient(X,Y, [0 1 0], 2);
end

if ~isempty(bd_box)
    xmin   = bd_box(1);
    ymin   = bd_box(3);
    w      = bd_box(2) - bd_box(1);
    h      = bd_box(4) - bd_box(3);
    bd_box = [xmin ymin w h];
    r = rectangle('Position', bd_box); % [x y w h]
    set(r, 'EdgeColor', 'c');
end

h = gcf;
axis equal;
hold off;