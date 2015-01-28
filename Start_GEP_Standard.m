SetupVariables;

DATA_VIDEO_CHOSENSET = DATA_VIDEO_CVDALL;

VideoList = FN_PopulateStandardList(DATA_VIDEO_CHOSENSET.dir,DATA_VIDEO_CHOSENSET.fold);

Param_GLCM = Param_GLCM_Default;

Param_GLCM = struct('baseoffsets',[1 0;-1 0;0 1;0 -1],...
    'graylevel',64,...
    'pyramid',[4 4],...
    'range',[1 2]);

% Param_GLCM = struct('baseoffsets', [1,1;0,1;1,0;1,-1;-1,1;-1,-1;0,-1;-1,0],...
%     'graylevel',54,...
%     'pyramid',[1 1],...
%     'range',[1 2 4 8]);

Param_EdgeCardinality = Param_EdgeCardinality_Default;

Param_PixelDifference=  Param_PixelDifference_Default;

WindowSize = 6;
WindowSkip = 1;
WindowSplit = 3;
ImageResize = 1;

% Extract Descriptors
[GEPNonPCADescriptors,GEPPCADescriptors,GEPTags,GEPFlowList,GEPGroup]...
    = FN_GEPDescriptor(VideoList,...
    DATA_VIDEO_CHOSENSET,...
    Param_GLCM,...
    Param_EdgeCardinality,...
    Param_PixelDifference,...
    WindowSize,...
    WindowSkip,...
    WindowSplit,...
    ImageResize);

% Perform Classification
[RAND_FOREST,LINEAR_SVM] = ...
    FN_CrossValidationTesting( GEPNonPCADescriptors,GEPGroup,GEPTags,true,true );




FN_SingleVideoTesting( LINEAR_SVM{4}, RAND_FOREST{4}, STANDData )



AnswersNumeric = cell2mat(RAND_FOREST{6});
Classes =  RAND_FOREST{7};
Answers = cell(length(AnswersNumeric),1);
Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

TreeProb = cell2mat(RAND_FOREST{3}); TreeProb = TreeProb(:,1);
[RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,'Abnormal');
[X,Y,T,LINAUC] = perfcurve(Answers ,  cell2mat(LINEAR_SVM{3}) ,'Abnormal' );
figure, plot(RF_X,RF_Y); hold on
plot(X,Y);

title(['ROC Classification ',DATA_VIDEO_CHOSENSET.name]);
legend(['Random Forest : ',num2str(RF_AUC)],['Linear SVM : ',num2str(LINAUC)]);    
mean(RAND_FOREST{2})
mean(LINEAR_SVM{2})
