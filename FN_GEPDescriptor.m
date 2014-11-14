function [  GEPNonPCADescriptors,GEPDescriptors,GEPTags,GEPFlowList,GEPGroup]...
    = FN_GEPDescriptor(VideoList,DATA_VIDEO_CHOSENSET,Param_GLCM,Param_Edge,Param_PixelDifference,WINDOWSIZE,WINDOWSKIP,IMRESIZE)
% GEP Descriptor is comprised of GLCM Co-Occurannce features/ Edge
% Cardinality and Inter-frame pixel difference between adjacent frames

%
    EDGEDETECTOR = Param_Edge.type;
    
    PDJUMP = Param_PixelDifference.framejump;
    
    BASEOFFSET = Param_GLCM.baseoffsets;
    LEVELS = Param_GLCM.graylevel;
    PYRAMID = Param_GLCM.pyramid;
    RANGE = Param_GLCM.range;
    SYMMETRY = false;   %ALWAYS FALSE
    
    % PYRSIZE = size(PYRAMID);
    
    %WINDOWSKIP = 30;    % Window between sample extraction
    %WINDOWSIZE = 8;        % Length of temporal window for descriptor extraction
    FRAMERESIZE = IMRESIZE;
        %Determine the number of FOLDS as dictated by the video list
    FOLD = max([VideoList{:,5}]);
    % Determine Output Folder Name
    FolderExtension = ['o',sprintf('%d',reshape(BASEOFFSET,1,numel(BASEOFFSET))),...
        'l',sprintf('%d',LEVELS),...
        'i',num2str(IMRESIZE),...
        'p',num2str(reshape(PYRAMID,1,numel(PYRAMID))),...
        'r',num2str(RANGE),...
        's',sprintf('%d',SYMMETRY)];
    FolderExtension(FolderExtension == ' ') = '';
    FolderExtension(FolderExtension == '.') = '_';
    
    
    FolderLocation = fullfile('ALLDATAMEX',DATA_VIDEO_CHOSENSET.name,...
        ['WS',num2str(WINDOWSKIP),...
        'W',num2str(WINDOWSIZE),...
        'F',num2str(FOLD),...
        FolderExtension]);
    
    OUTPUT = FolderLocation;
    
    % Create the Output Folder
    if ~exist(OUTPUT ,'dir')
        mkdir(OUTPUT);
    end
    

    % Variable Declaration
    VideoListExtended = {}; totalTime = 0;
    SourceVideoCount = size(VideoList);
    Descriptors = []; DescriptorsTags = []; DescriptorGroup = [];
    
    for i = 1 : SourceVideoCount(1)
        tic;
        % Select the current Item Being Tested
        VideoListItem = VideoList(i,:);
        
        if SourceVideoCount(2) > 5 % Does the data use a custom window skip value?
            if ~isempty(VideoList{i,6})
                WS = VideoList{i,6};
            else
                WS =  WINDOWSKIP;
            end
        else
           WS =  WINDOWSKIP; 
        end
        
        % Peform feature extraction
        ExtractedVideoFeatures = RD_TextureEdgeMeasure( VideoListItem,WINDOWSIZE,...
            WS,PYRAMID,RANGE, FRAMERESIZE,DATA_VIDEO_CHOSENSET,...
            SYMMETRY,LEVELS,BASEOFFSET);
        % Formate the entire Scene, Each Row is a different Window/Scene
        ExtractedVideoFeatures = cell2mat(ExtractedVideoFeatures);
        
        ExtractedSceneCount = size(ExtractedVideoFeatures);
        ExtractedSceneCount = ExtractedSceneCount(1); % Scene count is vertical
        
        % Append Number of Samples Taken from the sample
        VideoListExtended = [VideoListExtended;VideoList(1,:),ExtractedSceneCount];
        
        if ExtractedSceneCount ~= 0 && ~isempty(ExtractedVideoFeatures);
            % Add features to a global list
            Descriptors = [Descriptors;ExtractedVideoFeatures];
            % assign class tags to each feature
            clear Tags
            [Tags{1:ExtractedSceneCount}] = deal(VideoList{i,1});
            DescriptorsTags = [DescriptorsTags;Tags'];
            % Assign the feature a group within the K-folds
            clear Tags
            [Tags{1:ExtractedSceneCount}] = deal(VideoList{i,5});
            DescriptorGroup = [DescriptorGroup;Tags'];
            
        end
        % Output Process Time
        currentTime = toc; totalTime = totalTime + currentTime;
        disp(strcat(num2str(currentTime),'(',num2str(totalTime),')'));
    end
    
    DescriptorsCopy = Descriptors;
    
    Descriptors = cell2mat(PerformPCA(Descriptors));
    
    GEPNonPCADescriptors = DescriptorsCopy;
    GEPDescriptors = Descriptors;
    GEPTags = DescriptorsTags;
    GEPFlowList = VideoList;
    GEPGroup = DescriptorGroup;
    save(strcat(OUTPUT,'/TestOutput','.mat'),...
        'GEPDescriptors',...
        'GEPTags',...
        'GEPGroup',...
        'GEPFlowList',...
        'GEPNonPCADescriptors',...
        '-v7.3');
end

