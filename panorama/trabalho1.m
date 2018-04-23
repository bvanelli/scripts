clear all
images = iread('dataset/*.JPG','double');
[~,~,~,numImages] = size(images);

im2 = images(:,:,:,1);
sf2 = isurf(im2);%,'nfeat', 10);

for i = 2:(numImages)
    im1 = im2;
    im2 = images(:,:,:,i);
    
    sf1 = sf2;
    sf2 = isurf(im2);
    
    m = sf1.match(sf2,'top',500);
    
    H{i-1} = ransac(@homography,[m.p1; m.p2],0.5);
    if(i > 2)
        H{i-1} = H{i-1} * H{i-2};
    end
end

H = [eye(3) H];
indexCentral = ceil(numImages/2);
inversa = inv(H{indexCentral});

for i = 1:numImages
    H{i} = H{i} * inversa;
end

for i = 1:(numImages)
    [imagesFinal{i} offs{i}] = homwarp(inv(H{i}), images(:,:,:,i), 'full');
end

[yMaxs,xMaxs, c] = cellfun(@size,imagesFinal);
offsets = cell2mat(offs);

limitYSuperior = max(abs(offsets(2:2:end)));

yMaxs = yMaxs + offsets(2:2:end);
yFinal = max(yMaxs) + limitYSuperior;

limitXEsquerda = abs(min(offsets(1:2:end)));
[maxX, indexMaxX] = max(offsets(1:2:end));
xFinal = limitXEsquerda + maxX + xMaxs(indexMaxX);%xMaxs(numImages-1) deveria receber o tamanho da imagem correspondente a max(offsets(1:2:end))


pInicialx = limitXEsquerda;
pInicialy = limitYSuperior;
panoramic = zeros(yFinal,xFinal,3);

for i = 1:numImages
    panoramic = paste2(panoramic,imagesFinal{i},[(pInicialx+ offsets(i*2 -1)) (pInicialy+ offsets(i*2))]);
end
imshow(panoramic)








