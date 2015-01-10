function [ semantic_config ] = get_semantic_configuration()
%GET_SEMANTIC_CONFIGURATION returns the global semantic configuration used
%   to generate semantic features. Current configuration generates 32 body
%   joints on top of the imocap structure.
% @Alireza

%% Initialize

% This function helps with selecting the joint id on imocap structure.
j_id       = @(x) cellfun(@get_imocap_joint_index, x);

%% Prepare the config structure.
semantic_config = struct();

% These scales are determined manually on top of the MPII dataset for each
% joint.
semantic_config.gaussian_scale = ...
            [8 8 8 8 8 9 8 9 6 8 ...
             8 9 8 9 6 8.5 8 8 10.5 9 ...
             8.5 8 6 8.5 8 8 10.5 9 8.5 8 ...
             6 10];

% This is the mapping from the imocap structure to the 32 joint model of
% human body.

semantic_config.semantic_map = [...
    %From               %Prop %Target (HumanFig2)
    j_id({'Head'})          1      1
    j_id({'Neck1'})         1      2
    j_id({'Neck'})          1      3
    
    j_id({'RightArm'})      1      4
    j_id({'RightArm'})      0.5    5
    j_id({'RightForeArm'})  0.5    5
    j_id({'RightForeArm'})  1      6
    j_id({'RightForeArm'})  0.5    7
    j_id({'RightHand'})     0.5    7
    j_id({'RightHand'})     1      8
    j_id({'RightHand'})     3/2    9
    j_id({'RightForeArm'})  -1/2   9

    j_id({'LeftArm'})      1      10
    j_id({'LeftArm'})      0.5    11
    j_id({'LeftForeArm'})  0.5    11
    j_id({'LeftForeArm'})  1      12
    j_id({'LeftForeArm'})  0.5    13
    j_id({'LeftHand'})     0.5    13
    j_id({'LeftHand'})     1      14
    j_id({'LeftHand'})     3/2    15
    j_id({'LeftForeArm'})  -1/2   15
    
    j_id({'LeftArm'})       2/3   16
    j_id({'LeftUpLeg'})     1/3   16
    j_id({'LeftArm'})       1/3   17
    j_id({'LeftUpLeg'})     2/3   17
    j_id({'LeftUpLeg'})     1     18
    j_id({'LeftUpLeg'})     1/2   19
    j_id({'LeftLeg'})       1/2   19
    j_id({'LeftLeg'})       1     20
    j_id({'LeftLeg'})       1/2   21
    j_id({'LeftFoot'})      1/2   21
    j_id({'LeftFoot'})      1     22
    j_id({'LeftToeBase'})   1     23

    j_id({'RightArm'})       2/3   24
    j_id({'RightUpLeg'})     1/3   24
    j_id({'RightArm'})       1/3   25
    j_id({'RightUpLeg'})     2/3   25
    j_id({'RightUpLeg'})     1     26
    j_id({'RightUpLeg'})     1/2   27
    j_id({'RightLeg'})       1/2   27
    j_id({'RightLeg'})       1     28
    j_id({'RightLeg'})       1/2   29
    j_id({'RightFoot'})      1/2   29
    j_id({'RightFoot'})      1     30
    j_id({'RightToeBase'})   1     31
    
    j_id({'RightUpLeg'})     1/2   32
    j_id({'LeftUpLeg'})      1/2   32
    ];

semantic_config.bones = [...
     j_id({'Head', 'Neck1'})
     j_id({'Neck1', 'Neck'})
     
     j_id({'Neck', 'RightArm'})
     j_id({'Neck', 'LeftArm'})
     
     j_id({'RightArm', 'RightForeArm'})
     j_id({'RightForeArm', 'RightHand'})     
     
     j_id({'LeftArm', 'LeftForeArm'})
     j_id({'LeftForeArm', 'LeftHand'})     
     
     j_id({'LeftUpLeg', 'RightUpLeg'})
     
     j_id({'LeftLeg', 'LeftUpLeg'})
     j_id({'LeftFoot', 'LeftLeg'})

     j_id({'RightLeg', 'RightUpLeg'})
     j_id({'RightFoot', 'RightLeg'})
     
     ];
 
 % Used to map mirrored joints
 semantic_config.collapse = {
    [1], [2], [3], ...
    [4, 10], [5, 11], [6, 12], [7, 13], [8, 14], [9, 15], ...
    [16, 24], [17, 25], [18, 26], [19, 27], [20, 28], [21, 29], [22, 30], [23, 31], ...
    [32]
    };
 
 
end

