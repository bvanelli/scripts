%%---------------------------------
% Copyright (C) 2017-2018, by Marcelo R. Petry
% This file is distributed under the MIT license
% 
% Copyright (C) 2017-2018, by Marcelo R. Petry
% Este arquivo Ã© distribuido sob a licenÃ§a MIT
%%---------------------------------

clear, clc, close all

%Problemas, o I está sendo todo escalado, o que é terrível, deve-se
%adicionar linahs pretas ou brancas ao lado da letra para ficar com a mesma
%largura que as outras, isso pode ser feito na linha 33 do get_plate e 20
%do get_plate_header

%Problema, se está assumindo que o treshold fará a letra ficar branca, o
%que é mentira. Deve-se detectar a cor da letra na hr de mandar o dataset
%pro template_match, sugiro contar os pixeis pretos e brancos da placa.
% verdade.

% read plate images

carro = iread('dataset/placa_carro1.jpg', 'double', 'grey');
moto = iread('dataset/placa_moto1.jpg', 'double', 'grey');

template = load_font('fonte/letras.png', 'fonte/numeros.png');

% car plate recognition
s1 = get_plate(carro, template);
h1 = get_plate_header(carro, template);

% bike plate recognition
s2 = get_plate(moto, template);
h2 = get_plate_header(moto, template);


im = iread('dataset/Escolha_placa_960_640.jpg', 'double','grey');
imCorre = correct_perspective(im);

s3 = get_plate(imCorre, template);
h3 = get_plate_header(imCorre, template);


