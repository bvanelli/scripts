function [ imCorrected ] = correct_perspective( im )
%CORRECT_PERSPECTIVE Summary of this function goes here
%   Detailed explanation goes here
%

carro_chassi_t = niblack(im,-.5,1) < otsu(im)/2;
f = iblobs(carro_chassi_t,'area',[20 Inf],'touch',0);
[u,v] = size(carro_chassi_t);
teste_centros = zeros(u,v);
for i = 1:length(f)
    centros(i,:) = [f(i).uc,f(i).vc];
    teste_centros(ceil(f(i).vc), ceil(f(i).uc)) = 1;
end

teste_centros = idilate(teste_centros, ones(5,5));

hg2 = Hough(teste_centros);
%imshow(im);
%hg2.plot();
lines = hg2.lines();
[~, qtdLines] = size(lines);

lineVotes = zeros(qtdLines,1);
pointsInLine = cell(qtdLines,1);
for j = 1:qtdLines
    line = rt2hmgLin([lines(j).rho,lines(j).theta]);
    for i = 1:length(centros)
        res = line'*e2h([centros(i,2);centros(i,1)]);
        if(abs(res) < 3)
            lineVotes(j) = lineVotes(j) +1;
            pointsInLine{j}(lineVotes(j)) = f(i);
        end
    end
end

proportion = zeros(qtdLines,1);
for i = 1:qtdLines
    if(lineVotes(i) > 5)
        points = pointsInLine{i};
        clear xpos;
        for k = 1:length(points)
            xpos(k) = points(k).uc;
        end
        [~, pos] = sort(xpos);
        points = permute(points,pos);
        soma = 0;
        for j = 1:(length(points)-2)
            soma = soma + abs(pdist([points(j).uc,points(j).vc;points(j+1).uc,points(j+1).vc])  -   pdist([points(j+1).uc,points(j+1).vc;points(j+2).uc,points(j+2).vc])  );
        end
        proportion(i) = soma/(length(points));
    else
        proportion(i) = 5000;
    end
end

[~,positions] = sort(proportion)
lines = permute(lines,positions);
%Fazer a média dos pontos centrais das linhas, aceitar só aqueles q
%estiverem perto da linha da posição (1)?
k = 1;
for i = 1:qtdLines
    if(lineVotes(i) > 5)
        temp(k) = lines(i);
        k = k+1;
    end
end
clear lines;

lines = temp;
[~, qtdLines] = size(lines);

k = 1;
for i = 1:length(centros)
    for j = 1:qtdLines
        line = rt2hmgLin([lines(j).rho,lines(j).theta]);
        res = line'*e2h([centros(i,2);centros(i,1)]);
        if(abs(res) < 3)
            result(k) = f(i);
            k = k+1;
            break;
        end
    end
end

minU = 5000000;
maxU = -1;
minV = 5000000;
maxV = -1;
maxDistU = -1;
maxDistV = -1;
for i = 1:length(result)
    minU(minU > result(i).umin) = result(i).umin;
    maxU(maxU < result(i).umax) = result(i).umax;
    minV(minV > result(i).vmin) = result(i).vmin;
    maxV(maxV < result(i).vmax) = result(i).vmax;
    maxDist = length(result(i).umin:result(i).umax);
    maxDistU(maxDistU < maxDist) = maxDist;
    maxDist = length(result(i).vmin:result(i).vmax);
    maxDistV(maxDistV < maxDist) = maxDist;
end

[v,u] = size(carro_chassi_t);

minU = minU - maxDistU/4;
minU(minU<=0) = 1;

maxU = maxU + maxDistU/4;
maxU(maxU>=u) = u;

minV = minV - maxDistV/4;
minV(minV<=0) = 1;

maxV = maxV + maxDistV/4;
maxV(maxV>=v) = v;


%imshow(carro_chassi_t(minV:maxV,minU:maxU));


for i = 1:length(result)
    s(i) = result(i).area;
end

groups = kmeans(s', 2);
[~, pos] = max(s);
gletras = groups(pos);

idx = find(groups == gletras);

plate = result(idx);

for i = 1:length(plate)
    xpos(i) = plate(i).umin;
end
[~, pos] = sort(xpos);
plate = permute(plate,pos);

p1 = [plate(1).umin, plate(end).umin, plate(1).umin, plate(end).umin; plate(1).vmin, plate(end).vmin ,plate(1).vmax, plate(end).vmax ];


p2 = [plate(1).umin, plate(end).umin, plate(1).umin, plate(end).umin; plate(1).vmin, plate(1).vmin ,plate(1).vmax, plate(1).vmax ];

H = homography(p1, p2);

%p1 = [minU, minU, maxU, maxU; minV, maxV, maxV, minV ];

%p1 = h2e(H*e2h(p1));

imCorrected = homwarp(H, im(minV:maxV,minU:maxU), 'full');
imCorrected(isnan(imCorrected)) = 1;

end
