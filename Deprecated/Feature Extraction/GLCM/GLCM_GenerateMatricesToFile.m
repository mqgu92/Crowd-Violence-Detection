function GLCM_GenerateMatricesToFile( BASEOFFSET,SYMMETRY,LEVELS,IMRESIZE,PYRAMID,RANGE )
% The Purpose of this document is to generate a set of GLCM matrices from
% video files, a matrix for each frame; these can then be used to quickly
% extract textual features using a slower machine as GLCM is the current
% bottleneck

SetupVariables; % Load the setup variables

% Create a GLCM Data Storage Folder
if ~exist(DATA_GLCM,'dir')
    mkdir(DATA_GLCM);
end

% Generate Video List (DATA_VIDEO_UFC/ALLCROWDS),
DATA_VIDEO_CHOSENSET = DATA_VIDEO_ALLCROWDS;
VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir);

%% GLCM Settings
%BASEOFFSET = [1 1; 0 1; 1 0; 1 -1; -1 1;-1 -1; 0 -1; -1 0];
%SYMMETRY = false;
%LEVELS = 16;
%IMRESIZE = 0.5;
%PYRAMID = [1 1];
PYRSIZE = size(PYRAMID);
%RANGE = [1];

%% Calculate Offset Neighbourhood
OFFSET = GLCM_CalculateNeighbourhood( BASEOFFSET,RANGE);

for i = 1: length(VideoList)
    tic;
    % Create Storage File       
    FolderExtension = GLCM_CalculateFolderName( BASEOFFSET,LEVELS,IMRESIZE,PYRAMID,RANGE,SYMMETRY);
    
    FolderLocation = fullfile(DATA_GLCM,DATA_VIDEO_CHOSENSET.name,VideoList{i,3},FolderExtension);
    
    if ~exist(FolderLocation,'dir')
        mkdir(FolderLocation);
    end

    % Create Settings File
    save(fullfile(FolderLocation,'settings.mat'),...
        'BASEOFFSET','OFFSET','SYMMETRY','LEVELS','IMRESIZE','RANGE','PYRAMID');
    
    % Read the Video File
    vidObj = VideoReader( strcat( fullfile(VideoList{i,2:3}),VideoList{i,4}));
    numFrames = get(vidObj, 'NumberOfFrames');
    
    for j = 1: numFrames
        % Load Frame and Resize
        I = rgb2gray(read(vidObj,j));
        I = imresize(I,IMRESIZE);
        
        % Split for Pyramid
        for q = 1: PYRSIZE(1)
            % Split the image into sub images as per the Pyramid
            ISplit = MISC_splitMat(I,PYRAMID(q,1),PYRAMID(q,2));
            
            GLCMData = cell(1,prod(PYRAMID(q,:)));
            % For each Pyramid Section (or entire frame [1 1])
            for p = 1: prod(PYRAMID(q,:))
                % Calcualte the GLCM matrix for the provided image section
                [GLCM2, SI]= graycomatrix(ISplit{p},'Offset',OFFSET,...
                    'Symmetric',SYMMETRY,'NumLevels',LEVELS);
                GLCMData{p} = GLCM2;
            end
            pyrString = strcat(num2str(PYRAMID(q,1)),'-',num2str(PYRAMID(q,2)));
            save( fullfile(FolderLocation,[num2str(MISC_Padzeros(j,6)),'pyr',pyrString,'.mat']),'GLCMData');
        end
    
    end
    timeTaken = toc;
    disp(timeTaken);
end


clear all;

end

