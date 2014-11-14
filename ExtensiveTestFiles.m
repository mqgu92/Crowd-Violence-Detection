
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
    
    load(fullfile(FolderLocation,'TestOutput.mat'));
    
       %% TREE DATA
    TREEClassificationPerf = cell(1,FOLD);
    TREEFinalDecision = cell(1,FOLD);
    TREEAccuracy = cell(1,FOLD);
    TREEProbability = cell(1,FOLD);
    TREEActualAnswer = cell(1,FOLD);
    TREEVocab = cell(1,FOLD);
    TREETrainingModel = cell(1,FOLD);
    TREEROC = cell(FOLD,3);
    
    GLCMSIZE = size(GLCMNonPCADescriptors);
    MeanData = [1:2:GLCMSIZE(2)];
    VarianceData = [2:2:GLCMSIZE(2)];
    [G GN] = grp2idx(GLCMTags);  % Reduce character tags to numeric grouping
    
    for TESTTYPE = 1: 6
        
        switch TESTTYPE
            case 1
                FinalDescriptor = cell2mat(PerformPCA(GLCMNonPCADescriptors,PCA));
            case 2
                
                FinalDescriptor = cell2mat(PerformPCA(GLCMNonPCADescriptors(:,MeanData),PCA));
            case 3
                FinalDescriptor = cell2mat(PerformPCA(GLCMNonPCADescriptors(:,VarianceData),PCA));
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

    
    GLOBALOUTPUT{TEST + TESTTYPE - 1,1} = mean([TREEAccuracy{:}]);
    GLOBALOUTPUT{TEST + TESTTYPE - 1,2} = TREEAUC;
    GLOBALOUTPUT{TEST + TESTTYPE - 1,3} = [TREEX,TREEY];
    
%     GLOBALOUTPUT{TEST + TESTTYPE - 1,4} = mean([LINAccuracy{:}]);
%     GLOBALOUTPUT{TEST + TESTTYPE - 1,5} = LINAUC;
%     GLOBALOUTPUT{TEST + TESTTYPE - 1,6} = [X,Y];
    
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