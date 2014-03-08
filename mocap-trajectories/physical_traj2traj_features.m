function [ftraj, traj_end] = physical_traj2traj_features(ptraj, frameNo, len_traj)
% PTRAJ2TRAJ_FEATURES Vectorized conversion of physical trajectory points
% to traj features (as defined by Wang et al.[1]).
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
% ---
% Julieta & Ankur

if isempty(ptraj),
    traj_end = [];
    ftraj    = [];
    return
end
NUM_METADATA_ROWS = 7;
[ntraj, ~] = size( ptraj );

ftraj    = zeros(ntraj, NUM_METADATA_ROWS + 2*len_traj);
traj_end = ptraj(:, end-1:end); % Save the 2D location where traj terminates.

diff  = ptraj(:, 1:end-2) - ptraj(:, 3:end);

lenT = sum( sqrt(diff(:, 1:2:end).^2+diff(:, 2:2:end).^2), 2 );
xy = diff./repmat( lenT, [1, size(diff, 2)] );

ftraj(:, 1)   = repmat(frameNo, [ntraj, 1]);
ftraj(:, 2:3) = [mean(ptraj(:, 1:2:end), 2) mean(ptraj(:, 2:2:end), 2)];
ftraj(:, 4:5) = [std(ptraj(:, 1:2:end), 0, 2) std(ptraj(:, 2:2:end), 0, 2)];
ftraj(:, 6) = lenT;
ftraj(:, 7) = -1; %% we lose this information
ftraj(:, 8:2:end) = xy(:, end-1:-2:1);
ftraj(:, 9:2:end) = xy(:, end:-2:1);
end