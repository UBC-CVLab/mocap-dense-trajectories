function ptraj = traj_features2physical_traj(trajFeatures, numPoints)
%TRAJ_FEATURES2PHYSICAL_TRAJ Converts trajectory feature to physical traj
% Input
%    trajFeatures: n-by-(6 + 2*numPoints) matrix. Each row is a feature
%       trajectory formated in the following order.
%       1:2 - mean of xy trajectories in normalized feature coordinates,
%       3:4 - variance of xy trajectories in normalized feature
%             coordinates.
%       5   - length of traj.
%       6   - scale at which it was calculated.
%       7:7+2*numPoints-1 - xy coordinates in normalized feature
%             coordinates
%
%    numPoints: Integer. Optional. number of points in the trajectory.
%               Defaults to 15.
%
% Output
%    ptraj - Physical trajectories. I.e. a series of XY in image coordinates
%
% --
% Ankur


%% TODO Vectorize!

%% Defaults.
DEFAULT_NUM_POINTS = 15;
if nargin <2 
    numPoints = DEFAULT_NUM_POINTS;
end

if isempty(trajFeatures),
    ptraj = [];
    return;
end

%% Constants.
XY_BEGIN_IDX = 7;

xIndices = XY_BEGIN_IDX :  2 : XY_BEGIN_IDX + 2 * numPoints - 1;
yIndices = XY_BEGIN_IDX+1 : 2 : XY_BEGIN_IDX + 2 * numPoints - 1;
numTraj = size(trajFeatures, 1);
ptraj = zeros(numTraj, 2*(numPoints+1));
    
if size(trajFeatures, 2) ~= XY_BEGIN_IDX + 2 * numPoints -1
    error('Please check the length of the input: trajFeature');
end
trajMean =  trajFeatures(:, 1:2);      
xTraj = trajFeatures(:, xIndices);
yTraj = trajFeatures(:, yIndices);
trajLen = trajFeatures(:, 5);

for i = 1:numTraj
    orderedArr = zeros(1, 2*(numPoints+1));
    xym  = trajMean(i, :);             % Trajectory mean in image coordiates.
    % Vm      = trajFeature(3:4);      % Trajectory variance.
    lent    = trajLen(i);              % Absolute length of trajectory in image space.
    % scale   = trajFeature(6);        % Scale (?) of the spatial pyramid, I guess.
    px = xTraj(i, :);
    py = yTraj(i, :);
    
    X = zeros(numPoints+1, 1);
    Y = zeros(numPoints+1, 1);
    
    % Multiply with length.
    for col_i=2:numPoints+1
        X(col_i) = X(col_i-1) + px(col_i-1) * lent; %
        Y(col_i) = Y(col_i-1) + py(col_i-1) * lent; %
    end
    % Add the differences to get real trajectory.
    lm = [mean(X), mean(Y)];
    Xm = xym - lm;
    Xarr = (Xm(1)+X(numPoints+1:-1:1));
    Yarr = (Xm(2)+Y(numPoints+1:-1:1));    
    for pti = 1:(numPoints+1)
        orderedArr(2*pti-1) = Xarr(pti);
        orderedArr(2*pti) = Yarr(pti);       
    end
    ptraj(i, :) = orderedArr;        
end
