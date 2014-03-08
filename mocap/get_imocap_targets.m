function [target_joints, name_ind_map] = get_imocap_targets()
% get_cmu_targets returns the target_joints data
% Alireza

target_joints = {   'Hips', ...      % used
                    'LHipJoint',  ...     % used
                    'LeftUpLeg', ...      % left upper leg
                    'LeftLeg', ...        % left lower leg
                    'LeftFoot', ...       % left foot
                    'LeftToeBase',...     % used 
                    'RHipJoint', ...      % used
                    'RightUpLeg', ...     % right upper leg
                    'RightLeg', ...       % right lower leg 
                    'RightFoot',...       % right foot
                    'RightToeBase', ...   % used
                    'LowerBack', ...      % used    
                    'Spine', ...          % used
                    'Spine1', ...         % used
                    'Neck', ...           % used
                    'Neck1', ...          % neck
                    'Head', ...           % head 
                    'LeftShoulder', ...   % no used
                    'LeftArm', ...        % left upper arm   
                    'LeftForeArm', ...    % left lower arm
                    'LeftHand', ...       % left hand
                    'LeftFingerBase', ... % used
                    'LeftHandIndex1', ... % used 
                    'LThumb', ...         % used
                    'RightShoulder', ...  % used 
                    'RightArm', ...       % right upper arm
                    'RightForeArm', ...   % right lower arm
                    'RightHand', ...      % right hand   
                    'Torso'};             % Added on top. Torso does not exist in the mocap data.
if nargout > 1 
    name_ind_map = containers.Map(target_joints, 1 : size(target_joints, 2));
end
                
end

