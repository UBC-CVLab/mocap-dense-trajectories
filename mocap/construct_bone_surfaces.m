function bones = construct_bone_surfaces(mocapData)
% CONSTRUCT_BONE_SURFACES Gets bone parameters (structure info) from mocap,
% computes the initial offsets, generates surfaces for each bone, and
% applies the initial offsets to the bones.
% 
% Input 
%   mocapData     : Struct. Complete mocap data from file (extracted using 
%                       LOADBVH). 
%
% Output
%   bones     : Map {String, struct}
%                   key   : bone name.
%                   value : 3D bones generated using the described 
%                           structured defined below.
%   
%   The struct defined in this code has the following entries.
%
%   name         : Name of the bone
%   len          : Length of the bone.
%   childNodeInd : Indices of the child bones.
%   parentInd    : Index of the parent bone.
%   origInd      : Original index into the mocap data struct.
%   offsetTr     : Initial transformation of bones.
%   
% --
% Ankur & Julieta

all_bones = {mocapData(:).name, 'Torso'};

keys      = cell(1,size(all_bones,2));
values    = cell(1,size(all_bones,2));
ctr       = 1;
T_POS_FR  = 1;  % Initial t-pose frame index.

for b_i=1:size(all_bones,2)
    
    % Define the structure for bones.
    bone = struct('name', [], ... % Name of the bone
        'len',            [],...  % Length of the bone.
        'childNodeInd',   [],...  % Where does it end.
        'parentInd',      [],...  % Where does the bone stem from.
        'origInd',        [],...  % Original index into the mocap data struct.
        'offsetTr',       []);    % Initial transformation of bones.   

    bone.name = all_bones{b_i};
    
    % If the bone name does not exist ...
    if isempty(strtrim(bone.name))
        continue;
    end
    
    % Torso is not a mocap bone per se, so we define its properties here.
    len = 0;
    if strcmp(all_bones{b_i}, 'Torso')
        bone.origInd = -1;
        % The torso is upper-bounded by the arms and lower-bounded by the
        % legs.
        leftArmInd  = find(strcmp({mocapData.name},'LeftArm'), 1);
        rightArmInd = find(strcmp({mocapData.name},'RightArm'), 1);
        leftHipInd  = find(strcmp({mocapData.name},'LeftUpLeg'), 1);
        rightHipInd = find(strcmp({mocapData.name},'RightUpLeg'), 1);
        topMid      = (mocapData(leftArmInd).Dxyz(:, T_POS_FR) + mocapData(rightArmInd).Dxyz(:, T_POS_FR))/2;
        botMid      = (mocapData(leftHipInd).Dxyz(:, T_POS_FR) + mocapData(rightHipInd).Dxyz(:, T_POS_FR))/2;
        len         = norm(topMid-botMid); % Length defined by endpoints.
        offsetTr    = eye(3); % And no initial transformation.
    else
        % Find the original bone index in the mocapData structure.
        st_i = find(strcmp({mocapData.name},all_bones{b_i}),1);   
        % Get all the child nodes.
        child_node = find([mocapData.parent]==st_i);
        % Since there can be multiple children...
        if ~isempty(child_node)
            % ...choose the farthest child node for calculating length.
            for i=1:size(child_node,2)    
                newchildNodeLoc = mocapData(child_node(i)).Dxyz(:, T_POS_FR);
                newlen = norm(mocapData(st_i).Dxyz(:, T_POS_FR) - newchildNodeLoc);                
                if newlen >= len
                    childNodeLoc = newchildNodeLoc;
                    len = newlen;                     
                end
            end
        else
            error('Length not available for the bone');
        end
        
        bone.origInd      = st_i;  
        child_nodes       = {mocapData(child_node).name};
        
        % Get imocap indices for child nodes.
        for i=1:numel(child_nodes)
            cind              = get_imocap_joint_index(child_nodes{i}); 
            if cind~=-1
                bone.childNodeInd = [bone.childNodeInd cind];
            end
        end
        
        % Get imocap index for the parent of the current bone.
        parent_ind        = mocapData(st_i).parent;
        if parent_ind ~=0
            bone.parentInd    = get_imocap_joint_index(mocapData(parent_ind).name);
        else
            bone.parentInd    = parent_ind;
        end
        
        % Get initial transformation for each bone (from a vertically aligned
        % pose at origin to the t-pose model).
        
        % Handling feet as a special case, as foot are not rotationally 
        % symmetric, they need to be aligned so that the flat part is
        % parallel to the ground.
        if strcmp(all_bones{b_i}, 'LeftFoot')
            leftLegInd = find(strcmp({mocapData.name},'LeftLeg'), 1);
            parentLoc  = mocapData(leftLegInd).Dxyz(:,1);
            offsetTr   = getOffsetTransformWithOrthogonalityConstraint(parentLoc, ...
                childNodeLoc, mocapData(st_i).trans(:, :, T_POS_FR));
        elseif strcmp(all_bones{b_i}, 'RightFoot')
            rightLegInd = find(strcmp({mocapData.name},'RightLeg'), 1);
            parentLoc   = mocapData(rightLegInd).Dxyz(:,1);
            offsetTr    = getOffsetTransformWithOrthogonalityConstraint(parentLoc, ...
                childNodeLoc, mocapData(st_i).trans(:, :, T_POS_FR));
        else
            offsetTr = getOffsetTransform(childNodeLoc, len, ...
                mocapData(st_i).trans(:, :, T_POS_FR));
        end
    end
    bone.offsetTr = offsetTr;
    bone.len      = len;
    keys{ctr}     = bone.name;
    values{ctr}   = bone;
    ctr           = ctr + 1;
end
keys = keys(1:ctr-1);
values = values(1:ctr-1);

bones = containers.Map(keys, values);


% Get the transformation to align the bone with the initial t-pose model.
function T = getOffsetTransform(loc_child_node, length, init_trans)
% Input
%   loc_child_node : 1x3 Double. Location of the child node or end of the
%                    bone.
%   length         : Double. Bone length.
%   init_trans     : 4x4 Double. Initial transformation of bone at t-pose.
%
% Output
%   T              : 3x3 Double. Tranformation matrix representing the
%                    offset from bone model at origin to the t-pose.
vec1 = [0 0 length]';
vec2 = transform_pts(loc_child_node, pinv(init_trans));
theta = acos(dot(vec1,vec2)/(norm(vec1)*norm(vec2)));
u = cross(vec1, vec2);
T = vrrotvec2mat([u' theta]);

% Same as the function above. This is a special case for feet.
function T = getOffsetTransformWithOrthogonalityConstraint(parentNodeLoc, ...
    childNodeLoc, init_trans)
% Input
%   parentNodeLoc : 1x3 Double. Location of the parent node for curr bone.
%   childNodeLoc  : 1x3 Double. Location of the child node or end of the
%                    bone.
%   init_trans    : 4x4 Double. Initial transformation of bone at t-pose.
%
% Output
%   T             : 3x3 Double. Tranformation matrix representing the
%                    offset from bone model at origin to the t-pose.
vec_ortho = transform_pts(parentNodeLoc, pinv(init_trans));
vec_axis = transform_pts(childNodeLoc, pinv(init_trans));
ux = cross(vec_axis, vec_ortho);
ux = ux/norm(ux);
uz = vec_axis/norm(vec_axis);
uy = cross(uz, ux);
T = [ux uy uz];