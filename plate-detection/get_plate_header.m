function [ str_plate_header ] = get_plate_header( image , template )
%GET_PLATE_HEADER Summary of this function goes here
%   Detailed explanation goes here
%state city
    
    imPlate = (niblack(image,-.38,1) < otsu(image)/2);
    blobs2 = get_blobs(imPlate(1:size(imPlate)*.5,:));
    
    
    for i = 1:length(blobs2)
       s2(i) = (blobs2{i}.Box(2,2) - blobs2{i}.Box(2,1))*blobs2{i}.Box(2,1);
    end

    groups = clusterdata(s2', 2); % todo: tirei threshold = 2 da bunda
    gletras = mode(groups);
    
    idx = find(groups == gletras);
    
    stateCity = blobs2(idx);
    
    for i = 1:length(stateCity)
        p{i} = stateCity{i}.Image;
    end
    
    for i = 1:length(stateCity)
        xpos2(i) = stateCity{i}.Box(1,1);
    end
    
    [~, pos2] = sort(xpos2);
    for i = 1:length(stateCity)
       box = stateCity{pos2(i)}.Box;
       plate_unscrambled2{i} = image(box(2,1):box(2,2),box(1,1):box(1,2));
    end
    
    % correct height to remove accents
    for i = 1:length(plate_unscrambled2)
        heigth(i) = size(plate_unscrambled2{i}, 1);
    end
    mode_heigth = mode(heigth);
    for i = 1:length(plate_unscrambled2)
        try
            holder = plate_unscrambled2{i};
            plate_unscrambled2{i} = holder(end - mode_heigth:end, :);
        catch
        end
    end
    
    for i = 1:length(plate_unscrambled2)
        state_city_decoded(i) = template_match(niblack(plate_unscrambled2{i}, -0.2, 1) < otsu(plate_unscrambled2{i}), template, 'letter');
    end
    
    str_plate_header = state_city_decoded;
    
end

