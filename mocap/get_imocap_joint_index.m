function [index, name_ind_map] = get_imocap_joint_index(joint_name, name_ind_map)
%GET_IMOCAP_JOINT_INDEX returns the index on imocap for a given joint.
% Input
%   joint_name   : String. A joint name. e.g 'Head', for a full list see 
%                   GET_IMOCAP_TARGETS.
%   name_ind_map : Map {String, Integer} 
%                   key   : Joint name.
%                   value : Index of this joint in the imocap structure.
%                  Optional. Defaults to the second output of 
%                  GET_IMOCAP_TARGETS.
%
% Output
%   Index        : Integer. The found index for the passed joint. -1 if the
%                   joint was not found.
%   name_ind_map : Either the second passed argument or the second output
%                   of GET_IMOCAP_TARGETS.
%
% --
% Alireza, refactored by Julieta.

if nargin<2
    [~, name_ind_map] = get_imocap_targets();
end

if name_ind_map.isKey(joint_name)
    index = name_ind_map(joint_name);
else
    index = -1;
end

end

