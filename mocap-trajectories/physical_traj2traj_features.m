function [ftraj, traj_end] = physical_traj2traj_features(ptraj, frameNo, len_traj)
% PHYSICAL_TRAJ2TRAJ_FEATURES Vectorized conversion of physical trajectory
% points to traj features (as defined by Wang et al.[1]).
%
% Input
%   ptraj    : ntraj x len_traj*2 Double. 2D point locations of the
%              trajectories.
%   frameNo  : Integer. Frame where the trajectory ends.
%   len_traj : Integer. Length of each trajectory. 
%
% Output
%   ftraj    : ntraj x NUM_METADATA_ROWS + 2*len_traj Double. Traj feature
%              vectors.
%   traj_end : ntraj x 2. X-Y locations where each trajectory ends.
%
% [1] Wang, H., & Klaser, A. (2011). Action recognition by dense
% trajectories. CVPR'11.
%
% ---
% Julieta & Ankur

% If the passed trajectories are empty, return empty arrays.
if isempty(ptraj),
    traj_end = [];
    ftraj    = [];
    return
end

% We have 7 entries for metadata.
NUM_METADATA_ROWS = 7;

% Get the number of passed trajectories.
[ntraj, ~] = size( ptraj );

% Create space for the output.
ftraj    = zeros(ntraj, NUM_METADATA_ROWS + 2*len_traj);

% Save the 2D location where traj terminates (maybe useful for geometry).
traj_end = ptraj(:, [1 2]); 

% Get necessary info for trajectory features.
diff     = ptraj(:, 1:end-2) - ptraj(:, 3:end);

lenT     = sum( sqrt(diff(:, 1:2:end).^2+diff(:, 2:2:end).^2), 2 );
xy       = diff ./ repmat( lenT, [1, size(diff, 2)] );


% Add metadata.
% frameNum:     The trajectory ends on this frame
ftraj(:, 1)       = repmat(frameNo, [ntraj, 1]);
% mean_x:       The mean value of the x coordinates of the trajectory
% mean_y:       The mean value of the y coordinates of the trajectory
ftraj(:, 2:3)     = [mean(ptraj(:, 1:2:end), 2) mean(ptraj(:, 2:2:end), 2)];
% var_x:        The variance of the x coordinates of the trajectory
% var_y:        The variance of the y coordinates of the trajectory
ftraj(:, 4:5)     = [std(ptraj(:, 1:2:end), 0, 2) std(ptraj(:, 2:2:end), 0, 2)];
% length:       The length of the trajectory
ftraj(:, 6)       = lenT;
% scale:        This information is lost due to ortographic projection. Set to -1.
ftraj(:, 7)       = -1;

% Actually add the trajectory data.
ftraj(:, 8:2:end) = xy(:, end-1:-2:1);
ftraj(:, 9:2:end) = xy(:, end:-2:1);

end