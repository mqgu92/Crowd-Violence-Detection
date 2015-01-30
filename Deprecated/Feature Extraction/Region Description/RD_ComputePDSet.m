function [ OUTPUT ] = RD_ComputePDSet( ENTIRE_VIDEO, GRID_SET )
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
    PDPartitionSet = zeros(T - 1,prod(CurrentGrid));
    % Cycle through each frame
    for F = 1 : T - 1
        
        for p = 1: prod(CurrentGrid)
            F1 = ENTIRE_VIDEO(:,:,F);F2 = ENTIRE_VIDEO(:,:,F + 1);
           
            Y = rem( p - 1, CurrentGrid(1) ) + 1;
            X = ( p - Y ) / CurrentGrid(1) + 1;
            
            [ XRange,YRange ] = MISC_SplitMatInd( F1,CurrentGrid(1),...
                CurrentGrid(2),...
                Y,...
                X);

            SubF = F1(YRange,XRange) - F2(YRange,XRange);
            
            PDPartitionSet(F,p) =  sum(sum(SubF))/ numel(SubF);
        end
        
    end
    
    
end

OUTPUT{G} = PDPartitionSet;
end


