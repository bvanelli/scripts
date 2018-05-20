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

    imPlate = (niblack(image,-.5,1) < otsu(image)/2);
    
    imPlate = iopen(imPlate, [1 1 1;1 1 1]);
    
    blobs = get_blobs(imPlate);

    for i = 1:length(blobs)
       u = size(blobs{i}.Image);
       s(i) = u(1);%u(1)*u(2); Pega só a alura da placa
    end

    groups = clusterdata(s', 2);
    [~, pos] = max(s);
    gletras = groups(pos);
    
    idx = find(groups == gletras);
    
    plate = blobs(idx);
    assert(length(plate) == 7, 'Size of plate is not equal to 7 characters. Something went wrong...');
    
    box_size = plate{1}.Box;
    box_max_error = (box_size(2,2) -  box_size(2,1))*0.1;
    
    
    for i = 1:length(plate)
       ypos(i) = plate{i}.Box(2,1);
    end
    
    % teste whether is a car or bike plate
    if(abs(ypos - ypos(1)) < box_max_error)
        % parse the car plate
        for i = 1:length(plate)
            xpos(i) = plate{i}.Box(1,1);
        end
        [~, pos] = sort(xpos);
        for i = 1:length(plate)
            plate_unscrambled{i} = plate{pos(i)}.Image;
        end
    else
        % parsing the bike plate
        [~, pos] = sort(ypos);
        plate = permute(plate,pos);
        
        for i = 1:3
            xpos(i) = plate{i}.Box(1,1);
        end
        [~, pos] = sort(xpos);
        for i = 1:3
            plate_unscrambled{i} = plate{pos(i)}.Image;
        end
        
        for i = 4:7
            xpos(i-3) = plate{i}.Box(1,1);
        end
        [~, pos] = sort(xpos);
        for i = 1:4
            plate_unscrambled{i+3} = plate{pos(i) + 3}.Image;
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

