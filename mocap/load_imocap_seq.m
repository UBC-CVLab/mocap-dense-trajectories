function [imocap, mocap] = load_imocap_seq( subject_sequence, target_fps, base_path)
% LOAD_IMOCAP_SEQ Loads the mocap sequence and corresponding metadata.
% 
%  Input
%   subject_sequence : e.g 01_01 02_01
%   base_path        : String. The folder where the data is.
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
[mocap, ~]  = loadbvh([base_path, subject_sequence]);

[targets, name_ind_map]  = get_imocap_targets();
mocap_fps = 120;
skip      = mocap_fps / target_fps;

imocap    = struct();
trmocap   = cell(1, numel(targets) - 1);

for joint=1:numel(mocap)
    joint_data = mocap(joint);
    ind = get_imocap_joint_index(joint_data.name, name_ind_map);
    if ind ~= -1,
        mocap_transformation = joint_data.trans(1:3, :, 1:skip:end);
        trmocap{1, ind} = squeeze( num2cell( mocap_transformation, [1, 2]) );        
    end
end

imocap.trans = trmocap;
imocap.bones = construct_bone_surfaces( mocap );

end

