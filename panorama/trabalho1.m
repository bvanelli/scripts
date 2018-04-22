clear all
images = iread('dataset/*.JPG','double');%,'reduce',5);

[~,~,~,numImages] = size(images);

im2 = images(:,:,:,1);
sf2 = isurf(im2);%,'nfeat', 10);

for i = 2:(numImages)
    im1 = im2;
    im2 = images(:,:,:,i);
    
    sf1 = sf2;
    sf2 = isurf(im2);
    
    m = sf1.match(sf2,'top',200);
    
    H{i-1} = ransac(@homography,[m.p1; m.p2],2);
    if(i > 2)
        H{i-1} = H{i-1} * H{i-2};
    end
end

for i = 1:(numImages-1)
    [imagesFinal{i} offs{i}] = homwarp(inv(H{i}), images(:,:,:,i+1), 'full');
end

im = images(:,:,:,1);
[v,u,c] = size(im);

[yMaxs,xMaxs, c] = cellfun(@size,imagesFinal);
offsets = cell2mat(offs);

limitYSuperior = max(abs(offsets(2:2:end)));

yMaxs = yMaxs + offsets(2:2:end);
yFinal = max(yMaxs) + limitYSuperior;
xFinal = offsets(end-1) + xMaxs(numImages-1);


pInicialx = 1;
pInicialy = limitYSuperior;
panoramic0 = zeros(yFinal,xFinal);


panoramic = ipaste(panoramic0,im,[pInicialx pInicialy],'add');

for i = 1:(numImages-1)
    panoramic = paste2(panoramic,imagesFinal{i},[(pInicialx+ offsets(i*2 -1)) (pInicialy+ offsets(i*2))]);
end
imshow(panoramic)





