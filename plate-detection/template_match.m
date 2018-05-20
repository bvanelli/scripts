function [ decoded_char ] = template_match( character, template, method )
%TEMPLATE_MATCH is a function that finds the best match for the character
%in the template using the zncc algorithm.
%
% Usage:
%
%  [ decoded_char ] = template_match( character, template, method )
%
% See also GET_PLATE.
    if strcmp(method, 'letter')
        space = template.ALPHABET;
        dictionary = template.Letters;
    elseif strcmp(method, 'number')
        space = template.DIGITS;
        dictionary = template.Numbers;
    else
        error('template_match method is not recognized. Use letter or number.');
    end
            
%     [u, v] = size(character);
%     for i = 1:length(dictionary)
%         scaled_image = ~imresize(dictionary{i}, [u, v]);
%         sim(i) = zncc(character, scaled_image);
%     end
    
    % detect I and 1 by proportion instead of matching
    proportion = size(character, 1)/size(character, 2);
    if proportion < 1.3*83/16 && proportion > 0.59*83/16
        if strcmp(method, 'letter')
            decoded_char = 'I';
        else
            decoded_char = '1';
        end
        return;
    end
    
    for i = 1:length(dictionary)
        [u, v] = size(dictionary{i});
        scaled_image = imresize(character, [u, v]);
        sim(i) = zncc(scaled_image, dictionary{i});
    end
    
    [~, letter_pos] = max(sim);
    decoded_char = space(letter_pos);
end

