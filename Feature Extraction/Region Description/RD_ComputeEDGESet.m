function [ OUTPUT ] = RD_ComputeEDGESet( ENTIRE_VIDEO, GRID_SET, EDGE_TYPE )
%   Computes EDGE counts for each frame within a video for a given set of
%   grid partitions
%
%   ENTIRE_VIDEO : MxNxT Gray Scale Video File
%   GRID_SET : Mx2 Matrix describing how the X and Y axis should be
%   partitioned.


% Initialize basic variables
[M, ~] = size(GRID_SET);
[~, ~, T] = size(ENTIRE_VIDEO);
OUTPUT = cell(M,1);

% Cycle through the grid partition sets
for G = 1 : M
    CurrentGrid = GRID_SET(G,:);
    EDGEPartitionSet = zeros(T,prod(CurrentGrid));
    % Cycle through each frame
    for F = 1 : T
        [BW] = edge(ENTIRE_VIDEO(:,:,F),EDGE_TYPE);
        
        for p = 1: prod(CurrentGrid)
            % Calculate Edge Count/Edge Magnitude
            Y = rem( p - 1, CurrentGrid(1) ) + 1;
            X = ( p - Y ) / CurrentGrid(1) + 1;
            
            [ XRange,YRange ] = MISC_SplitMatInd( BW,CurrentGrid(1),...
                CurrentGrid(2), Y, X );
            
            BWSub = BW(YRange,XRange);
            EDGEPartitionSet(F,p) = sum( sum( BWSub ) ) / numel( BWSub );
        end
    end
    
    OUTPUT{G} = EDGEPartitionSet;
end

end

