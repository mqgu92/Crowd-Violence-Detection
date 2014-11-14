function [ FinalOut ] = RD_TextureEdgeMeasure( VIDEODIR,WINDOWSIZE,WINDOWSKIP,PYR,RANGE,FLOWDIR, FRAMERESIZE,DATA_VIDEO_CHOSENSET )
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

if iscell(VIDEODIR)
    VIDEODIR = VIDEODIR{:};
end

[PATHSTR,NAME,EXT] = fileparts(VIDEODIR)


BASEOFFSET = [1 1; 0 1; 1 0; 1 -1; -1 1;-1 -1; 0 -1; -1 0];
offsets = GLCM_CalculateNeighbourhood( BASEOFFSET,RANGE);


FolderExtension = GLCM_CalculateFolderName( BASEOFFSET,16,RESIZEVALUE,PYR,RANGE,false);

FolderLocation = fullfile(DATA_GLCM,DATA_VIDEO_CHOSENSET.name,NAME,FolderExtension);




vidObj = VideoReader(VIDEODIR);
numFrames = get(vidObj, 'NumberOfFrames');
 
%dirInfo = dir(strcat(FLOWDIR,'\*.mat'));
%dirSize = size(dirInfo);
%numFrames = dirSize(1);

getIndex = 1:WINDOWSKIP:(numFrames - WINDOWSIZE ) ;
saveNumber = length(getIndex);

FinalOut = cell(length(saveNumber),PYRSIZE(1));

for q = 1: PYRSIZE(1)
MaximumEdge = vidObj.Height * vidObj.Width;
MaximumDifference = MaximumEdge * 255; % All pixels change state fully

    frameBufferTexture = cell(numFrames,prod(PYR(q,:)));
    frameBufferEdge = cell(numFrames,prod(PYR(q,:)));
    frameBufferDifference = cell(numFrames,prod(PYR(q,:)));


for i = 1 : saveNumber
    disp([num2str(i) 'of', num2str(saveNumber)]);
    s = getIndex(i);
  
    

    ENERGYSeries =  zeros(WINDOWSIZE,prod(PYR(q,:)));
    CONTRASTSeries =  zeros(WINDOWSIZE,prod(PYR(q,:)));
    EDGESseries = zeros(WINDOWSIZE,prod(PYR(q,:)));
    
    for f = 0 : WINDOWSIZE - 1
        if isempty(frameBufferTexture{s + f,1})
            %disp('empty');
            I = rgb2gray(read(vidObj,s + f));
            I = imresize(I,RESIZEVALUE);
            [BW] = edge(I,'canny');

            BWSplit = MISC_splitMat(BW,PYR(q,1),PYR(q,2));
            ISplit = MISC_splitMat(I,PYR(q,1),PYR(q,2));
            
            for p = 1: prod(PYR(q,:))
                
                BWSub = BWSplit{p};
                EDGESseries(f + 1,p) = sum(sum(BWSub)) / numel(BWSub);
                frameBufferEdge{s + f,p} = EDGESseries(f + 1,p);
                
                % Does the GLCM exist
                pyrString = strcat(num2str(PYR(q,1)),'-',num2str(PYR(q,2)));
                FILE = fullfile(FolderLocation,[num2str(MISC_Padzeros(i,6)),'pyr',pyrString,'.mat']);
                if exist(FILE,'file')
                    load(FILE);
                    statss = graycoprops(GLCMData{p},{'all'});
                else
                    
                    [GLCMData, SI]= graycomatrix(ISplit{p},'Offset',offsets,'Symmetric',true,'NumLevels',16);
                    statss = graycoprops(GLCMData,{'all'});
                end
                
                ENERGYSeries(f + 1,p) =  mean(statss.Energy);
                CONTRASTSeries(f + 1,p)  =  mean(statss.Contrast);
                frameBufferTexture{s + f,p} = statss;
            end
            
        else
            %disp('Not-empty');
            for p = 1: prod(PYR(q,:))
                EDGESseries(f + 1,p) =  frameBufferEdge{s + f,p};
                ENERGYSeries(f + 1,p) =  mean( frameBufferTexture{s + f,p}.Energy);
                CONTRASTSeries(f + 1,p)  =  mean( frameBufferTexture{s + f,p}.Contrast);
            end
        end
    end
    
    % Get Pixel Differences
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

