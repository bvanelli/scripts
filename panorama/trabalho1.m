clear all
images = iread('dataset/*.JPG','double');
[~,~,~,numImages] = size(images);

im2 = images(:,:,:,1);
sf2 = isurf(im2);%,'nfeat', 10);

for i = 2:(numImages)
    im1 = im2;
    im2 = images(:,:,:,i);
    
    sf1 = sf2;
    sf2 = isurf(im2);%,'nfeat', 10);
    
    m = sf1.match(sf2)%,'top',300);
    
    H{i-1} = ransac(@homography,[m.p1; m.p2],0.5);
    if(i > 2)
        H{i-1} = H{i-1} * H{i-2};
    end
end

for i = 1:(numImages-1)
    [imagesFinal{i} offs{i}] = homwarp(inv(H{i}), images(:,:,:,i+1), 'full');
end

im = images(:,:,:,1);
[u,v,~] = size(im);

[yMaxs,xMaxs] = cellfun(@size,imagesFinal);
yMaxs = [yMaxs u];
xMaxs = [xMaxs v];
yFinal = max(yMaxs);
xFinal = sum(xMaxs);

offsets = cell2mat(offs);
xOffset = sum(offsets(1:2:end));
yOffset = sum(offsets(2:2:end));
yFinal = yFinal - yOffset;

[u,v,c] = size(imagesFinal{end});

panoramic0 = zeros(yFinal,offsets((numImages-1)*2 -1)+u);


panoramic = ipaste(panoramic0,im,[1 -yOffset],'add');

for i = 1:(numImages-1)
    panoramic = paste2(panoramic,imagesFinal{i},[offsets(i*2 -1) sum(-offsets(2:2:end)) + offsets(i*2)]);
end

[nonZeroRows, ~, ~] = find(panoramic);
% Get the cropping parameters
topRow = min(nonZeroRows(:));
bottomRow = max(nonZeroRows(:));
% Extract a cropped image from the original.
croppedpanoramic = panoramic(topRow:bottomRow, 1:end, :);

idisp(croppedpanoramic);

