function [ blobs ] = get_blobs( im )
% GET_BLOBS return all significant (in area) blobs in the image, that are at
% most first children of the background.
%
% Example:
%
%       plate = iread('dataset/placa_carro1.jpg', 'double', 'grey');
%       plate = plate > 0.2;
%       blobs = get_blobs(plate);
%       for i = 1:length(blobs)
%           b{i} = blobs{i}.Image;
%       end
%       idisp(b);

    f = iblobs(im, 'area', [20 Inf], 'touch', 0);
    
    j = 1;
    background = f.parent;
    for i = 1:length(f)
        if f(i).parent == background
            box = f(i);
            temp.Image = im(box.vmin:box.vmax, box.umin:box.umax);
            temp.Box = f(i).box;
            blobs{j} = temp;
            j = j + 1;
        end
    end

end

