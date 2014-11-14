SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_KTH;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,2);

Param_GLCM = Param_GLCM_Default;
Param_GLCM = struct('baseoffsets',[1 0; -1 0; 0 1;0 -1],...
    'graylevel',64,...
    'pyramid',[1 1; 3 3; 7 7],...
    'range',[1]);
Param_EdgeCardinality = Param_EdgeCardinality_Default;

Param_PixelDifference=  Param_PixelDifference_Default;

WindowSize = 24;
WindowSkip = 12;
ImageResize = 0.5;

% Extract Descriptors
[GEPNonPCADescriptors,GEPDescriptors,GEPTags,GEPFlowList,GEPGroup]...
    = FN_GEPDescriptorModified(VideoList,...
    DATA_VIDEO_CHOSENSET,...
    Param_GLCM,...
    Param_EdgeCardinality,...
    Param_PixelDifference,...
    WindowSize,...
    WindowSkip,...
    ImageResize);

% Perform Classification
[RANDOM_FOREST,LINEAR_SVM] = ...
    FN_CrossValidationTesting( GEPDescriptors,GEPGroup,GEPTags,true,true );

% Get ROC Curve
AnswersNumeric = cell2mat(LINEAR_SVM{6});
Classes =  LINEAR_SVM{7};
Answers = cell(length(AnswersNumeric),1);
Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

[LIN_SVM_X,LIN_SVM_Y,~,LIN_SVM_AUC] = perfcurve( Answers ,  cell2mat(LINEAR_SVM{3}),'Abnormal Crowds' );

figure, plot(LIN_SVM_X,LIN_SVM_Y);
title('ROC before and after feature selection');
legend(['Linear SVM : ',num2str(LIN_SVM_AUC)]);

TreeProb = cell2mat(RANDOM_FOREST{3}); TreeProb = TreeProb(:,1);
[RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,'Abnormal Crowds');

figure, plot(RF_X,RF_Y);
title('ROC before and after feature selection');
legend(['Random Forest : ',num2str(RF_AUC)]);


