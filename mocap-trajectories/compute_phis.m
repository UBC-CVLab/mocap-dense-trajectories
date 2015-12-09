function phis = compute_phis( imocap, campos )
%COMPUTE_PHIS Gets the relative angles between the person's hip facing
%direction and the camera position.
%
% Input
%   imocap : See the output of LOAD_IMOCAP_SEQ.
%   campos : 1-by-3 matrix. Camera position in the 3D world. 
%
% Output
%   phis : n-long vector. Each entry is the angle between the hip's heading
%          direction and the camera position.
%
% --
% Julieta

% Slice the hip_headings.
% hip_transformations = squeeze(num2cell(imocap.trans{1}, [1, 2]));
% hip_headings        = cellfun( @(x) x(1:3, 3)', hip_transformations, 'UniformOutput', false );
% hip_headings        = cell2mat( hip_headings );
hip_headings        = squeeze(imocap.trans{1}(1:3, 3, :))';
% Project to the ground.
hip_headings(:, 2)  = 0;
% Normalize.
hip_headings_norm   = sqrt(sum(abs( hip_headings ).^2, 2));
hip_headings        = hip_headings ./ repmat( hip_headings_norm, [1, 3] );

nframes = size( hip_headings, 1 );
hip_loc = squeeze(imocap.trans{1}(1:3, 4, :))';
% Slice the camera opsition wrt the hip.
campos_normalized       = repmat(campos, [nframes, 1]) - hip_loc;
% Project to the ground plane and normalize.
campos_normalized(:, 2) = 0;
campos_normalized_norm  = sqrt(sum(abs(campos_normalized).^2,2));
camposes                = campos_normalized ./ repmat( campos_normalized_norm, [1, 3] );

hip_campos_angle = acos( sum( hip_headings .* camposes, 2 ));

cross_prods      = cross( hip_headings, camposes );
cross_prods      = cross_prods(:, 2);

hip_campos_angle( cross_prods < 0 ) = 2*pi - hip_campos_angle( cross_prods < 0 );
phis = hip_campos_angle;

end

