function [ FinalOut ] = RD_TextureEdgeMeasure( VIDEOLISTITEM,WINDOWSIZE,...
    WINDOWSKIP,PYR,RANGE, FRAMERESIZE,DATA_VIDEO_CHOSENSET,...
    SYMMETRY,LEVELS,BASEOFFSET)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   RD_TextureEdgeMeasure extracts both, texture, edge and pixel difference
%   measures
%
%   PYR: Array Specifying how to split the frame into [X,Y] cells
%   RANGE: The size of the neighbouhood used to generate the GLCM
%
SetupVariables;

RESIZEVALUE = FRAMERESIZE;

PYRSIZE = size(PYR);

%% Create Video Directory with Name to load the video file
fullFileName = strcat(fullfile(VIDEOLISTITEM{2:3}),VIDEOLISTITEM{4});

disp(['Processing Video: ',fullFileName]);

OFFSETS = GLCM_CalculateNeighbourhood(BASEOFFSET,RANGE);

%% Load the Video File Into Matlab
disp('Loading Video');
tic;
vidObj = VideoReader(fullFileName);
numFrames = get(vidObj, 'NumberOfFrames');

frame = rgb2gray(read(vidObj,1));
frame = imresize(frame,RESIZEVALUE);
frameSize = size(frame);
EntireVideo = zeros(frameSize(1),frameSize(2),numFrames) ;

for v = 1: numFrames;
    EntireVideo(:,:,v) = imresize(rgb2gray(read(vidObj,v)),RESIZEVALUE);
end

disp(['Loading Complete:',num2str(toc)]);

%% Set up the frames chosen for processing based on Window Skip Values
getIndex = 1:WINDOWSKIP:(numFrames - WINDOWSIZE ) ;

if isempty(getIndex)
    getIndex = 1;
    WINDOWSIZE = numFrames;
end
saveNumber = length(getIndex);

FinalOut = cell(length(saveNumber),PYRSIZE(1));


BasePyramid = GLCME_DesiredBaseMaps(PYR,20); bs = size(BasePyramid);
BaseNumber = bs(1);
BaseFactors = cell(BaseNumber,1);

for i = 1: BaseNumber
    if i ~= 1
        BaseFactors{i} = 1;
    else
        BaseFactors{i} = [1,factors(BasePyramid(i,1)),BasePyramid(i,1)];
    end
end

GLCMSet = cell(BaseNumber, numFrames);  %{1} = Matrix,{2} Factors
% Initial Pass, Compute Base GLCM Matrices
FramesProcessed = zeros(1,numFrames);

for i = 1 : saveNumber
    s = getIndex(i);
    for f = 0 : WINDOWSIZE - 1
        if FramesProcessed(s+f) == 0
            I = EntireVideo(:,:,s + f); % Get Frame
            FramesProcessed(s + f) = 1;
            
            %For Each Base Compute a GLCM Matrix
            for b = 1: BaseNumber
                [ GLCMPartitionCollection ] = GLCME_ComputeGLCM( I, BasePyramid(b,:), OFFSETS,LEVELS);
                GLCMSet{b,s + f} = GLCMPartitionCollection;           
            end               
        end
    end
end



for q = 1: PYRSIZE(1)
    
    CurrentPyramidStructure = PYR(q,:);
    

    frameBufferTexture = cell(numFrames,prod(PYR(q,:)));
    frameBufferEdge = cell(numFrames,prod(PYR(q,:)));
    frameBufferDifference = cell(numFrames,prod(PYR(q,:)));
    
    
    for i = 1 : saveNumber
       % disp([num2str(i) 'of', num2str(saveNumber)]);
        s = getIndex(i);
        
        ENERGYSeries =  zeros(WINDOWSIZE,prod(CurrentPyramidStructure));
        CONTRASTSeries =  zeros(WINDOWSIZE,prod(CurrentPyramidStructure));
        EDGESseries = zeros(WINDOWSIZE,prod(CurrentPyramidStructure));
        
        for f = 0 : WINDOWSIZE - 1

            
            % Check if the frame Buffer Data is present, if so we can just call
            % old data from memory rather than recompute.
            if isempty(frameBufferTexture{s + f,1})

                
                for p = 1: CurrentPyramidStructure
                    
                 % Determin the factor that so that we can load the base
                 GLCMSet{b,s + f}
                 
                end
                % Calculate the Stats Based on the GLCM
                GLCMData = cell(1,prod(CurrentPyramidStructure));
                for p = 1: prod(CurrentPyramidStructure)
                    GLCMData{p} = cat(3,GLCMPartitionCollection{1,p,:});
                    statss = graycoprops(GLCMData{p},{'Contrast','Energy'});
                    ENERGYSeries(f + 1,p) =  mean(statss.Energy);
                    CONTRASTSeries(f + 1,p)  =  mean(statss.Contrast);
                    frameBufferTexture{s + f,p} = statss;
                    
                end
                
                
            else
                % As the GLCM Matrix is in the buffer just compute stats
                for p = 1: prod(PYR(q,:))
                    ENERGYSeries(f + 1,p) =  mean( frameBufferTexture{s + f,p}.Energy);
                    CONTRASTSeries(f + 1,p)  =  mean( frameBufferTexture{s + f,p}.Contrast);
                end
            end
            
            
            
            %% Edge Magnitude Calculation
            if isempty(frameBufferEdge{s + f,1})
                [BW] = edge(I,'zerocross');
                BWSplit = MISC_splitMat(BW,CurrentPyramidStructure(1),...
                    CurrentPyramidStructure(2));
                for p = 1: prod(CurrentPyramidStructure)
                    %% Calculate Edge Count/Edge Magnitude
                    BWSub = BWSplit{p};
                    EDGESseries(f + 1,p) = sum(sum(BWSub)) / numel(BWSub);
                    frameBufferEdge{s + f,p} = EDGESseries(f + 1,p);
                end
            else
                EDGESseries(f + 1,p) =  frameBufferEdge{s + f,p};
            end
            
        end
        
        
        
        %% Compute Pixel Differences between Adjacent Frames
        DiffSeries = zeros(WINDOWSIZE - 1,1);
        
        f1 = EntireVideo(:,:,s);
        ISplitF1 = MISC_splitMat(f1,PYR(q,1),PYR(q,2));
        for f = 0 : WINDOWSIZE - 3
            
            f2 = EntireVideo(:,:,s + f);
            ISplitF2 = MISC_splitMat(f2,PYR(q,1),PYR(q,2));
            
            if isempty(frameBufferDifference{s + f,1})
                
                for p = 1: prod(PYR(q,:))
                    SubF = ISplitF1{p} - ISplitF2{p};
                    DiffSeries(f + 1,p) =  sum(sum(SubF))/ numel(SubF);
                    frameBufferDifference{s + f,p} = DiffSeries(f + 1,p);
                end
            else
                DiffSeries(f + 1,p) = frameBufferDifference{s + f,p};
            end
            ISplitF1 = ISplitF2;
        end
        
        subSample = zeros(prod(PYR(q,:)),8);
        % Get Stats on sample
        for p = 1: prod(PYR(q,:))
            subSample(p,1) = mean(EDGESseries(:,p));
            subSample(p,2) = var(EDGESseries(:,p));
            subSample(p,3) = mean(DiffSeries(:,p));
            subSample(p,4) = var(DiffSeries(:,p));
            subSample(p,5) = mean(ENERGYSeries(:,p));
            subSample(p,6) = var(ENERGYSeries(:,p));
            subSample(p,7) = mean(CONTRASTSeries(:,p));
            subSample(p,8) = var(CONTRASTSeries(:,p));
        end
        FinalOut{i,q} = reshape(subSample,1,numel(subSample));
    end
end

end

