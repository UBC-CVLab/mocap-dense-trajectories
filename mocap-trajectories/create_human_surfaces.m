function [ imocap ] = create_human_surfaces( imocap, bone_properties, point_density )
%CREATE_HUMAN_SURFACES Creates the surfaces that represent different parts
%of the human body. The initial (offset) transformation is also applied to
%every bone.
%
% Input
%   imocap          : Struct. See the output of LOAD_IMOCAP_SEQ.
%   bone_properties : Struct. Properties of body cylinders. See DEFINE_LIMB_PROP.
%   point_density   : Float. Number of points per area unit.
%
% Output
%   imocap : The structure as it came in, except that each bone in 
%               imocap.bone is updated to have the following fields -
%            pts           : Actual points on the bone surface.
%            surfnormals   : Surface normals of every point.
%            triangulation : Surface triangulation.
%
% --
% Julieta

for name = bone_properties.keys,
    
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
        
        circDiv = ceil( sqrt( point_density * limbArea * ((basedia + topdia) / 2)) );
        numDiv  = ceil( (circDiv / ((basedia + topdia) / 2)) / (2*pi) );
        
        if circDiv <= 2 || numDiv <= 2;
            error('The bones are not dense enough.');
        end
        
        % Call the cylinder wrapper that retuns also a triangulation.
        [tri, x,y,z] = triangulated_cylinder( linspace(len*basedia , len*topdia, numDiv), circDiv);
        
        % Scaling. 
        y = y*minmajratio;
        z = z .* len;
        
        % Getting surface normals.
        [nx, ny, nz]   = surfnorm(x, y, z);
        pts            = [x(:)'; y(:)'; z(:)'];
        surfaceNormals = [nx(:)'; ny(:)'; nz(:)'];
        
        % Store these in the structure.
        bone.pts           = transformPts(pts, offset_transformation);
        % For normals we just use rotation as transformation.
        bone.surfnormals   = transformPts(surfaceNormals, offset_transformation(1:3, 1:3));
        % Store the triangulation.
        bone.triangulation = tri;
        
        % Put back into the imocap structure.
        imocap.bones( bone_name ) = bone;
    end
end

end

