%
%  SetupVariables;
  DATA_VIDEO_CHOSENSET = DATA_VIDEO_VF;
%  
  VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

BACKGROUNDTYPE = 1;

%% CHOOSE DATASET
%DATA_VIDEO_CHOSENSET = DATA_VIDEO_UFC;
WORDSSET = {4000};
SUBSET_SIZE = 200000;
BASEOFFSETS = {[1 0;-1 0;0 1;0 -1]};
LEVELSET = {64};
PYRAMIDS = {[8 8]};
RANGES = {[1 2]};
WINDOWSPLITS = {1 2 3 4 5 6};
WINDOWSIZES = {9999};
PCA = true;
DATA = DATA_VIDEO_CHOSENSET.name;
FOLD = DATA_VIDEO_CHOSENSET.fold;

IND_WORDS = 1;
IND_WINDOW = 1;
IND_OFFSET = 1;
IND_LEVEL = 1;
IND_PYRAMIDS = 1;
IND_RANGE = 1;
IND_WINDOWSPLIT = 1;
WINDOWSKIP = 1;    % Window between sample extraction

%WINDOWSIZE = 25;        % Length of temporal window for descriptor extraction



TESTNUMBER = length(BASEOFFSETS) * length(LEVELSET) * length(PYRAMIDS) *...
    length(RANGES) * length(WINDOWSPLITS) * length(WINDOWSIZES) * length(WORDSSET);

% Accuracy, ROC, ROC PLOT , One for Frest, One for SVM
GLOBALOUTPUT =  cell(TESTNUMBER,12);
% TESTNUMBER * 6, 1 TEST ALL FEATURES, ANOTHER JUST MOTION, ANOTHER JUST
% VISUAL and a variant with and without PCA

for TEST = 1 :TESTNUMBER
    
    WINDOWSIZE = WINDOWSIZES{IND_WINDOW};
    BASEOFFSET = BASEOFFSETS{IND_OFFSET};
    LEVELS = LEVELSET{IND_LEVEL};
    PYRAMID = PYRAMIDS{IND_PYRAMIDS};
    RANGE = RANGES{IND_RANGE};
    WINDOWSPLIT = WINDOWSPLITS{IND_WINDOWSPLIT};
    SYMMETRY = false;   % ALWAYS FALSE
    WORDS = WORDSSET{IND_WORDS};
    IMRESIZE = 1;
    PYRSIZE = size(PYRAMID);
    
    FRAMERESIZE = IMRESIZE;
    
    Param_GLCM = struct('baseoffsets',BASEOFFSET,...
        'graylevel',LEVELS,...
        'pyramid',PYRAMID,...
        'range',RANGE);
    
    
    Param_EdgeCardinality = Param_EdgeCardinality_Default;
    
    Param_PixelDifference =  Param_PixelDifference_Default;
    
    
    
    [GEPNonPCADescriptors,GEPPCADescriptors,GEPTags,GEPFlowList,GEPGroup]...
        = FN_GEPDescriptor(VideoList,...
        DATA_VIDEO_CHOSENSET,...
        Param_GLCM,...
        Param_EdgeCardinality,...
        Param_PixelDifference,...
        WINDOWSIZE,...
        WINDOWSKIP,...
        WINDOWSPLIT,...
        IMRESIZE,BACKGROUNDTYPE);
    
    [G GN] = grp2idx(GEPTags);  % Reduce character tags to numeric grouping
    
    % Non-BagofWords Classification
%    [RAND_FOREST,LINEAR_SVM] = ...
%        FN_CrossValidationTesting( GEPNonPCADescriptors,GEPGroup,GEPTags,true,true );
[RAND_FOREST,LINEAR_SVM] = ...
    FN_CrossValidationTestingBoW( GEPNonPCADescriptors,...
    GEPGroup,...
    GEPTags,...
    true,...
    true,...
    Param_GLCM,WORDS,SUBSET_SIZE,WINDOWSPLIT);


    
    RandomForest_Confusion              =       RAND_FOREST{1};
    RandomForest_Accuracy               =       RAND_FOREST{2};
    RandomForest_Probablity_estimates   =       RAND_FOREST{3};
    RandomForest_Training_model         =       RAND_FOREST{4};
    RandomForest_Final_decision         =       RAND_FOREST{5};
    RandomForest_Actual_answer          =       RAND_FOREST{6};
    
    LinearSVM_Confusion                 =       LINEAR_SVM{1};
    LinearSVM_Accuracy                  =       LINEAR_SVM{2};
    LinearSVM_Probablity_estimates      =       LINEAR_SVM{3};
    LinearSVM_Training_model            =       LINEAR_SVM{4};
    LinearSVM_Final_decision            =       LINEAR_SVM{5};
    LinearSVM_Actual_answer             =       LINEAR_SVM{6};
    %% Compute Basic Stats such as accuracy and ROC classification
    
    % Compute the ROC curve of the Random Forest Model
    AnswersNumeric = cell2mat(reshape(RandomForest_Actual_answer,FOLD,1));
    Classes =  GN; Answers = cell(length(AnswersNumeric),1);
    Answers(AnswersNumeric == 1) = Classes(1); Answers(AnswersNumeric == 2) = Classes(2);
    
    if length(unique(AnswersNumeric)) >= 2
        TreeProb = cell2mat(reshape(RandomForest_Probablity_estimates,FOLD,1)); TreeProb = TreeProb(:,1);
        [RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,'Abnormal');
        GLOBALOUTPUT{TEST ,1} = mean(RandomForest_Accuracy);
        GLOBALOUTPUT{TEST ,2} = RF_AUC;
        GLOBALOUTPUT{TEST ,3} = [RF_X,RF_Y];
    end
    
    % Compute the ROC curve of the Linear SVM Model  
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
    GLOBALOUTPUT{TEST ,11} = WINDOWSIZE;
    GLOBALOUTPUT{TEST ,12} = WINDOWSPLIT;
    GLOBALOUTPUT{TEST ,13} = WORDS;
    
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
                            
                            IND_WORDS = IND_WORDS + 1;
                            if mod(IND_WORDS,length(WORDSSET) + 1) == 0
                                IND_WORDS = 1;
                            end
                        end
                    end
                end
            end
            
        end
        
    end
    
    disp([TEST,IND_OFFSET,IND_LEVEL,IND_RANGE,IND_PYRAMIDS,IND_WINDOW]);
    
    
end