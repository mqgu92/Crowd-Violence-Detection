function [ GLCMOUT ] = GLCME_Fine2Course( COARSE,FINE )
% When splitting a frame into a set of segmentation arrays we end up
% calculating the same computations multiple times, to save some time we
% only compute the most densely split GLCM and create all less fine
% matrices as the sum of parts that exist within the dense 
%
%   i.e GLCM of a frame split by 2x2, taking each cell and summing them is
%   equal to a GLCM with split 1x1 (no split)
%
%   i.e GLCM frame split 2x1 can be constructed using the two Y cells that
%   are summed across the x axis
%
%   COARSE: M by N Cell Matrix of GLCM matrices
%
%   FINE: P by Q cell Matrix of GLCM matrices

[P Q] = size(FINE); M = COARSE(1);  N = COARSE(2);

GLCMOUT = cell(M,N);

if mod(P,M) ~=0 || mod(Q,N) ~=0;
    % Error, Require Matrix Size is not a factor of the Fine grid
    return;
end

for x = 1: M
    XSplit = Q / N * (x - 1) + 1 : Q / N * x;

    for y = 1: N
        YSplit = P / M * (y - 1) + 1 : P / M * y;
        
        GLCMOUT{y,x} = sum(cat(3,FINE{YSplit,XSplit}),3);
    end
end




end

