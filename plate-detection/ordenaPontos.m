function [ newPoints ] = ordenaPontos( points , segmentedImage)
%ORDENAPONTOS order points. That's it. It has no use outside
%correct_perspective_matlab function.
%

    [yMax,xMax] = size(segmentedImage);
    pointsImage = [0, xMax, xMax, 0;0, 0, yMax, yMax ];
    
    %pointsImage = [0, xMax, xMax, 0;b1(2)-250, b2(2)-250, b2(2)+b2(4)+250, b1(2)+b1(4)+250 ];
    
    points = [points; zeros(1,length(points))];
    for i = 1:length(points)-1
        for j = i+1:length(points)
            X = [points(1,j), points(2,j); points(1,i), points(2,i)];
            d = pdist(X,'euclidean');
            if(d < 50)
                points(3,i) = 1;
                points(3,j) = 1;
            end
        end
    end
    
    
    for j = 1:length(pointsImage)
        [~, col] = size(points);
        for i = 1:col
            X = [pointsImage(1,j), pointsImage(2,j); points(1,i), points(2,i)];
            d(i) = pdist(X,'euclidean');
        end
        [~, pos] = min(d);
        newPoints(:,j) = points(1:2,pos);
        points(:,pos) = [];
        clear d;
    end
       
    
%     for j = 1:length(pointsImage)
%         for i = 1:length(points)
%             X = [pointsImage(1,j), pointsImage(2,j); points(1,i), points(2,i)];
%             d(i) = pdist(X,'euclidean');
%         end
%         [~, pos] = sort(d);
%         if(points(3,pos(1)) < points(3,pos(2)))%O segundo ponto é uma dupla
%             if(abs(d(pos(1)) - d(pos(2))) < 100)
%                 newPoints(:,j) = points(1:2,pos(2));
%             else
%                 newPoints(:,j) = points(1:2,pos(1));
%             end
%         else
%             newPoints(:,j) = points(1:2,pos(1));
%         end
%         clear d;
%     end
    
%     figure;
%     hold on;
%     for j = 1:length(pointsImage)
%         plot(pointsImage(1,j),pointsImage(2,j),'y*')
%     end
%     for j = 1:length(points)
%         if(points(3,j) == 1)
%             plot(points(1,j),points(2,j),'g*')
%         else
%             plot(points(1,j),points(2,j),'b*')
%         end
%     end
%     for j = 1:length(newPoints)
%         plot(newPoints(1,j),newPoints(2,j),'r*')
%     end
%     R = [cosd(-45) -sind(-45); sind(-45) cosd(-45)];

    X = newPoints(1,:);
    Y = newPoints(2,:);
    [~, pos] = sort(X);

    X = X(pos);
    Y = Y(pos);

    [~, pos] = sort(Y(1:2),'descend');
    X(1:2) = X(pos);
    Y(1:2) = Y(pos);

    [~, pos] = sort(Y(3:4));
    X(3:4) = X(pos + 2);
    Y(3:4) = Y(pos + 2);
 
     newPoints = [X;Y];
end

