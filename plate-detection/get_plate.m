function [ str_plate ] = get_plate(image , template)
%GET_PLATE is a function that returns plate string given an image of the
%plate and a template containing the font. The template can be generated
%using the load_font function.
%
%   Usage:
%
%       str_plate = get_plate(image , template);
%
%   Ex: 
%
%       plate =  iread('dataset/placa_carro1.jpg', 'double', 'grey');
%       template = load_font('fonte/letras.png', 'fonte/numeros.png');
%       get_plate(carro, template)

    imPlate = (niblack(image,-.5,1) < otsu(image));
    imPlate = imbinarize(image);
    if (sum(imPlate(:) == 0) > sum(imPlate(:) == 1))
       imPlate = ~imPlate;
    end
    
    imPlate = iclose(imPlate, [1 1 1;1 1 1]);
    
    [blobs boxes] = get_blobs(imPlate);

    for i = 1:length(blobs)
       box = boxes{i};
       s(i) = (box(2,2) - box(2,1));%u(1)*u(2); Pega só a altura da placa
    end

    groups = clusterdata(s', 2);
    [~, pos] = max(s);
    gletras = groups(pos);
    
    idx = find(groups == gletras);
    
    plate = blobs(idx);
    plateBox = boxes(idx);
    
    if(length(plate) ~= 7)
        str_plate = nan;
        return;
    end
    %assert(length(plate) == 7, 'Size of plate is not equal to 7 characters. Something went wrong...');
    
    box_size = plateBox{1};
    box_max_error = (box_size(2,2) -  box_size(2,1))*0.5;
    
    
    for i = 1:length(plate)
       box = plateBox{i};
       ypos(i) = box(2,1);
    end
    
    % teste whether is a car or bike plate
    if(abs(ypos - ypos(1)) < box_max_error)
        % parse the car plate
        for i = 1:length(plate)
            box = plateBox{i};
            xpos(i) = box(1,1);
        end
        [~, pos] = sort(xpos);
        for i = 1:length(plate)
            plate_unscrambled{i} = plate{pos(i)};
        end
    else
        % parsing the bike plate
        [~, pos] = sort(ypos);
        plate = permute(plate,pos);
        plateBox = permute(plateBox,pos);
        
        for i = 1:3
            box = plateBox{i};
            xpos(i) = box(1,1);
        end
        [~, pos] = sort(xpos);
        for i = 1:3
            plate_unscrambled{i} = plate{pos(i)};
        end
        
        for i = 4:7
            box = plateBox{i};
            xpos(i-3) = box(1,1);
        end
        [~, pos] = sort(xpos);
        for i = 1:4
            plate_unscrambled{i+3} = plate{pos(i) + 3};
        end
    end
    
    for i = 1:3
        plate_decoded(i) = template_match(plate_unscrambled{i}, template, 'letter');
    end
    
    for i = 4:7
        plate_decoded(i) = template_match(plate_unscrambled{i}, template, 'number');
    end
    
    str_plate = plate_decoded;
    
end

