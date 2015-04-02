function [ imocap, cyl_params] = create_human_surfaces( imocap, bone_properties, point_density, cyl_div_map)
%CREATE_HUMAN_SURFACES Creates the surfaces that represent different parts
%of the human body. The initial (offset) transformation is also applied to
%every bone.
%
% Input
%   imocap          : Struct. See the output of LOAD_IMOCAP_SEQ.
%   bone_properties : Struct. Properties of body cylinders. See DEFINE_LIMB_PROP.
%   point_density   : Float. Number of points per area unit. (optional)
%   cyl_div_map     : Map with keys bone names and each entry a 1x2 Integer 
%                     [circular_divisions, axial_divisions] for cylinder. (optional)
%
%   Note: If cyl_div is already provided we do not need point_density. If
%   cyl_div is not provided, we calculate these parameters using point_density.
%
% Output
%   imocap : The structure as it came in, except that each bone in 
%               imocap.bone is updated to have the following fields -
%            pts           : Actual points on the bone surface.
%            surfnormals   : Surface normals of every point.
%            triangulation : Surface triangulation.
%
% --
% Julieta & Ankur
if nargin < 4 
    if isempty(point_density)
       error('One of the input params out of cyl_div or point_density must be specified.' );
    end   
else
    if ~isempty(point_density)
        error('Only one of the input params out of cyl_div or point_density should be specified.' );
    end 
end
cyl_params_vals = cell(numel(bone_properties.keys), 1);    
bone_ind = 0;
for name = bone_properties.keys,    
    bone_ind  = bone_ind + 1;
    bone_name = name{1};
    % Check whether we defined properties for this bone.
    if ~isempty(bone_properties( bone_name )),
        % Obtain the bone parameters.
        basedia     = bone_properties( bone_name ).basedia;
        topdia      = bone_properties( bone_name ).topdia;
        minmajratio = bone_properties( bone_name ).minmajratio;
        
        % Obtain the bone's offset transformation and bone lenght.
        bone                  = imocap.bones( bone_name );
        offset_transformation = bone.offsetTr;
        len                   = bone.len;
        
        % Calculate the cylinder parameters to give them points
        % proportional to the limb area.
        radius   = len * ((basedia + topdia) / 2);
        limbArea = 2*pi * len * radius;
        if isempty(point_density)
            bone_prop_val = cyl_div_map(bone_name);
            circDiv = bone_prop_val(1);
            numDiv  = bone_prop_val(2);
        else
            circDiv = ceil( sqrt( point_density * limbArea * ((basedia + topdia) / 2)) );
            numDiv  = ceil( (circDiv / ((basedia + topdia) / 2)) / (2*pi) );
            cyl_params_vals{bone_ind} = [circDiv numDiv];
        end
        
        if circDiv <= 2 || numDiv <= 2;
            error('The bones are not dense enough.');
        end
        
        % Call the cylinder wrapper that retuns also a triangulation.
        [tri, x,y,z] = triangulated_cylinder( linspace(len*basedia , len*topdia, numDiv), circDiv);
        
        % Scaling. 
        y = y*minmajratio;
        z = z .* len;
        
        % Getting surface normals.
        % ---display code---
        % surfnorm(x, y, z)
        
        % NOTE:: THESE SURFACE NORMALS ARE POINING INWARDS RATHER THAN RADIALLY OUTWARDS.
        [nx, ny, nz]   = surfnorm(x, y, z);
        pts            = [x(:)'; y(:)'; z(:)'];
        surfaceNormals = [nx(:)'; ny(:)'; nz(:)'];
        
        % Store these in the structure.
        bone.pts           = transform_pts(pts, offset_transformation);
        % For normals we just use rotation as transformation.
        bone.surfnormals   = transform_pts(surfaceNormals, offset_transformation(1:3, 1:3));
        % Store the triangulation.
        bone.triangulation = tri;
        
        % Put back into the imocap structure.
        imocap.bones( bone_name ) = bone;
    end
end
if nargout > 1
    cyl_params = containers.Map(bone_properties.keys, cyl_params_vals);
end

