
SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_HOCKEY;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);


%% CHOOSE DATASET
%DATA_VIDEO_CHOSENSET = DATA_VIDEO_UFC;
WORDS = 3000;
SUBSET_SIZE = 500000;
BASEOFFSETS = {[0 1; 1 0; 0 -1; -1 0]};
LEVELSET = {64};
PYRAMIDS = {[4 4]};
RANGES = {[1 2]};
%WINDOWSIZES = {12,24,48,99999};
WINDOWSPLITS = {1 2 3 4 5};
WINDOWSIZES = {999999};
PCA = true;
DATA = DATA_VIDEO_CHOSENSET.name;

IND_WINDOW = 1;
IND_OFFSET = 1;
IND_LEVEL = 1;
IND_PYRAMIDS = 1;
IND_RANGE = 1;
IND_WINDOWSPLIT = 1;
WINDOWSKIP = 1;    % Window between sample extraction

%WINDOWSIZE = 25;        % Length of temporal window for descriptor extraction

    

TESTNUMBER = length(BASEOFFSETS) * length(LEVELSET) * length(PYRAMIDS) *...
    length(RANGES) * length(WINDOWSPLITS) * length(WINDOWSIZES);

% Accuracy, ROC, ROC PLOT , One for Frest, One for SVM
GLOBALOUTPUT =  cell(TESTNUMBER,11);
% TESTNUMBER * 6, 1 TEST ALL FEATURES, ANOTHER JUST MOTION, ANOTHER JUST
% VISUAL and a variant with and without PCA

for TEST = 1:TESTNUMBER
    
    WINDOWSIZE = WINDOWSIZES{IND_WINDOW};
    BASEOFFSET = BASEOFFSETS{IND_OFFSET};
    LEVELS = LEVELSET{IND_LEVEL};
    PYRAMID = PYRAMIDS{IND_PYRAMIDS};
    RANGE = RANGES{IND_RANGE};
    WINDOWSPLIT = WINDOWSPLITS{IND_WINDOWSPLIT};
    SYMMETRY = false;   %ALWAYS FALSE
    
    IMRESIZE = 1;
    PYRSIZE = size(PYRAMID);
    
    FRAMERESIZE = IMRESIZE;
    
    Param_GLCM = struct('baseoffsets',BASEOFFSET,...
    'graylevel',LEVELS,...
    'pyramid',PYRAMID,...
    'range',RANGE);


Param_Edge = Param_EdgeCardinality_Default;

Param_PixelDifference=  Param_PixelDifference_Default;
    
    
    
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
    
    Loaded = false;
    % Create the Output Folder
    if ~exist(OUTPUT ,'dir')
        mkdir(OUTPUT);
    else
        %Dataexists so load it
        if exist(fullfile(OUTPUT,'TestOutput.mat'),'file')
            load(fullfile(OUTPUT,'TestOutput.mat'));
            Loaded = true;
            disp('Loaded');
            
        end
    end
    
    %Determine the number of FOLDS as dictated by the video list
    if ~Loaded
    
    % Variable Declaration
    VideoListExtended = {}; totalTime = 0;
    SourceVideoCount = size(VideoList);
    Descriptors = []; DescriptorsTags = []; DescriptorGroup = [];
    
    for i = 1 : SourceVideoCount(1)
        tic;
        % Select the current Item Being Tested
        VideoListItem = VideoList(i,:);
        
        if SourceVideoCount(2) >5 % Does the data use a custom window skip value?
            if ~isempty(VideoList{i,6})
                WS = VideoList{i,6};
            else
                WS =  WINDOWSKIP;
            end
        else
            WS = WINDOWSKIP;
        end
        
        % Peform feature extraction
      %  ExtractedVideoFeatures = RD_TextureEdgeMeasure( VideoListItem,WINDOWSIZE,...
       %     WS,PYRAMID,RANGE, FRAMERESIZE,DATA_VIDEO_CHOSENSET,...
       %     SYMMETRY,LEVELS,BASEOFFSET);
        % Formate the entire Scene, Each Row is a different Window/Scene
        OFFSETS = GLCM_CalculateNeighbourhood(BASEOFFSET,RANGE);
        EntireVideo = RD_LoadVideo(VideoListItem,FRAMERESIZE);
        GLCM_SET = RD_ComputeGLCMSet( EntireVideo, PYRAMID, OFFSETS,LEVELS );
        ExtractedVideoFeatures = RD_ComputeGLCMFeatures(GLCM_SET, WINDOWSIZE,WINDOWSPLIT,WINDOWSKIP,[1:4]');
        
       % Formate the entire Scene, Each Row is a different Window/Scene
        if iscell( ExtractedVideoFeatures)
        ExtractedVideoFeatures = cell2mat(ExtractedVideoFeatures);
        end
        
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
            % Assign the feature a group within the K-FOLD
            clear Tags
            [Tags{1:ExtractedSceneCount}] = deal(VideoList{i,5});
            DescriptorGroup = [DescriptorGroup;Tags'];
            
        end
        % Output Process Time
        currentTime = toc; totalTime = totalTime + currentTime;
        disp(strcat(num2str(currentTime),'(',num2str(totalTime),')'));
    end
    
    
        
    % Remove NaN values that rarely occur due to rounding?

    NanValues = isnan(Descriptors);
    Descriptors(NanValues) = 0;
    
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

        save(strcat(OUTPUT,'/Settings','.mat'),...
        'Param_Edge',...
        'Param_GLCM',...
        'Param_PixelDifference',...
        'WINDOWSIZE',...
        'WINDOWSKIP',...
        'IMRESIZE',...
        '-v7.3');
    end
    
    [G GN] = grp2idx(GEPTags);  % Reduce character tags to numeric grouping
    
    
    
    
    
    
    
    for k = 1: max(cell2mat(GEPGroup)) %Number of Folds
        disp(['Starting Test ',num2str(k)]);
        % Split data into two groups (Fight.NotFight) based on DescriptorGroup
        % number
        % testData = find(str2num([DescriptorGroup{:}]')== k);
        testData = find([GEPGroup{:}]'== k);
        TESTIDX = false(length(GEPGroup),1);
        TESTIDX(testData) = true;
        TRAINIDX = ~TESTIDX;
        
        % Save group assignments into a
        DataSplit{k,1} = k;
        DataSplit{k,2} = TRAINIDX;
        DataSplit{k,3} = TESTIDX;
        DataSplit{k,4} = G;
        DataSplit{k,5} = GN;
        
        
        
        
        %Generate Vocobulary from Training Data
        
        UnFormattedData = FN_ReformalizeDescriptorFromStructure( GEPNonPCADescriptors, PYRAMID,8,WINDOWSPLIT );
        TRAINData = FN_ReformalizeDescriptorFromStructure( GEPNonPCADescriptors(TRAINIDX,:),PYRAMID,8,WINDOWSPLIT );
        TRAINData = cell2mat(TRAINData);
        % Pick a subset
        if SUBSET_SIZE <= length(TRAINData)
            SubsetInd = randperm(length(TRAINData));
            SubsetInd = SubsetInd(1:SUBSET_SIZE);
        else
            SubsetInd = 1:length(TRAINData);
        end
        
        if length(SubsetInd) < WORDS
            VOCAB = ML_VocabGeneration( TRAINData(SubsetInd,:), length(SubsetInd) );
        else
            VOCAB = ML_VocabGeneration( TRAINData(SubsetInd,:), WORDS );
        end
        
        clear TRAINData;
        
        
        REFORMALIZEDDATA = ML_NearestWord( UnFormattedData, VOCAB,WORDS );
        
        %% TEST USING LINEAR SVM
        [ LinearSVM_Confusion{k},...
            LinearSVM_Accuracy(k),...
            LinearSVM_Probablity_estimates{k},...
            LinearSVM_Training_model{k},...
            LinearSVM_Final_decision{k},...
            LinearSVM_Actual_answer{k} ]...
            = ML_TwoClassLibLinearSVM(REFORMALIZEDDATA ,TESTIDX,TRAINIDX,G,GN,LINEAR_SVM_VERBOSE );
        LinearSVM_Vocabulary{k} = VOCAB;
        
%         [RandomForest_Confusion{k},...
%             RandomForest_Accuracy(k),...
%             RandomForest_Probablity_estimates{k},...
%             RandomForest_Training_model{k},...
%             RandomForest_Final_decision{k},...
%             RandomForest_Actual_answer{k} ] = ML_TwoClassForest(REFORMALIZEDDATA,...
%             TESTIDX,...
%             TRAINIDX,...
%             G,...
%             GN,...
%             RANDOM_FOREST_TREES,...
%             RANDOM_FOREST_VERBOSE,...
%             RANDOM_FOREST_VERBOSE_MODEL);
%         RandomForest_Vocabulary{k} = VOCAB;
%         
    end
    
    %Get AUC
    
%     AnswersNumeric = cell2mat(reshape(RandomForest_Actual_answer,FOLD,1));
%     Classes =  GN; Answers = cell(length(AnswersNumeric),1);
%     Answers(AnswersNumeric == 1) = Classes(1); Answers(AnswersNumeric == 2) = Classes(2);
%     if length(unique(AnswersNumeric)) >= 2
%         TreeProb = cell2mat(reshape(RandomForest_Probablity_estimates,FOLD,1)); TreeProb = TreeProb(:,1);
%         [RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,'Abnormal');
%         GLOBALOUTPUT{TEST ,1} = mean(RandomForest_Accuracy);
%         GLOBALOUTPUT{TEST ,2} = RF_AUC;
%         GLOBALOUTPUT{TEST ,3} = [RF_X,RF_Y];
%       
%     end
%     
    
    AnswersNumeric = cell2mat(reshape(LinearSVM_Actual_answer,FOLD,1));
    Classes =  GN; Answers = cell(length(AnswersNumeric),1);
    Answers(AnswersNumeric == 1) = Classes(1); Answers(AnswersNumeric == 2) = Classes(2);
    if length(unique(AnswersNumeric)) >= 2
        [X,Y,T,LINAUC] = perfcurve(Answers ,  cell2mat(reshape(LinearSVM_Probablity_estimates,FOLD,1)) ,'Abnormal' );
        GLOBALOUTPUT{TEST ,4} = mean(LinearSVM_Accuracy);
        GLOBALOUTPUT{TEST ,5} = LINAUC;
        GLOBALOUTPUT{TEST ,6} = [X,Y];
    else
        GLOBALOUTPUT{TEST ,4} =0;
        GLOBALOUTPUT{TEST ,5} = 0;
        GLOBALOUTPUT{TEST ,6} = 0;
    end
    
    GLOBALOUTPUT{TEST ,7} = BASEOFFSET;
    GLOBALOUTPUT{TEST ,8} = LEVELS;
    GLOBALOUTPUT{TEST ,9} = PYRAMID;
    GLOBALOUTPUT{TEST ,10} = RANGE ;
    GLOBALOUTPUT{TEST ,11} = IND_WINDOW ;
    %% Update the Counters
    IND_OFFSET = IND_OFFSET + 1;
    if mod(IND_OFFSET,length(BASEOFFSETS) + 1) == 0
        IND_OFFSET = 1;
        
        IND_LEVEL = IND_LEVEL + 1;
        if mod(IND_LEVEL,length(LEVELSET) + 1) == 0
            IND_LEVEL = 1;
            
            IND_RANGE = IND_RANGE + 1;
            if mod(IND_RANGE,length(RANGES) + 1) == 0
                IND_RANGE = 1;
                
                IND_PYRAMIDS = IND_PYRAMIDS + 1;
                if mod(IND_PYRAMIDS,length(PYRAMIDS) + 1) == 0
                    IND_PYRAMIDS = 1;
                    
                    IND_WINDOW = IND_WINDOW + 1;
                    if mod(IND_WINDOW,length(WINDOWSIZES) + 1) == 0
                        IND_WINDOW = 1;
                        
                        IND_WINDOWSPLIT = IND_WINDOWSPLIT + 1;
                        if mod(IND_WINDOWSPLIT,length(WINDOWSPLITS) + 1) == 0
                            IND_WINDOWSPLIT = 1;
                        end
                    end
                end
            end
            
        end
        
    end
    
    disp([TEST,IND_OFFSET,IND_LEVEL,IND_RANGE,IND_PYRAMIDS,IND_WINDOW]);
    
    
end