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

FolderExtension = GLCM_CalculateFolderName(BASEOFFSET,...
    LEVELS,...
    RESIZEVALUE,...
    PYR,...
    RANGE,...
    SYMMETRY);

FolderLocation = fullfile(DATA_GLCM,...
    DATA_VIDEO_CHOSENSET.name,...
    VIDEOLISTITEM{3},...
    FolderExtension);

%% Load the Video File Into Matlab
vidObj = VideoReader(fullFileName);
numFrames = get(vidObj, 'NumberOfFrames');

%% Set up the frames chosen for processing based on Window Skip Values
getIndex = 1:WINDOWSKIP:(numFrames - WINDOWSIZE ) ;
saveNumber = length(getIndex);

FinalOut = cell(length(saveNumber),PYRSIZE(1));

for q = 1: PYRSIZE(1)
    
    CurrentPyramidStructure = PYR(q,:);
    
    % MaximumEdge = vidObj.Height * vidObj.Width;
    % MaximumDifference = MaximumEdge * 255; % All pixels change state fully
    
    frameBufferTexture = cell(numFrames,prod(PYR(q,:)));
    frameBufferEdge = cell(numFrames,prod(PYR(q,:)));
    frameBufferDifference = cell(numFrames,prod(PYR(q,:)));
    
    
    for i = 1 : saveNumber
        disp([num2str(i) 'of', num2str(saveNumber)]);
        s = getIndex(i);
        
        ENERGYSeries =  zeros(WINDOWSIZE,prod(CurrentPyramidStructure));
        CONTRASTSeries =  zeros(WINDOWSIZE,prod(CurrentPyramidStructure));
        EDGESseries = zeros(WINDOWSIZE,prod(CurrentPyramidStructure));
        
        for f = 0 : WINDOWSIZE - 1
            % What Video Frame Are We Processing
            FrameNumber = s + f;
            
            %% Check If the GLCM File Exists
            %            GLCM_Exists = false;
            
            %             pyrString = strcat(num2str(CurrentPyramidStructure(1)),...
            %                 '-',num2str(CurrentPyramidStructure(2)));
            %
            %             FILE = fullfile(FolderLocation,...
            %                 [num2str(MISC_Padzeros(FrameNumber,6)),...
            %                 'pyr',pyrString,'.mat']);
            %
            %             if exist(FILE,'file')
            %                 GLCM_Exists = true;
            %                 load(FILE);
            %             else
            %                 GLCMData = cell(1,prod(CurrentPyramidStructure));
            %             end
            %
            disp(['Processing Video Frame:',num2str(FrameNumber)]);
            
            % Read Frame Image
            I = rgb2gray(read(vidObj,s + f));
            I = imresize(I,RESIZEVALUE);
            
            % Check if the frame Buffer Data is present, if so we can just call
            % old data from memory rather than recompute.
            if isempty(frameBufferTexture{s + f,1})
                
                ISplit = MISC_splitMat(I,CurrentPyramidStructure(1),...
                    CurrentPyramidStructure(2));
                
                GLCMPartitionCollection = cell(1,prod(CurrentPyramidStructure),length(OFFSETS));
                for g = 1: length(OFFSETS)
                    
                    
                    SUBOFFSET = OFFSETS(g,:);
                    % Check that the file exists
                    tic;
                    
                    FolderLocation = fullfile(DATA_GLCM,...
                        DATA_VIDEO_CHOSENSET.name,...
                        VIDEOLISTITEM{3},...
                        GLCM_CalculateFolderName(SUBOFFSET,...
                        LEVELS,...
                        RESIZEVALUE,...
                        PYR,...
                        RANGE,...
                        SYMMETRY));
                    disp(['Creating FileName :',num2str(toc)]);
                    tic;
                    pyrString = strcat(num2str(CurrentPyramidStructure(1)),...
                        '-',num2str(CurrentPyramidStructure(2)));
                    
                    FILE = fullfile(FolderLocation,...
                        [num2str(MISC_Padzeros(FrameNumber,6)),...
                        'pyr',pyrString,'.mat']);
                    disp(['Other File Stuff :',num2str(toc)]);
                    % Load the file
                    if exist(FILE,'file')
                            load(FILE);
                            GLCMPartitionCollection{1,1,g} = GLCMData;
    
                    else
                        GLCMData = cell(1,prod(CurrentPyramidStructure));
                        for p = 1: prod(CurrentPyramidStructure)
                            [GLCMPartitionCollection{1,p,g}, ~]= graycomatrix(ISplit{p},...
                                'Offset',SUBOFFSET,...
                                'Symmetric',SYMMETRY,...
                                'NumLevels',LEVELS);
                            GLCMData{p} = cat(3,GLCMPartitionCollection{1,p,:});
                        end
                        
                        %With all partitions in tow, save the suboffset
                        GLCM_Save(GLCMData, FrameNumber, SUBOFFSET, SYMMETRY, LEVELS,...
                            RESIZEVALUE,RANGE, PYR,CurrentPyramidStructure,...
                            DATA_VIDEO_CHOSENSET,VIDEOLISTITEM);
                    end
                    
                end
                
                
                % Calculate the Stats Based on the GLCM
                GLCMData = cell(1,prod(CurrentPyramidStructure));
                for p = 1: prod(CurrentPyramidStructure)
                    GLCMData{p} = cat(3,GLCMPartitionCollection{1,p,:});
                    statss = graycoprops(GLCMData{p},{'all'});
                    ENERGYSeries(f + 1,p) =  mean(statss.Energy);
                    CONTRASTSeries(f + 1,p)  =  mean(statss.Contrast);
                    frameBufferTexture{s + f,p} = statss;
                    
                end
    
            else
                % As the GLCM Matrix is in the buffer just compute stats
                for p = 1: prod(PYR(q,:))
                    %EDGESseries(f + 1,p) =  frameBufferEdge{s + f,p};
                    ENERGYSeries(f + 1,p) =  mean( frameBufferTexture{s + f,p}.Energy);
                    CONTRASTSeries(f + 1,p)  =  mean( frameBufferTexture{s + f,p}.Contrast);
                end
            end
        end
        
        %% Edge Magnitude Calculation
        if isempty(frameBufferEdge{s + f,1})
            [BW] = edge(I,'canny');
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
        
        
        %% Compute Pixel Differences between Adjacent Frames
        DiffSeries = zeros(WINDOWSIZE - 1,1);
        
        f1 = rgb2gray(read(vidObj,s));
        f1 = imresize(f1,RESIZEVALUE);
        ISplitF1 = MISC_splitMat(f1,PYR(q,1),PYR(q,2));
        for f = 0 : WINDOWSIZE - 3
            f2 = rgb2gray(read(vidObj, s + f)); % Read the Frame
            f2 = imresize(f2,RESIZEVALUE);
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

