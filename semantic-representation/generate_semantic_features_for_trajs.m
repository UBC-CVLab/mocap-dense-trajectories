function [ semantic_features ] = generate_semantic_features_for_trajs( all_trajs, imocap, ...
                                                                theta, phi, D, look_at, UP, viz )
%GENERATE_SEMANTIC_FEATURES_FOR_TRAJS This function generates semantic
% features for the trajectories. The last location of the trajectory is
% used to generate a 19 dimensional features based on the semantic
% structure of the data.
%
% INPUT:
%   all_trajs :     The physical traj cell data.
%   imocap :        The corresponding imocap sequence.
%   theta :         Camera parameter used to generate the trajectories.
%   phi :           Camera parameter used to generate the trajectories.
%   D :             Camera parameter used to generate the trajecotires.
%   look_at :       Camera parameter used to generate the trajectories.
%   UP :            Camera parameter used to generate the trajectories.
%   viz:            Whether we should visualize the process. (default: f)
%
% OUTPUT:
%   semantic_features: A structure comparable to the all_traj that
%   contains the semantic features.
% @Alireza

if nargin < 8
    viz = false;
end

%% Initialize
semantic_config = get_semantic_configuration();
gaus_scale  = semantic_config.gaussian_scale;

% Helper functions
drop_row = @(x) x(1:end-1, :);
project  = @(x, C) drop_row(C*[x; ones(1, size(x, 2))]);
frames   = @(x) size(x.xyz{1}, 2);
at_frame = @(x, t) x(:, t)';
pointcloud = @(x, t) cell2mat(cellfun(@(x) at_frame(x, t), x', 'UniformOutput', false));

membership = @(x, i, scale, anchor) ...
    mvnpdf(x, anchor(i, :), (scale * gaus_scale(i)).^2 .* eye(2, 2)) ...
    ./ mvnpdf(anchor(i, :), anchor(i, :), (scale * gaus_scale(i)).^2 .* eye(2, 2));

% Variables
[C, ~] = cam_matrix_theta_phi(theta, phi, D, look_at', UP);
nframe = frames(imocap);
semantic_features = cell(size(all_trajs));

%% Process
extended_xyz        = get_extended_semantic_joints(imocap, semantic_config);
projected_extended  = cellfun(@(x) project(x, C), extended_xyz, 'UniformOutput', false);

projected_joints = cellfun(@(x) project(x, C), imocap.xyz, 'UniformOutput', false);

if viz,
    figure();
end

for i= 1:nframe,
    
    traj_features = all_trajs{i};
    
    if isempty(traj_features),
        continue;
    end
    
    trajectory_ends = traj_features(:, 1:2);
    
    ext_cloud   = pointcloud(projected_extended, i);
    % Must reverse Y for compatibility;
    ext_cloud(:, 2)     = -ext_cloud(:, 2);

    % The distance between the first and the second joint should be 30 when
    % the scale is 1.
    scale = norm(ext_cloud(1, :) - ext_cloud(2, :), 2)/15;

    if viz,
        point_cloud = pointcloud(projected_joints, i);
        point_cloud(:, 2)   = -point_cloud(:, 2);
        scatter(ext_cloud(:, 1), ext_cloud(:, 2), 'r+');
        scatter(trajectory_ends(:, 1), trajectory_ends(:, 2), 'g.');
        hold on;
        for b= 1:size(semantic_config.bones, 1),
            from_id = semantic_config.bones(b, 1);
            to_id   = semantic_config.bones(b, 2);
            bone    = [point_cloud(from_id, :); point_cloud(to_id, :)];
            line(bone(:, 1), bone(:, 2));
        end
        axis equal;
        for f= 1:size(ext_cloud, 1),
            range = ext_cloud(f, :);
            x1 = range(1)-2:1:range(1)+2;
            x2 = range(2)-2:1:range(2)+2;
            [X1,X2] = meshgrid(x1, x2);
            F = membership([X1(:) X2(:)], f, scale, ext_cloud);
            F = reshape(F,length(x2),length(x1));
            contour(X1, X2, F);
        end
        hold off;
        set(gca,'YDir','reverse');

        drawnow;
        waitforbuttonpress;
        pause(0.01);
    end
    
    traj_count = size(trajectory_ends, 1);    
    sub_feat   = zeros(traj_count, size(ext_cloud, 1));
    
    % First we calculate the uncollapsed feature
    for f= 1:size(ext_cloud, 1),
        sub_feat(:, f) = membership(trajectory_ends, f, scale, ext_cloud);
    end
    
    % Now we collapse the features to account for mirrored joints
    feat       = zeros(traj_count, numel(semantic_config.collapse)+1);
    
    for f= 1:size(feat, 2)-1,
        feat(:, f+1) = max(sub_feat(:, semantic_config.collapse{f}), [], 2);
    end
    
    % Now calculate the background (first dimension) as 1-max(rest)
    feat(:, 1) = 1 - max(feat(:, 2:end), [], 2);
    
    % And the final normalization
    feat_length = sum(feat, 2);
    feat        = bsxfun(@rdivide, feat, feat_length);
    
    semantic_features{i} = feat;
end


end

