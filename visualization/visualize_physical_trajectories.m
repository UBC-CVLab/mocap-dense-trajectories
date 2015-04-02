function visualize_physical_trajectories(all_traj, rectangles, len_traj, last_frame)
% VISUALIZE_PHYSICAL_TRAJECTORIES Visualizes the trajectories returned by  
% GENERATE_TRAJECTORIES_FOR_VIEW.
% 
% Input
%   all_traj   : See the output of GENERATE_TRAJECTORIES_FOR_VIEW.   
%   rectangles : See the output of GENERATE_TRAJECTORIES_FOR_VIEW.
% 
% Output
%   None. You will see the trajectories.
%
% --
% Julieta

% Get the number of frames.
num_frames = size(all_traj, 2);

if nargin < 4,
    last_frame = num_frames - len_traj;
else
    last_frame = min(num_frames - len_traj, last_frame);    
end

% Loop over the frames ...
for i=1:last_frame,

    % Obtain the trajectories that end in this frame.
    in_frame = all_traj{i};
    
    if isempty( in_frame), continue; end;
    
    display_2D_trajectories(in_frame, [], rectangles(i, :));    
    
    axis equal;
    set(gca,'YDir','Reverse'); % Trajs are upside down to be consistent 
                               % with the image coordinate system.
    pause(1/24);
    clf;
    hold off;
end

end