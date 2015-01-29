function [ volume_set ] = EXP_determine_sub_volumes( varargin )
%%EXP_DETERMINE_SUB_VOLUMES 
% The purpose of this method is to convert interest points into volume
% indices for retrieval for video information.

% Using a video volume, generate the [X,Y,T,W,H,L] volumes of regions of
% interest: the input for this function is a set of points with a width,
% height, length value.
% OUTPUT:
%   A list of [X,Y,T,W,H,L] vectors that describe the indices of each
%   sub-volume for description.
%
%   T indicates the start of temporal sampling and L is the length

% In order to create volumes seen like those in global description schemes
% simply generate a set of equdistant points with equal boundaries that do
% no overlap.

% Width, Height, Length of spatio-temporal volume
% Point, Width, Hight, Length of each sub-volume

% Algorithm
%   for each point, determine if bounding area exists
%   if so, save bounds, else modify



end

function [X,Y,T,W,H,L] = Check_Boundary(x,y,w,h,l,v_w,v_h,v_l)
    X = -1;Y = -1;T = -1;W = -1;H = -1;L = l;
    
    w_t = w / 2;
    h_t = h / 2;
    x_f = x - floor(w_t);
    x_c = x + ceil(w_t);
    y_f = y - floor(h_t);
    y_c = y + ceil(h_t);
    
    if x < 1 || y < 1 || y > v_h || x > v_w || t < 1 || t > v_l
        return %Error, not a valid point
    end
    if x < 1 
       x_f = 1;
    end
    if x > w 
       x_c = w;
    end
    
    if y < 1
        y_f = 1;
    end
    
    if y > h
        y_c = h;
    end
    
    if t + l > v_l
        L = v_l;
    end
    
    X = x_f;
    Y = y_f;
    T = t;
    W = x_c;
    H = y_c;
    
end
