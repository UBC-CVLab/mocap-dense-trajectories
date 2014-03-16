function prop = define_limb_prop()
% DEFINE_LIMB_PROP Specify properties of tapered cylinders representing limbs.
%
% Input: None
%
% Output: 
%    prop: a map of key value pairs.
%       key   - String. name of the joint used to drive the limb.
%       value - Struct with following fields.  
%             basedia    : base diameter (thicker part of the tapered cyl.).
%             topdia     : top diameter  (thiner part of the tapered cyl.).
%             minmajratio: ratio of min/max radius for both ends of the cyl.  
%                          Not all cylinders have circuler ends (e.g., torso).
%
% NOTE
%   a) This function assumes that each human limb is represented by a 
%       tapered cylinder.
%   b) This description of joints names is tied with the mocap files 
%       released in BVH format (Motion Builder friendly) here
%       https://sites.google.com/a/cgspeed.com/cgspeed/motion-capture/cmu-bvh-conversion
%   c) Since the model is too detailed. We do not use all the joints. See
%       the commets below for a list of unused ones. We have left them 
%       there for future use if wish to make our model more sophisticated.
%   d) There is no single joint to drive the torso. So we had to create a 
%      seperate entry for it in the prop map. However, there is no joint 
%      with that name in the mocap data.
%
% --
% Ankur

keys = { 'Hips', ...      % not used
    'LHipJoint',  ...     % not used
    'LeftUpLeg', ...      % left upper leg
    'LeftLeg', ...        % left lower leg
    'LeftFoot', ...       % left foot
    'LeftToeBase',...     % not used 
    'RHipJoint', ...      % not used
    'RightUpLeg', ...     % right upper leg
    'RightLeg', ...       % right lower leg 
    'RightFoot',...       % right foot
    'RightToeBase', ...   % not used
    'LowerBack', ...      % not used    
    'Spine', ...          % not used
    'Spine1', ...         % not used
    'Neck', ...           % not used
    'Neck1', ...          % neck
    'Head', ...           % head 
    'LeftShoulder', ...   % no used
    'LeftArm', ...        % left upper arm   
    'LeftForeArm', ...    % left lower arm
    'LeftHand', ...       % left hand
    'LeftFingerBase', ... % not used
    'LeftHandIndex1', ... % not used 
    'LThumb', ...         % not used
    'RightShoulder', ...  % not used 
    'RightArm', ...       % right upper arm
    'RightForeArm', ...   % right lower arm
    'RightHand', ...      % right hand
    'RightFingerBase', ...% not used
    'RightHandIndex1', ...% not used 
    'RThumb', ...         % not used
    'Torso'}; %% torso, added separately 

% Up leg
upleg.basedia = 1/5.0;
upleg.topdia = 1/6.0;
upleg.minmajratio = 1;

% Bot leg
botleg.basedia = 1/7.5;
botleg.topdia = 1/8.5;
botleg.minmajratio = 1;

% foot
foot.basedia = 1/2;
foot.topdia = 1/2;
foot.minmajratio = 1/4;

% upper arm
uparm.basedia = 1/6.5;
uparm.topdia = 1/7;
uparm.minmajratio = 1;

% lower arm
lowarm.basedia = 1/4.5;
lowarm.topdia = 1/5.5;
lowarm.minmajratio = 1;

% neck1
neck1.basedia = 1/2;
neck1.topdia = 1/2;
neck1.minmajratio = 1;

% head
head.basedia = 1/1.5;
head.topdia = 1/1.5;
head.minmajratio = 1;

% torso
torso.basedia = 1/2.8;      %1/3;
torso.topdia = 1/2.2;       %1/2.5;
torso.minmajratio = 1/2;    %1/2.7;

values = {[],[], upleg, botleg, foot, ...
    [], [], upleg, botleg, foot, ...
    [], [], [], [], [], neck1, ...
    head, [], uparm, lowarm, [], ...
    [], [], [], [], ...
    uparm, lowarm, [], [], ...
    [], [], torso};
prop = containers.Map(keys, values);