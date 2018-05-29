function [ blobs, boxes] = get_blobs( im )
% GET_BLOBS return all significant (in area) blobs in the image, that are at
% most first children of the background.
%
% Example:
%
%       plate = iread('dataset/placa_carro1.jpg', 'double', 'grey');
%       plate = plate > 0.2;
%       [blobs, boxes] = get_blobs(plate);
%       idisp(blobs);

    f = iblobs(im, 'area', [20 Inf], 'touch', 0);

    j = 1;
    if ~isempty(f)
        background = f.parent;
    else
        blobs{1} = [];
        boxes{1} = [];
    end
    for i = 1:length(f)
        if f(i).parent == background
            box = f(i);
            aspect = (box.vmin - box.vmax) / (box.umin - box.umax);
            if (aspect > 1.2 && aspect < 2.5) || (aspect > 4 && aspect < 10)
                temp.Image = im(box.vmin:box.vmax, box.umin:box.umax);
                temp.Box = f(i).box;
                blobs{j} = temp.Image;
                boxes{j} = temp.Box;
                j = j + 1;
            end
        end
    end

end

