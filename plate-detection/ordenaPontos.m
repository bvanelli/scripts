function [ newPoints ] = ordenaPontos( points , segmentedImage)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

    [yMax,xMax] = size(segmentedImage);
    
    pointsImage = [0, xMax, xMax, 0;0, 0, yMax, yMax ];
       
    
    for j = 1:length(pointsImage)
        for i = 1:length(points)
            X = [pointsImage(1,j), pointsImage(2,j); points(1,i), points(2,i)];
            d(i) = pdist(X,'euclidean');
        end
        [~, pos] = min(d);
        newPoints(:,j) = points(:,pos);
        clear d;
    end
    
%         figure;
%     hold on;
%     for j = 1:length(pointsImage)
%         plot(pointsImage(1,j),pointsImage(2,j),'y*')
%     end
%     for j = 1:length(points)
%         plot(points(1,j),points(2,j),'b*')
%     end
%     for j = 1:length(newPoints)
%         plot(newPoints(1,j),newPoints(2,j),'r*')
%     end
%     R = [cosd(-45) -sind(-45); sind(-45) cosd(-45)];

%     X = points(1,:)
%     Y = points(2,:)
%     [~, pos] = sort(Y);
% 
%     X = X(pos);
%     Y = Y(pos);
% 
%     [~, pos] = sort(X(1:2));
%     X(1:2) = X(pos);
%     Y(1:2) = Y(pos);
% 
%     [~, pos] = sort(X(3:4), 'descend');
%     X(3:4) = X(pos + 2);
%     Y(3:4) = Y(pos + 2);
% 
%     newPoints = [X;Y];
end

