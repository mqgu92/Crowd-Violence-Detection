function [ OUTPUT ] = RD_ComputeGLCMSet( ENTIRE_VIDEO, GRID_SET, OFFSETS,LEVELS )
%   Computes GLCM matrices for each frame within a video for a given set of
%   grid partitions
%
%   ENTIRE_VIDEO : MxNxT Gray Scale Video File
%   GRID_SET : Mx2 Matrix describing how the X and Y axis should be
%   partitioned.
%       [2 2] Results in 4 GLCM matrices
%       [2 2; 3 3] Results in the above and 9 GLCM matrices
%       [1 1] Results in full frame GLCM

%   Note, A Massive optimization is achievable by computing the finer GLCM
%   matrix and then creating the courser matrices as the sum of parts of
%   the finer matrix
%
%   [1 1] = sum of all cells in [2 2]
%

% Initialize basic variables
[M, ~] = size(GRID_SET);
[~, ~, T] = size(ENTIRE_VIDEO);
OUTPUT = cell(M,1);

% Cycle through the grid partition sets
for G = 1 : M
    CurrentGrid = GRID_SET(G,:);
    GLCMPartitionSet = cell(T,prod(CurrentGrid));
    % Cycle through each frame
    for F = 1 : T
        
        GLCMPartitionCollection = GLCME_ComputeGLCM( ENTIRE_VIDEO(:,:,F),...
            GRID_SET(G,:),...
            OFFSETS,...
            LEVELS);
        
        % Reformalute the GLCM Parition Collection so that all GLCM's
        % across the third dimension are summed; the third dimension holds
        % different offset GLCM matrices
        
        GLCMData = cell(1,prod(CurrentGrid));
        for p = 1: prod(CurrentGrid)
            
            Y = rem(p-1,CurrentGrid(1))+1;
            X = (p-Y)/CurrentGrid(1) + 1;
            
            GLCMData{p} = sum(cat(3,GLCMPartitionCollection{Y,X,:}),3);
        end
        
        GLCMPartitionSet(F,:) = GLCMData;
    end
    
    OUTPUT{G} = GLCMPartitionSet;
end

end

