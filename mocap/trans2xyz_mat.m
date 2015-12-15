function xyz_mat = trans2xyz_mat( trans )
% TRANS2XYZ_MAT Get the xyz coordinates in the matrix form.
%
% xyz_mat : 3*num_nz_bones x num_frames single.

% ---
% Ankur
xyz_cell = cellfun(@(x) reshape(x(:, 4, :), 3, []), trans, 'UniformOutput', false);
xyz_mat  = cell2mat(xyz_cell');
end

