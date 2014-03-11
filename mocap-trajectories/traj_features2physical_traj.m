function ptraj = traj_features2physical_traj(trajFeatures, numPoints)
% TRAJ_FEATURES2PHYSICAL_TRAJ Converts trajectory features to physical.
% Input
%   trajFeatures: n-by-(7 + 2*numPoints) matrix. Each row is a feature
%       trajectory formated in the following order :
%           1:2   : Mean of xy trajectories in normalized feature coordinates.
%           3:4   : Variance of xy trajectories in normalized feature coordinates.
%           5     : Length of the trajectory.
%           6     : Scale at which it was calculated.
%           8:end : XY coordinates in normalized feature coordinates.
%
%   numPoints: Integer. Optional. number of points in the trajectory.
%               Defaults to 15.
%
% Output
%    ptraj : n-by-(numPoints*2) matrix of physical trajectories. Each row
%            is a series of XY points in image coordinates that make up a
%            physical trajectory.
%
% --
% Julieta & Ankur

% Defaults.
DEFAULT_NUM_POINTS = 15;
if nargin <2 
    numPoints = DEFAULT_NUM_POINTS;
end

% If the passed trajectories are empty, return an empty array.
if isempty(trajFeatures),
    ptraj = [];
    return;
end

% Constant.
XY_BEGIN_IDX = 7;

% Indices to slice x and y entries.
xIndices = XY_BEGIN_IDX   : 2 : XY_BEGIN_IDX + 2 * numPoints - 1;
yIndices = XY_BEGIN_IDX+1 : 2 : XY_BEGIN_IDX + 2 * numPoints - 1;
% Get the number of passes trajectories.
numTraj  = size(trajFeatures, 1);
% And create space for the output.
ptraj    = zeros(numTraj, 2*(numPoints+1));

if size(trajFeatures, 2) ~= XY_BEGIN_IDX + 2 * numPoints -1
    error('Check the length of the input trajectories.');
end

trajMean = trajFeatures(:, 1:2);      
xTraj    = trajFeatures(:, xIndices);
yTraj    = trajFeatures(:, yIndices);
trajLen  = trajFeatures(:, 5);

X = zeros( numTraj, numPoints + 1 );
Y = zeros( numTraj, numPoints + 1 );

% Multiply times the length.
for col_i=2:numPoints+1,
    X(:, col_i) = X(:, col_i-1) + xTraj(:, col_i-1) .* trajLen;
    Y(:, col_i) = Y(:, col_i-1) + yTraj(:, col_i-1) .* trajLen;
end

lm = [mean(X, 2), mean(Y, 2)];
Xm = trajMean - lm;

% Add the mean to the trajectories.
Xm1 = Xm(:, 1);
Xm2 = Xm(:, 2);

Xarr = ( Xm1(:, ones(1, numPoints+1)) + X(:, numPoints+1:-1:1) );
Yarr = ( Xm2(:, ones(1, numPoints+1)) + Y(:, numPoints+1:-1:1) );

for pti = 1:(numPoints+1)
    ptraj(:,  2*pti-1 ) = Xarr(:,  pti );
    ptraj(:,  2*pti   ) = Yarr(:,  pti );       
end