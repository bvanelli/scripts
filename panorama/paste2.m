function [ newIm ] = paste2( im,im2,p )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    newIm = im;
    [u,v,c] = size(im2);
    for x = 1:v
        for y = 1:u
            if(~isnan(im2(y,x)))
                newIm(p(2)+y,p(1)+x,:) = im2(y,x,:);
            end
        end
    end
end

