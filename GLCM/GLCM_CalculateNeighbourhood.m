function [ OFFSET ] = GLCM_CalculateNeighbourhood( BASEOFFSET,RANGE )
%   Extends the base offset values out to create a small neighbourhood
%   
%   Example:
%   BASEOFFSET = [-1 -1]    with RANGE [1 2 4 8]
%   OUTPUT = [-1 -1;-2 -2;-4 -4; -8 -8]
%
OFFSETSIZE = size(BASEOFFSET);

fOffset = [];
for i = 1 : length(RANGE)
    for q = 1 : OFFSETSIZE(1)
        s = RANGE(i) .* BASEOFFSET(q,:);
        fOffset = [fOffset;s];
    end
end
OFFSET = fOffset;
end

