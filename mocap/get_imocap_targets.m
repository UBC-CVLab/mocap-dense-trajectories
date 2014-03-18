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

% Not all the joints are used for constructing the 3D body model. Used ones
% are highlighted by comments.  
target_joints = {   'Hips', ...           % Body center (root node)    
                    'LHipJoint',  ...      
                    'LeftUpLeg', ...      % left upper leg
                    'LeftLeg', ...        % left lower leg
                    'LeftFoot', ...       % left foot                  
                    'LeftToeBase',...       
                    'RHipJoint', ...       
                    'RightUpLeg', ...     % right upper leg
                    'RightLeg', ...       % right lower leg 
                    'RightFoot',...       % right foot                 
                    'RightToeBase', ...    
                    'LowerBack', ...           
                    'Spine', ...           
                    'Spine1', ...          
                    'Neck', ...           
                    'Neck1', ...          % neck
                    'Head', ...           % head 
                    'LeftShoulder', ...    
                    'LeftArm', ...        % left upper arm   
                    'LeftForeArm', ...    % left lower arm             
                    'LeftHand', ...      
                    'LeftFingerBase', ...  
                    'LeftHandIndex1', ...   
                    'LThumb', ...          
                    'RightShoulder', ...                            
                    'RightArm', ...       % right upper arm
                    'RightForeArm', ...   % right lower arm            
                    'RightHand', ...      
                    'Torso'};             % Added on top. Torso does not exist in the mocap data.
if nargout > 1
    name_ind_map = containers.Map(target_joints, 1 : size(target_joints, 2));
end
                
end

