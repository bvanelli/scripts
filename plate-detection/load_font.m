function [ res ] = load_font( letters_file, numbers_file )
%LOAD_FONT is a function to load fonts for template matching.
%   In order to load your font, make an image file containing all the
%   letters from left to right and in alphabetical order. The same goes for
%   the numbers, starting from 0 to 9. Then, load your fonts using the
%   images:
%
%     font = load_font( letters_image_path, numbers_image_image_path );
%
%   Ex:
%
%     template = load_font('fonte/letras.png', 'fonte/numeros.png');
    letras =  iread(letters_file, 'double', 'grey');
    numeros =  iread(numbers_file, 'double', 'grey');

    % separar letras de A a Z
    f = iblobs(letras);
    j = 1;
    background = f.parent;
    for i = 1:length(f)
       tmp = f(i).box;
       xpos(i) = tmp(1,1);
    end
    [~, order] = sort(xpos);
    f = f(order);
    for i = 1:length(f)
        if f(i).parent == background
            box = f(i);
            template_letters{j} = letras(box.vmin:box.vmax, box.umin:box.umax);
            j = j + 1;
        end
    end
    
    clear xpos;
    % separar numeros
    f = iblobs(numeros);
    j = 1;
    background = f.parent;
    for i = 1:length(f)
       tmp = f(i).box;
       xpos(i) = tmp(1,1);
    end
    [~, order] = sort(xpos);
    f = f(order);
    for i = 1:length(f)
        if f(i).parent == background
            box = f(i);
            template_numbers{j} = numeros(box.vmin:box.vmax, box.umin:box.umax);
            j = j + 1;
        end
    end
    
    % organizar resultados
    res.Letters = template_letters;
    res.Numbers = template_numbers;
    
    res.ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    res.DIGITS = '0123456789';

end

