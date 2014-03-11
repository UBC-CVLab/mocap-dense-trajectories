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
%   TODO comment.
% --
% Ankur & Julieta

all_bones = {mocapData(:).name, 'Torso'};

keys      = cell(1,size(all_bones,2));
values    = cell(1,size(all_bones,2));
ctr       = 1;

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
        topMid      = (mocapData(leftArmInd).Dxyz(:,1)+mocapData(rightArmInd).Dxyz(:,1))/2;
        botMid      = (mocapData(leftHipInd).Dxyz(:,1)+mocapData(rightHipInd).Dxyz(:,1))/2;
        len         = norm(topMid-botMid); % Length defined by endpoints.
        offsetTr    = eye(3); % And no initial transformation.
    else
        st_i = find(strcmp({mocapData.name},all_bones{b_i}),1);        
        child_node = find([mocapData.parent]==st_i);      
        if ~isempty(child_node)
            % Choose the farthest child node for calculating length
            for i=1:size(child_node,2)    
                newchildNodeLoc = mocapData(child_node(i)).Dxyz(:,1);
                newlen = norm(mocapData(st_i).Dxyz(:,1)-newchildNodeLoc);                
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
        for i=1:numel(child_nodes)
            cind              = get_imocap_joint_index(child_nodes{i}); 
            if cind~=-1
                bone.childNodeInd = [bone.childNodeInd cind];
            end
        end
            
        parent_ind        = mocapData(st_i).parent;
        if parent_ind ~=0
            bone.parentInd    = get_imocap_joint_index(mocapData(parent_ind).name);
        else
            bone.parentInd    = parent_ind;
        end
        % handling feet as a special case
        if strcmp(all_bones{b_i}, 'LeftFoot')
            leftLegInd = find(strcmp({mocapData.name},'LeftLeg'), 1);
            parentLoc = mocapData(leftLegInd).Dxyz(:,1);
            offsetTr = getOffsetTransformWithOrthogonalityConstraint(parentLoc, ...
                childNodeLoc, mocapData(st_i).trans(:,:,1));
        elseif strcmp(all_bones{b_i}, 'RightFoot')
            rightLegInd = find(strcmp({mocapData.name},'RightLeg'), 1);
            parentLoc = mocapData(rightLegInd).Dxyz(:,1);
            offsetTr = getOffsetTransformWithOrthogonalityConstraint(parentLoc, ...
                childNodeLoc, mocapData(st_i).trans(:,:,1));
        else
            offsetTr = getOffsetTransform(childNodeLoc, len, ...
                mocapData(st_i).trans(:,:,1));
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

function T = getOffsetTransform(childNode, length, currNodeTrans)
vec1 = [0 0 length]';
vec2 = transform_pts(childNode, pinv(currNodeTrans));
theta = acos(dot(vec1,vec2)/(norm(vec1)*norm(vec2)));
u = cross(vec1, vec2);
T = vrrotvec2mat([u' theta]);


function T = getOffsetTransformWithOrthogonalityConstraint(parentNodeLoc, ...
    childNodeLoc, currNodeTrans)
vec_ortho = transform_pts(parentNodeLoc, pinv(currNodeTrans));
vec_axis = transform_pts(childNodeLoc, pinv(currNodeTrans));
ux = cross(vec_axis, vec_ortho);
ux = ux/norm(ux);
uz = vec_axis/norm(vec_axis);
uy = cross(uz, ux);
T = [ux uy uz];




