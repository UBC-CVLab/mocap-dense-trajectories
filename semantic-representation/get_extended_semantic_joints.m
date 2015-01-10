function [ extended_xyz ] = get_extended_semantic_joints( imocap, semantic_config )
%GET_EXTENDED_SEMANTIC_JOINTS returns the XYZ location of the extended
%   semantic joint structure.
% @Alireza

if nargin < 2,
    semantic_config = get_semantic_configuration();
end
frames   = @(x) size(x.xyz{1}, 2);

extended_xyz = repmat({zeros(3, frames(imocap))}, 1,...
                      numel(unique(semantic_config.semantic_map(:, 3))));

for r= 1:size(semantic_config.semantic_map, 1),
    from = semantic_config.semantic_map(r, 1);
    prop = semantic_config.semantic_map(r, 2);
    targ = semantic_config.semantic_map(r, 3);
    extended_xyz{targ} = extended_xyz{targ} + imocap.xyz{from} * prop;
end

end

