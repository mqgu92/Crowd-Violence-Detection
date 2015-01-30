function [ volume_set ] = EXP_determine_sub_volumes(W,H,L, PointData)
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

applyToGivenRow = @(func, matrix) @(row) func(matrix(row, :));
applyToRows = @(func, matrix) arrayfun(applyToGivenRow(func, matrix), 1:size(matrix,1),'UniformOutput',false)';

PointData(:,7) = deal(W);
PointData(:,8) = deal(H);
PointData(:,9) = deal(L);

volume_set = applyToRows(@Check_Boundary, PointData);


end

function [A] = Check_Boundary(varargin)
    A = 0;
    varargin = varargin{1};
    x = varargin(1);
    y = varargin(2);
    t = varargin(3);
    w = varargin(4);
    h = varargin(5);
    l = varargin(6);
    v_w = varargin(7);
    v_h = varargin(8);
    v_l = varargin(9);

    L = t + l;
    w_t = w / 2;
    h_t = h / 2;
    x_f = floor(x - floor(w_t));
    x_c = floor(x + ceil(w_t));
    y_f = floor(y - floor(h_t));
    y_c = floor(y + ceil(h_t));

    if x < 1 || y < 1 || y > v_h || x > v_w || t < 1 || t > v_l
        return %Error, not a valid point
    end
    if x_f < 1 
       x_f = 1;
    end
    if x_c > w 
       x_c = v_w;
    end
    
    if y_f < 1
        y_f = 1;
    end
    
    if y_c > h
        y_c = v_h;
    end
    
    if L > v_l
        L = v_l;
    end

    A = [x_f,y_f,t,x_c,y_c,L];
    A = round(A);
end
