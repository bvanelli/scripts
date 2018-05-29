function [ intersection ] = findIntersection( line1, line2 )
%FINDINTERSECTION finds the intersection given two line objects line1 and
%line2.
%
% The line object is a structure as defined in:
% https://www.mathworks.com/help/images/ref/houghlines.html#buwgo_f-1-lines

    %line1
    x1  = [line1.point1(1,1) line1.point2(1,1)];
    y1  = [line1.point1(1,2) line1.point2(1,2)];
    %line2
    x2  = [line2.point1(1,1) line2.point2(1,1)];
    y2  = [line2.point1(1,2) line2.point2(1,2)];
    %fit linear polynomial
    p1 = polyfit(x1,y1,1);
    p2 = polyfit(x2,y2,1);
    %calculate intersection
    x_intersect = fzero(@(x) polyval(p1-p2,x),3);
    y_intersect = polyval(p1,x_intersect);
%     figure
%     line(x1,y1);
%     hold on;
%     line(x2,y2);
%     plot(x_intersect,y_intersect,'r*')
    intersection = [x_intersect;y_intersect];
end

