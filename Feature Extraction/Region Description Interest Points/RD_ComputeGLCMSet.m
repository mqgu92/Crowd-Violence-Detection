function [ OUTPUT ] = RD_ComputeGLCMSet( ENTIRE_VIDEO,GRID_SET, VOLUMES, OFFSETS,LEVELS )
%   Computes GLCM matrices for each frame within a video for a given set of
%   grid partitions
%
%   ENTIRE_VIDEO : MxNxT Gray Scale Video File
%   VOLUMES : Mx4 Matrix, X, Y, Width, Height, Frame Temporal
%
%
%   OUTPUT is a list of Co-Occurance Matrices, one for each interest point
%   in VOLUMES

%
%   Document Outline: STEP 1: Extract Volumes for GLCM Representation
%                   STEP 2: Compute GLCM Matrices for each volume
%

% Initialize basic variables
[M, ~] = size(GRID_SET);
[P, ~] = size(VOLUMES);
OUTPUT = cell(M,1);
[Q,R,S] = size(ENTIRE_VIDEO);

% STEP 1: STVolumes: Spatio Temporal Image Volumes
STVolumes = cell(P,1);
GRIDSETS = cell(P,1);
LEVELSETS = cell(P,1);
OFFSETSETS = cell(P,1);
for CurrentPoint = 1: P
    
    T = VOLUMES(CurrentPoint,6);
    Frame = VOLUMES(CurrentPoint,5);
    X = VOLUMES(CurrentPoint,1);
    Y = VOLUMES(CurrentPoint,2);
    Width = VOLUMES(CurrentPoint,3);
    Height = VOLUMES(CurrentPoint,4);
    XRange = max(1,X - round(Width/2)) : min(Q,X + round(Width/2));
    YRange = max(1,Y - round(Height/2)) : min(R,Y + round(Height/2));
    TRange = max(1,Frame):min(S,Frame + T);
    
    STVolumes{CurrentPoint,1} = ENTIRE_VIDEO(XRange,YRange,TRange);
    GRIDSETS{CurrentPoint,1} = GRID_SET;
    LEVELSETS{CurrentPoint,1} = LEVELS;
    OFFSETSETS{CurrentPoint,1} = OFFSETS;
end

clear ENTIRE_VIDEO; % Not Needed, Remove for Memory Reasons, Video Files are big brah!

% STEP 2, Compute GLCM Matrices for each Volume


[OUTPUT] = cellfun(@ComputeGLCMMatrices,STVolumes,GRIDSETS,OFFSETSETS,LEVELSETS,'UniformOutput',false );



end

function GLCMMatrix = ComputeGLCMMatrices(Volume,GRID_SET,OFFSETS,LEVELS )
[M, ~] = size(GRID_SET);
[~,~,S] = size(Volume);
% Cycle through the grid partition sets
for G = 1 : M
    
 
    CurrentGrid = GRID_SET(G,:);
    GLCMPartitionSet = cell(S,prod(CurrentGrid));
   
    % Cycle through each frame
    for F = 1 : S
        
        %size(Volume(:,:,F))
        %min(min(Volume(:,:,F)))
        %max(max(Volume(:,:,F)))
        
        GLCMPartitionCollection = GLCME_ComputeGLCM( Volume(:,:,F),...
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
    
    GLCMMatrix = GLCMPartitionSet;
end

end