function [model_surfaces, id_data] = put_surfaces_in_place(imocap, frame_range)
% PUT_SURFACES_IN_PLACE Moves the cylinders to the positions in the 3d
% world. The returned structure is an array of transformed poses that can
% now be rendered.
%
% Input
%   imocap         : See the output of LOAD_IMOCAP_SEQ.
%   frame_range    : 1x2 Integer. [begin_frame end_frame]. Optional.
%                    Defaults to the entire sequence.
%                    Note: these frame indices correspond to
%                    imocap structure.
%
% Output
%   model_surfaces : 1-by-num_frames array of structures. Each entry
%                   contains the transformed points of the 3d body
%                   according to the  pose of that frame. The entries of
%                   the structure are -
%
%                   fNum    : The frame number.
%                   pts3D   : 1-by-nbones cell array. The transformed 3d points
%                             of fNum.
%                   norms3D : 1-by-nbones cell array. The transformed normals
%                             of fNum.
%  id_data        : Strcture with following information:
%                     limbs  : 2-by-nbones cell array containing names and
%                              imocap id for each limb.
%                     pt_ids : 1-by-nbones cell array. Unique id of each
%                              pt on the surface.
%                     dist   : 1-by-nbones cell array. Each entry is a
%                               symmetrix distance matrix between points of
%                               a bone.
% -------
% Julieta & Ankur

trmocap     = imocap.trans;
nframes     = size(trmocap{1}, 1);

% Default values.
DEFAULT_FRAME_RANGE = [1 nframes];

% Use the wholse sequence if no frame range is specified.
if nargin<2 || isempty(frame_range)
    frame_range = DEFAULT_FRAME_RANGE;
end

calc_pt_id_data = 0;
if nargout>1
    calc_pt_id_data = 1;
end

% Define the structure for model_surfaces.
frameDataSt    = struct('fNum', [], 'pts3D', [], 'norms3D', []);
model_surfaces = repmat(frameDataSt, 1, floor((frame_range(2)-frame_range(1)+1)));

% Get the different body parts that will be created.
[~, imocap_ind_map] = get_imocap_targets();

% Define the limbs that we want to move, and their respective indices in
% the bone targets (i.e., the complete bone list).
considered_limbs = {'LeftUpLeg', 'LeftLeg', 'LeftFoot', 'RightUpLeg', ...
    'RightLeg', 'RightFoot', 'LeftArm', 'LeftForeArm', 'RightArm', ...
    'RightForeArm','Neck1', 'Head', 'Torso'};
nlimbs           = numel( considered_limbs );

limbs_to_construct = cell( nlimbs, 2 );

for i =1:nlimbs,
    limbs_to_construct{i, 1} = considered_limbs{i};
    limbs_to_construct{i, 2} = imocap_ind_map( considered_limbs{i} );
end

% Create space for the output
all_pts3D = cell( nlimbs, nframes );
all_norms = cell( nlimbs, nframes );
all_ids   = cell( nlimbs, 1);
dist_func = cell( nlimbs, 1);

pt_id_ctr   = 1; % Point ID counter
% Move the boyd parts for all the frames.
for i = 1:nlimbs,
    
    if ~strcmp( limbs_to_construct{i, 1}, 'Torso' ),
        % Get the trasnformations for this bone.
        T     = imocap.trans{  limbs_to_construct{i, 2} };
    else
        % The torso is a special case. We have to build the transformation
        % right here.
        leftArmInd    = imocap_ind_map('LeftArm');
        left_arm_loc  = cellfun(@(x) x(1:3, 4), imocap.trans{leftArmInd}, 'UniformOutput', false);
        
        rightArmInd = imocap_ind_map('RightArm');
        right_arm_loc = cellfun(@(x) x(1:3, 4), imocap.trans{rightArmInd}, 'UniformOutput', false);
        
        leftHipInd = imocap_ind_map('LeftUpLeg');
        left_hip_loc  = cellfun(@(x) x(1:3, 4), imocap.trans{leftHipInd}, 'UniformOutput', false);
        
        rightHipInd = imocap_ind_map('RightUpLeg');
        right_hip_loc = cellfun(@(x) x(1:3, 4), imocap.trans{rightHipInd}, 'UniformOutput', false);
        
        topMid = cellfun(@(x, y) mean([x,y],2), left_arm_loc, right_arm_loc, 'UniformOutput', false);
        botMid = cellfun(@(x, y) mean([x,y],2), left_hip_loc, right_hip_loc, 'UniformOutput', false);
        
        % unit vectors
        xu = cellfun(@minus, left_arm_loc, right_arm_loc, 'UniformOutput', false);
        xu = cellfun(@(x) x/norm(x), xu,     'UniformOutput', false);
        zu = cellfun(@minus, topMid, botMid, 'UniformOutput', false);
        zu = cellfun(@(x) x/norm(x), zu,     'UniformOutput', false);
        yu = cellfun(@cross, zu, xu,         'UniformOutput', false);
        
        T = cellfun(@(a,b,c,d) [a, b, c, d], xu, yu, zu, botMid, 'UniformOutput', false );
    end
    
    T_rot = cellfun(@(x) x(1:3, 1:3), T, 'UniformOutput', false);
    
    % Select this bone.
    bone = imocap.bones( limbs_to_construct{i, 1} );
    
    % Transform the 3d points.
    num_pts  = size(bone.pts, 2);
    bone_pts = { [bone.pts; ones(1, num_pts)] };
    bone_pts = repmat( bone_pts, [nframes, 1] );
    Tpts     = cellfun(@mtimes, T, bone_pts, 'UniformOutput', false );
    Tpts     = cellfun(@(x) x(1:3,:),  Tpts, 'UniformOutput', false );
    
    % Transform the normals.
    bone_normals = repmat( {bone.surfnormals}, [nframes, 1] );
    Tbone        = cellfun(@mtimes, T_rot, bone_normals, 'UniformOutput', false );
    
    all_pts3D(i, :) = Tpts;
    all_norms(i, :) = Tbone;
    if calc_pt_id_data
        all_ids{i}  = pt_id_ctr:pt_id_ctr + num_pts - 1;
        pt_id_ctr   = pt_id_ctr + num_pts;
        D           = zeros(num_pts, num_pts);
        for pt_i = 1:num_pts
            D(pt_i, :) = perform_fast_marching_mesh(bone.pts, bone.triangulation, pt_i);
        end
        dist_func{i} = D;                
    end
end
% Copy all to the output structure.
frame_i = 1;
for i = frame_range(1) : min(frame_range(2), nframes)
    model_surfaces(frame_i).fNum = i;
    
    model_surfaces(frame_i).pts3D   = all_pts3D(:, i);
    model_surfaces(frame_i).norms3D = all_norms(:, i);
    frame_i = frame_i + 1;
end

if calc_pt_id_data
    id_data.limbs  = limbs_to_construct;
    id_data.pt_ids = all_ids;
    id_data.dist   = dist_func;
end
