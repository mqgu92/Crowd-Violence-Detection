
SetupVariables;


%% CHOOSE DATASET
%DATA_VIDEO_CHOSENSET = DATA_VIDEO_UFC;

BASEOFFSETS = {[1 1; 0 1; 1 0; 1 -1; -1 1;-1 -1; 0 -1; -1 0],... % 8 Dir
    [0 1; 1 0; 0 -1; -1 0]};
LEVELSET = {8,16,32};
PYRAMIDS = {[1 1],[1 1; 4 4],[1 1 ;4 4; 8 8]};
RANGES = {1,[1 2 3], [1 2 4 8],[1 2 4 8 16]};
PCA = true;
DATA = DATA_VIDEO_CHOSENSET.name;

IND_OFFSET = 1;
IND_LEVEL = 1;
IND_PYRAMIDS = 1;
IND_RANGE = 1;

TESTNUMBER = length(BASEOFFSETS) * length(LEVELSET) * length(PYRAMIDS) *...
    length(RANGES);

% Accuracy, ROC, ROC PLOT , One for Frest, One for SVM
GLOBALOUTPUT =  cell(TESTNUMBER*6,10);
% TESTNUMBER * 6, 1 TEST ALL FEATURES, ANOTHER JUST MOTION, ANOTHER JUST
% VISUAL and a variant with and without PCA

for TEST = 1:6:TESTNUMBER * 6

    
    BASEOFFSET = BASEOFFSETS{IND_OFFSET};
    LEVELS = LEVELSET{IND_LEVEL};
    PYRAMID = PYRAMIDS{IND_PYRAMIDS};
    RANGE = RANGES{IND_RANGE};
    SYMMETRY = false;   %ALWAYS FALSE
    
    IMRESIZE = 0.5;
    PYRSIZE = size(PYRAMID);
    
    WINDOWSKIP = 30;    % Window between sample extraction
    WINDOWSIZE = 8;        % Length of temporal window for descriptor extraction
    FRAMERESIZE = IMRESIZE;
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
    
    %Determine the number of FOLDS as dictated by the video list
    
    
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
                WS = VideoList{i,6}
            else
                WS =  WINDOWSKIP
            end
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
    
    
    %% LIBSVM DATA
    LIBClassificationPerf = cell(1,FOLD);
    LIBFinalDecision = cell(1,FOLD);
    LIBAccuracy = cell(1,FOLD);
    LIBProbability = cell(1,FOLD);
    LIBActualAnswer = cell(1,FOLD);
    LIBVocab = cell(1,FOLD);
    LIBTrainingModel = cell(1,FOLD);
    LIBROC = cell(FOLD,3);
    %% LINEAR SVM DATA
    LINClassificationPerf = cell(1,FOLD);
    LINFinalDecision = cell(1,FOLD);
    LINAccuracy = cell(1,FOLD);
    LINProbability = cell(1,FOLD);
    LINActualAnswer = cell(1,FOLD);
    LINVocab = cell(1,FOLD);
    LINTrainingModel = cell(1,FOLD);
    LINROC = cell(FOLD,3);
    %% TREE DATA
    TREEClassificationPerf = cell(1,FOLD);
    TREEFinalDecision = cell(1,FOLD);
    TREEAccuracy = cell(1,FOLD);
    TREEProbability = cell(1,FOLD);
    TREEActualAnswer = cell(1,FOLD);
    TREEVocab = cell(1,FOLD);
    TREETrainingModel = cell(1,FOLD);
    TREEROC = cell(FOLD,3);
    
    DescriptorsCopy = Descriptors;
    
    Descriptors = cell2mat(PerformPCA(Descriptors,PCA));
    
    GLCMNonPCADescriptors = DescriptorsCopy;
    GLCMDescriptors = Descriptors;
    GLCMTags = DescriptorsTags;
    GLCMFlowList = VideoList;
    GLCMGroup = DescriptorGroup;
    subName = [DATA,'GLCM'];
    save(strcat(OUTPUT,'/TestOutput','.mat'),...
        'GLCMDescriptors',...
        'GLCMTags',...
        'GLCMGroup',...
        'GLCMFlowList',...
        'GLCMNonPCADescriptors',...
        '-v7.3');
    
    
    [G GN] = grp2idx(GLCMTags);  % Reduce character tags to numeric grouping
    
    for TESTTYPE = 1: 6
        
        switch TESTTYPE
            case 1
                FinalDescriptor = cell2mat(PerformPCA(GLCMNonPCADescriptors,PCA));
            case 2
                FinalDescriptor = cell2mat(PerformPCA(GLCMNonPCADescriptors(:,[1 3 5 7]),PCA));
            case 3
                FinalDescriptor = cell2mat(PerformPCA(GLCMNonPCADescriptors(:,[2 4 6 8]),PCA));
            case 4
                FinalDescriptor = GLCMNonPCADescriptors;
            case 5
                FinalDescriptor = GLCMNonPCADescriptors(:,[1 3 5 7]);
            case 6
                FinalDescriptor = GLCMNonPCADescriptors(:,[2 4 6 8]);
        end
        
    for k = 1: max(cell2mat(GLCMGroup)) %Number of Folds
        disp(['Starting Test ',num2str(k)]);
        % Split data into two groups (Fight.NotFight) based on DescriptorGroup
        % number
        % testData = find(str2num([DescriptorGroup{:}]')== k);
        testData = find([GLCMGroup{:}]'== k);
        TESTIDX = false(length(GLCMGroup),1);
        TESTIDX(testData) = true;
        TRAINIDX = ~TESTIDX;
        
        % Save group assignments into a
        DataSplit{k,1} = k;
        DataSplit{k,2} = TRAINIDX;
        DataSplit{k,3} = TESTIDX;
        DataSplit{k,4} = G;
        DataSplit{k,5} = GN;
        
        


        %% TEST USING LINEAR SVM
        [CPerf,finalDecision,Answer,accuracy,prob_estimates,trainingModel,subROC ]...
            = ML_TwoClassLibLinearSVM(FinalDescriptor ,TESTIDX,TRAINIDX,G,GN );
        
        LINFinalDecision{k} = finalDecision;
        LINAccuracy{k} = accuracy;
        LINProbability{k} = prob_estimates;
        LINActualAnswer{k} = Answer;
        LINTrainingModel{k} = trainingModel;
        LINClassificationPerf{k} = CPerf;
        LINROC(k,:) = subROC;
        
        %% TEST RANDOM FOREST
        [ r,finalDecision,Answer,accuracy,prob_estimates,svmMo ]...
            = ML_TwoClassForest(FinalDescriptor ,TESTIDX,TRAINIDX,G,GN );
        
        TREEFinalDecision{k} = finalDecision;
        TREEAccuracy{k} = accuracy;
        TREEProbability{k} = prob_estimates;
        TREEActualAnswer{k} = Answer;
        TREETrainingModel{k} = svmMo{:};
        TREEClassificationPerf{k} = r;
        
    end
    
    %Get AUC
    FightIndex = 1;
    TreeProb = cell2mat(reshape(TREEProbability,FOLD,1));
    TreeProb = TreeProb(:,1);
    [TREEX,TREEY,T,TREEAUC] = perfcurve( cell2mat(reshape(TREEActualAnswer,FOLD,1)) , TreeProb,FightIndex );
    [X,Y,T,LINAUC] = perfcurve( cell2mat(reshape(LINActualAnswer,FOLD,1)) ,  cell2mat(reshape(LINProbability,FOLD,1)) ,FightIndex );

    
    GLOBALOUTPUT{TEST + TESTTYPE - 1,1} = mean([TREEAccuracy{:}]);
    GLOBALOUTPUT{TEST + TESTTYPE - 1,2} = TREEAUC;
    GLOBALOUTPUT{TEST + TESTTYPE - 1,3} = [TREEX,TREEY];
    
    GLOBALOUTPUT{TEST + TESTTYPE - 1,4} = mean([LINAccuracy{:}]);
    GLOBALOUTPUT{TEST + TESTTYPE - 1,5} = LINAUC;
    GLOBALOUTPUT{TEST + TESTTYPE - 1,6} = [X,Y];
    
    GLOBALOUTPUT{TEST + TESTTYPE - 1,7} = BASEOFFSET;
    GLOBALOUTPUT{TEST + TESTTYPE - 1,8} = LEVELS;
    GLOBALOUTPUT{TEST + TESTTYPE - 1,9} = PYRAMID;
    GLOBALOUTPUT{TEST + TESTTYPE - 1,10} = RANGE ;

    end
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
                end
            end
            
        end
        
    end
    
    disp([TEST,IND_OFFSET,IND_LEVEL,IND_RANGE,IND_PYRAMIDS]);

    
end