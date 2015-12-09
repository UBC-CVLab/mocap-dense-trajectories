function [imocap, mocap] = load_imocap_seq( subject_sequence, base_path, target_fps )
% LOAD_IMOCAP_SEQ Loads the mocap sequence and corresponding metadata.
%
%  Input
%   subject_sequence : e.g 01_01 02_01 or full path in case second argument empty.
%   base_path        : String. The folder where the data is. [Optional]
%   target_fps       : Optional Integer. default is 24.
%
%  Output
%    imocap     : Struct with the following fields-
%                     trans: 1xnum_bones cell array of trasformations for
%                             each joint.
%                     bones: Map returned by CONSTRUCT_BONE_SURFACES.
%                     xyz  : 1xnum_bones cell array of 3D locations for
%                             each joint.
%    mocap      : Original mocap struct returned by LOADBVH.
%
% --
% Alireza & Ankur
if nargin < 3,
    target_fps = 24;
end

% Load data from bvh file.
if isempty(base_path)
    % Assume the first argument is the full path.
    [mocap, time]  = loadbvh(subject_sequence);
else
    [mocap, time]  = loadbvh([base_path, subject_sequence]);
end
mocap_fps      = 1/(time(2)-time(1));

[targets, name_ind_map]  = get_imocap_targets();

skip      = round(mocap_fps / target_fps);

imocap    = struct();
trmocap   = cell(1, numel(targets) - 1);

for joint=1:numel(mocap)
    joint_data = mocap(joint);
    ind = get_imocap_joint_index(joint_data.name, name_ind_map);
    if ~isempty(joint_data.trans)
        mocap_transformation = joint_data.trans(1:3, :, 1:skip:end);
        trmocap{1, ind} = single(mocap_transformation);
    end    
end

imocap.trans = trmocap;
imocap.bones = construct_bone_surfaces( mocap );
%imocap.xyz   = trans2xyz(trmocap);  % This may be useful in certain cases.
end


