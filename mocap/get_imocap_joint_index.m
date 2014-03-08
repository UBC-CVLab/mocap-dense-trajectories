function [index, name_ind_map] = get_imocap_joint_index(joint_name, name_ind_map)
%GET_MOCAP_JOINT_INDEX return joint index on imocap
% joint_name:   e.g 'Head', for a full list check get_imocap_targets
% Alireza
if nargin<2
    [~, name_ind_map] = get_imocap_targets();
end
if name_ind_map.isKey(joint_name)
    index = name_ind_map(joint_name);
else
    index = -1;
end

end

