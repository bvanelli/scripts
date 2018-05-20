function [ result ] = splitImage( im, centers)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    [u v] = size(im);
    numDiv = 5;

    limitsU = ceil(u/numDiv);
    limitsV = ceil(v/numDiv);
    
    us = 1:limitsU:u;
    us = [us u];
    vs = 1:limitsV:v;
    vs = [vs v];
    result = zeros(numDiv,numDiv);
    for i = 1:length(centers)
        for j = 1:(numDiv)
            for k = 1:(numDiv)
                if(centers(i,1)>vs(j) && centers(i,1) < vs(j+1) && centers(i,2)>us(k) && centers(i,2) < us(k+1))
                    result(j,k) = result(j,k) + 1;
                end
            end
        end
    end
    
%     imshow(im);
%     for i = 1:length(us)
%         for j = 1:length(vs)
%             plot_circle([vs(i) us(j)],10, 'fillcolor', 'r');
%         end
%     end
    
end

