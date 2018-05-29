function [ imCorrected ] = correct_perspective_matlab( im )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

carro_chassi_t = iconvolve(niblack(im,-.5,1) < otsu(im),kgauss(2));
labelImage = bwlabel(carro_chassi_t);

s = regionprops(labelImage,'BoundingBox','Area');
k = 1;
for i = 1: length(s)
    if(s(i).Area > 5000 && s(i).Area < 500000)
        props(k) = s(i);
        k = k+1;
    end
end
if(k < 6)
    %Plate not found
    imCorrected = nan;
    return;
end
boundingBoxs = cat(1, props.BoundingBox);
% [siz, ~] = size(boundingBoxs);
% for k = 1 : siz
%     rectangle('Position', [boundingBoxs(k,1),boundingBoxs(k,2),boundingBoxs(k,3),boundingBoxs(k,4)],...
%     'EdgeColor','r','LineWidth',2 )
% end

% for k = 1 : length(boundingBoxs)
%     plot(ceil(boundingBoxs(k,1) + boundingBoxs(k,3) /2),ceil(boundingBoxs(k,2) + boundingBoxs(k,4)/2),'b*')
% end
[u,v] = size(carro_chassi_t);
teste_centros = zeros(u,v);
centers = zeros(length(boundingBoxs),2);

for i = 1:length(boundingBoxs)
    centers(i,:) = [boundingBoxs(i,2) + boundingBoxs(i,4) /2,boundingBoxs(i,1) + boundingBoxs(i,3)/2];
    teste_centros(ceil(centers(i,1)-10:centers(i,1)+10),ceil(centers(i,2)-10:centers(i,2)+10)) = 1;
end

%teste_centros = imdilate(teste_centros,ones(10,10));%idilate(teste_centros, ones(10,10));

hg2 = Hough(teste_centros);
lines = hg2.lines();
strongestLine = lines(1);% = lines(lines.strength > 0.6)

k  = 1;
line = rt2hmgLin([strongestLine.rho,strongestLine.theta]);
for i = 1:length(centers)
    res = line'*e2h([centers(i,1);centers(i,2)]);
    if(abs(res) < 50)
        propsInLines(k) = props(i);
        k = k +1;
    end
end

boundingBoxs = cat(1, propsInLines.BoundingBox);
[~, pos] = sort(boundingBoxs(:,1));
boundingBoxs = permute(boundingBoxs,pos);

maxDistU = -1;
maxDistV = -1;
for i = 1:length(boundingBoxs)
    maxDistU(maxDistU < boundingBoxs(i,3)) = boundingBoxs(i,3);
    maxDistV(maxDistV < boundingBoxs(i,4)) = boundingBoxs(i,4);
end


xP = [boundingBoxs(1,1);boundingBoxs(end,1)+boundingBoxs(end,3);boundingBoxs(end,1)+boundingBoxs(end,3);boundingBoxs(1,1);boundingBoxs(1,1)];
yP = [boundingBoxs(1,2);boundingBoxs(end,2);boundingBoxs(end,2)+boundingBoxs(end,4);boundingBoxs(1,2)+boundingBoxs(1,4);boundingBoxs(1,2)];
xP(1) = xP(1) - maxDistV/3;
xP(2) = xP(2) + maxDistV/3;
xP(3) = xP(3) + maxDistV/3;
xP(4) = xP(4) - maxDistV/3;
xP(5) = xP(1);
yP(1) = yP(1) - maxDistU;
yP(2) = yP(2) - maxDistU;
yP(3) = yP(3) + maxDistU/2;
yP(4) = yP(4) + maxDistU/2;
yP(5) = yP(1);
xP(xP <= 0) = 1;
xP(xP > v) = v;
yP(yP <= 0) = 1;
yP(yP > u) = u;
xP = ceil(xP);
yP = ceil(yP);

bw = poly2mask(xP,yP,u,v);
bw = double(bw);
bw(bw == 0) = nan;
segmentedPlate = bw.*im;
segmentedPlate(isnan(segmentedPlate)) = 1;

sumArea = 0;
for i = 1:length(propsInLines)
    sumArea = sumArea + propsInLines(i).Area;
end

offsetLinha = ceil(min(yP)-maxDistU/4);
offsetLinha(offsetLinha <= 0) = 1;
offsetColuna = ceil(min(xP)-maxDistV/4);
offsetColuna(offsetColuna <= 0) = 1;

labelImage = bwlabel(~carro_chassi_t(offsetLinha:ceil(max(yP)+maxDistU/4),offsetColuna:ceil(max(xP)+maxDistV/4)));

s = regionprops(labelImage,'BoundingBox','Area','ConvexImage');
k = 1;
for i = 1: length(s)
    if(s(i).Area > sumArea)
        propsPlaca(k) = s(i);
        k = k+1;
    end
end
maxArea = -1;
for i = 1: length(propsPlaca)
    maxArea(maxArea < propsPlaca(i).Area) = propsPlaca(i).Area;
end
for i = 1: length(propsPlaca)
    if(propsPlaca(i).Area == maxArea)
        propsPlaca = propsPlaca(i);
        break;
    end
end


boundingBoxs = cat(1, propsPlaca.BoundingBox);

offsetLinha = offsetLinha + boundingBoxs(1,2);
offsetColuna = offsetColuna + boundingBoxs(1,1);

canny = edge(propsPlaca.ConvexImage,'Canny');

[H,T,R] = hough(canny);
P  = houghpeaks(H,5,'threshold',ceil(0.05*max(H(:))));
lines = houghlines(canny,T,R,P,'FillGap',200000,'MinLength',5);

% figure, imshow(propsPlaca.ConvexImage), hold on
% max_len = 0;
% for k = 1:length(lines)
%    xy = [lines(k).point1; lines(k).point2];
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    %Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    %Determine the endpoints of the longest line segment
%    len = norm(lines(k).point1 - lines(k).point2);
%    if ( len > max_len)
%       max_len = len;
%       xy_long = xy;
%    end
% end

testeRepetidas = [lines.theta; lines.rho];

groups = kmeans(testeRepetidas', 4);

for i = 1:4
    idx = find(groups == i, 1);
    linesNew(i) = lines(idx);
end

k = 1;
for i = 1:length(linesNew)-1
    for j = i+1:length(linesNew)
        inter = findIntersection(linesNew(i),linesNew(j));
        if(abs(inter(1,1)) < v && abs(inter(2,1)) < u)%trocar u por v?
            intersections(:,k) = inter;
            k = k+1;
        end
    end
end
%imshow(carro_chassi_t(min(yP):max(yP),min(xP):max(xP)));

intersections = ordenaPontos(intersections,propsPlaca.ConvexImage);

intersections(1,:) = intersections(1,:) + offsetColuna;
intersections(2,:) = intersections(2,:) + offsetLinha;

% imshow(im);
% hold on;
% for i = 1:length(intersections)
%    plot(intersections(1,i),intersections(2,i),'y*') 
% end

bw = poly2mask(intersections(1,:),intersections(2,:),u,v);
bw = double(bw);
bw(bw == 0) = nan;
segmentedPlate = bw.*im;
segmentedPlate(isnan(segmentedPlate)) = 1;

p2 = [intersections(1,1), intersections(1,1), intersections(1,1)+742, intersections(1,1) + 742; ...
    intersections(1,2)+241,intersections(1,2),intersections(1,2),intersections(1,2)+241];

H = homography(intersections, p2);
try
    imCorrected = homwarp(H, segmentedPlate, 'full');
catch
    imCorrected = nan;
    return;
end
if(isnan(imCorrected))
    return;
end
imCorrected(isnan(imCorrected)) = 1;

mask = (imCorrected ~= 1);
props = regionprops(mask, 'BoundingBox','Area');
maxArea = -1;
for i = 1: length(props)
    maxArea(maxArea < props(i).Area) = props(i).Area;
end
for i = 1: length(props)
    if(props(i).Area == maxArea)
        props = props(i);
        break;
    end
end
imCorrected = imcrop(imCorrected, props.BoundingBox);

end

