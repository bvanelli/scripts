%%---------------------------------
% Copyright (C) 2017-2018, by Marcelo R. Petry
% This file is distributed under the MIT license
% 
% Copyright (C) 2017-2018, by Marcelo R. Petry
% Este arquivo é distribuido sob a licença MIT
%%---------------------------------

clear, clc, close all

%% simple plate recognition
carro = iread('dataset-simple/placa_carro1.jpg', 'double', 'grey');
moto = iread('dataset-simple/placa_moto1.jpg', 'double', 'grey');
template = load_font('fonte/letras.png', 'fonte/numeros.png');

% car plate recognition
s1 = get_plate(carro, template);
h1 = get_plate_header(carro, template);

% bike plate recognition
s2 = get_plate(moto, template);
h2 = get_plate_header(moto, template);

%% read plate images
imagefiles = dir('dataset\*.jpg');
template = load_font('fonte/letras.png', 'fonte/numeros.png');
for i = 1:length(imagefiles)
    images{i} = iread(strcat('dataset\',imagefiles(i).name),'double','grey');
    plates{i} = correct_perspective_matlab(images{i});
end

%%
best = [4, 5, 6, 9];
for i = best
    code{i} = get_plate(plates{i}, template);
    state_city{i} = get_plate_header(plates{i}, template);
end
