function [target_joints, name_ind_map] = get_imocap_targets()
% GET_IMOCAP_TARGETS returns a map of joint names and indices in imocap.
% Input
%   None.
%
% Output
%   target_joints : 29-long cell array. Each entry is a joint name.
%   name_ind_map  : Map {String, Integer} 
%                       key   : Joint name.
%                       value : Index of this joint in the imocap structure.
%
% --
% Alireza. Refactored by Julieta.

target_joints = {   'Hips', ...           % used                       % 1
                    'LHipJoint',  ...     % used
                    'LeftUpLeg', ...      % left upper leg
                    'LeftLeg', ...        % left lower leg
                    'LeftFoot', ...       % left foot                  % 5
                    'LeftToeBase',...     % used 
                    'RHipJoint', ...      % used
                    'RightUpLeg', ...     % right upper leg
                    'RightLeg', ...       % right lower leg 
                    'RightFoot',...       % right foot                 % 10
                    'RightToeBase', ...   % used
                    'LowerBack', ...      % used    
                    'Spine', ...          % used
                    'Spine1', ...         % used
                    'Neck', ...           % used                       % 15
                    'Neck1', ...          % neck
                    'Head', ...           % head 
                    'LeftShoulder', ...   % not used
                    'LeftArm', ...        % left upper arm   
                    'LeftForeArm', ...    % left lower arm             % 20
                    'LeftHand', ...       % left hand
                    'LeftFingerBase', ... % used
                    'LeftHandIndex1', ... % used 
                    'LThumb', ...         % used
                    'RightShoulder', ...  % used                       % 25
                    'RightArm', ...       % right upper arm
                    'RightForeArm', ...   % right lower arm
                    'RightHand', ...      % right hand   
                    'Torso'};             % Added on top. Torso does not exist in the mocap data.
if nargout > 1
    name_ind_map = containers.Map(target_joints, 1 : size(target_joints, 2));
end
                
end

