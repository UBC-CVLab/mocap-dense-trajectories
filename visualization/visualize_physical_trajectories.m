function visualize_physical_trajectories(all_traj, rectangles, len_traj)
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

% Loop over the frames ...
for i=1:num_frames - len_traj,

    % Obtain the trajectories that end in this frame.
    in_frame = all_traj{i};
    
    if isempty( in_frame), continue; end;
    
    % Slice the X and Y coordinates.
    X = in_frame(:, 1:2:end-1);
    Y = in_frame(:, 2:2:end  );
    
    % Plot the trajectories.
    hold on;
    for k = 1:size(X,1),
        plot(X(k, :),   Y(k, :),   'LineWidth', 1.5, 'color', 'g');
    end
    
    % Also plot their endpoint, that it is easier to see the person.
    plot(X(:, end), Y(:, end), 'r*');
    
    % Also plot a rectangle around the person.
    % [ xmin, ymax, xmax, ymin ];
    rect = rectangles(i, :);
    xmin = rect(1);
    ymax = rect(2);
    xmax = rect(3);
    ymin = rect(4);
    rectangle( 'Position', [xmin, ymin, abs(xmin - xmax), abs(ymin - ymax)] );
    
    axis equal;
    set(gca,'YDir','Reverse'); % Trajs are upside down to be consistent 
                               % with the image coordinate system.
    pause(1/24);
    clf;
    hold off;
end

end