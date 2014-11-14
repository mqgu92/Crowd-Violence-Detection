function [RAND_FOREST,LINEAR_SVM] = FN_CrossValidationTestingBoW( DATA,DATA_GROUP,DATA_TAGS,USE_LINEAR_SVM,USE_RANDOM_FOREST,Param_GLCM,WORDS,SUBSET_SIZE )
global RANDOM_FOREST_VERBOSE;
global RANDOM_FOREST_TREES;
global RANDOM_FOREST_VERBOSE_MODEL;
global LINEAR_SVM_VERBOSE;

if isempty(LINEAR_SVM_VERBOSE)
    LINEAR_SVM_VERBOSE = false;
end

if isempty(RANDOM_FOREST_VERBOSE_MODEL)
    RANDOM_FOREST_VERBOSE_MODEL = false;
end

if isempty(RANDOM_FOREST_VERBOSE)
    RANDOM_FOREST_VERBOSE = false;
end

if isempty(RANDOM_FOREST_TREES)
    RANDOM_FOREST_TREES = 50;
end

Folds = max(cell2mat(DATA_GROUP));
DataSplit = cell(Folds,5);

RandomForest_Confusion            = cell(Folds,1);
RandomForest_Accuracy             = zeros(Folds,1);
RandomForest_Probablity_estimates = cell(Folds,1);
RandomForest_Training_model       = cell(Folds,1);
RandomForest_Final_decision       = cell(Folds,1);
RandomForest_Actual_answer        = cell(Folds,1);
RandomForest_Vocabulary        = cell(Folds,1);

LinearSVM_Confusion            = cell(Folds,1);
LinearSVM_Accuracy             = zeros(Folds,1);
LinearSVM_Probablity_estimates = cell(Folds,1);
LinearSVM_Training_model       = cell(Folds,1);
LinearSVM_Final_decision       = cell(Folds,1);
LinearSVM_Actual_answer        = cell(Folds,1);
LinearSVM_Vocabulary        = cell(Folds,1);

[G GN] = grp2idx(DATA_TAGS);  % Reduce character tags to numeric grouping

for k = 1: Folds
    disp(['Starting Test ',num2str(k)]);
    testData = find([DATA_GROUP{:}]'== k);
    TESTIDX = false(length(DATA_GROUP),1);
    TESTIDX(testData) = true;
    TRAINIDX = ~TESTIDX;
    
    % Save group assignments into a
    DataSplit{k,1} = k;
    DataSplit{k,2} = TRAINIDX;
    DataSplit{k,3} = TESTIDX;
    DataSplit{k,4} = G;
    DataSplit{k,5} = GN;
    
    %Generate Vocobulary from Training Data
    
    UnFormattedData = FN_ReformalizeDescriptorFromStructure( DATA, Param_GLCM.pyramid,8 );
    TRAINData = FN_ReformalizeDescriptorFromStructure( DATA(TRAINIDX,:), Param_GLCM.pyramid,8 );
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

    % Reformalulate back into a Structure
   % DATA = FN_ReformalizeDescriptorToStructure( WordRepresentation, Param_GLCM.pyramid,WORDS );

    
    
    if USE_LINEAR_SVM
    %% TEST USING LINEAR SVM

        LinearSVM_Vocabulary{k} = VOCAB;
        
        if length(GN) > 2
                [ LinearSVM_Confusion{k},...
            LinearSVM_Accuracy(k),...
            LinearSVM_Probablity_estimates{k},...
            LinearSVM_Training_model{k},...
            LinearSVM_Final_decision{k},...
            LinearSVM_Actual_answer{k} ]...
            = ML_MultiClassLibLinearSVM(REFORMALIZEDDATA ,TESTIDX,TRAINIDX,G,GN,LINEAR_SVM_VERBOSE );
        else
                [ LinearSVM_Confusion{k},...
            LinearSVM_Accuracy(k),...
            LinearSVM_Probablity_estimates{k},...
            LinearSVM_Training_model{k},...
            LinearSVM_Final_decision{k},...
            LinearSVM_Actual_answer{k} ]...
            = ML_TwoClassLibLinearSVM(REFORMALIZEDDATA ,TESTIDX,TRAINIDX,G,GN,LINEAR_SVM_VERBOSE );
        end
        
    end
    
    if USE_RANDOM_FOREST
    %% TEST RANDOM FOREST
    [RandomForest_Confusion{k},...
        RandomForest_Accuracy(k),...
        RandomForest_Probablity_estimates{k},...
        RandomForest_Training_model{k},...
        RandomForest_Final_decision{k},...
        RandomForest_Actual_answer{k} ] = ML_TwoClassForest(REFORMALIZEDDATA,...
        TESTIDX,...
        TRAINIDX,...
        G,...
        GN,...
        RANDOM_FOREST_TREES,...
        RANDOM_FOREST_VERBOSE,...
        RANDOM_FOREST_VERBOSE_MODEL);
        RandomForest_Vocabulary{k} = VOCAB;
    end
end

RAND_FOREST = cell(7,1);
LINEAR_SVM = cell(7,1);
if USE_RANDOM_FOREST
RAND_FOREST{1}  =   RandomForest_Confusion;
RAND_FOREST{2}  =   RandomForest_Accuracy;
RAND_FOREST{3}  =   RandomForest_Probablity_estimates;
RAND_FOREST{4}  =   RandomForest_Training_model;
RAND_FOREST{5}  =   RandomForest_Final_decision;
RAND_FOREST{6}  =   RandomForest_Actual_answer;
RAND_FOREST{7}  =   GN;
RAND_FOREST{8}  =   RandomForest_Vocabulary;
end
if USE_LINEAR_SVM
LINEAR_SVM{1}   =   LinearSVM_Confusion;
LINEAR_SVM{2}   =   LinearSVM_Accuracy;
LINEAR_SVM{3}   =   LinearSVM_Probablity_estimates;
LINEAR_SVM{4}   =   LinearSVM_Training_model;
LINEAR_SVM{5}   =   LinearSVM_Final_decision;
LINEAR_SVM{6}   =   LinearSVM_Actual_answer;
LINEAR_SVM{7}   =   GN;
LINEAR_SVM{8}   =   LinearSVM_Vocabulary;
end

end

