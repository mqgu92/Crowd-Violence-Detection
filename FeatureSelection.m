%% Linear SVM
opts = statset('display','iter');
fun = @FN_LinearSVMScore;
[fs,history] = sequentialfs(fun,...
        GLCMNonPCADescriptors,GLCMGroup,GLCMTags,'cv','resubstitution',...
        'direction','backward','options',opts);
    
ReducedDescriptors = GLCMNonPCADescriptors(:,fs);

[~,LINEAR_SVM] = ...
    FN_CrossValidationTesting( ReducedDescriptors,GLCMGroup,GLCMTags,true,false );
[~,LINEAR_SVM_ORIG] = ...
    FN_CrossValidationTesting( GLCMNonPCADescriptors,GLCMGroup,GLCMTags,true,false );
% Generate Labels for Classification
AnswersNumeric = cell2mat(LINEAR_SVM{6});
Classes =  LINEAR_SVM{7};
Answers = cell(length(AnswersNumeric),1);
Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

[LIN_SVM_X,LIN_SVM_Y,~,LIN_SVM_AUC] = perfcurve( Answers ,  cell2mat(LINEAR_SVM{3}),'Abnormal Crowds' );
[LIN_SVM_ORIG_X,LIN_SVM_ORIG_Y,~,LIN_SVM_ORIG_AUC] = perfcurve( Answers ,  cell2mat(LINEAR_SVM_ORIG{3}),'Abnormal Crowds' );

figure, plot(LIN_SVM_X,LIN_SVM_Y,LIN_SVM_ORIG_X,LIN_SVM_ORIG_Y);
title('ROC before and after feature selection');
legend(['AFTER : ',num2str(LIN_SVM_AUC)],['BEFORE : ',num2str(LIN_SVM_ORIG_AUC)]);


%% Random Forest
opts = statset('display','iter');
fun = @FN_RandomForestScore;
[RANDOM_FOREST_fs,RANDOM_FOREST_history] = sequentialfs(fun,...
        GLCMNonPCADescriptors,GLCMGroup,GLCMTags,'cv','resubstitution',...
        'direction','backward','options',opts);


ReducedDescriptors = GLCMNonPCADescriptors(:,RANDOM_FOREST_fs);
[RANDOM_FOREST,~] = ...
    FN_CrossValidationTesting( ReducedDescriptors,GLCMGroup,GLCMTags,false,true );
[RANDOM_FOREST_ORIG,~] = ...
    FN_CrossValidationTesting( GLCMNonPCADescriptors,GLCMGroup,GLCMTags,false,true );
[RANDOM_FOREST_PCA,~] = ...
    FN_CrossValidationTesting( GLCMDescriptors,GLCMGroup,GLCMTags,false,true );

AnswersNumeric = cell2mat(RANDOM_FOREST{6});
Classes =  RANDOM_FOREST{7};
Answers = cell(length(AnswersNumeric),1);

Class = 'Abnormal Crowds' ;
Answers(AnswersNumeric == 1) = Classes(1); Answers(AnswersNumeric == 2) = Classes(2); 

TreeProb = cell2mat(RANDOM_FOREST{3}); TreeProb = TreeProb(:,1);
[RF_X,RF_Y,~,RF_AUC] = perfcurve( Answers , TreeProb ,Class);

TreeProb = cell2mat(RANDOM_FOREST_ORIG{3}); TreeProb = TreeProb(:,1);
[RF_ORIG_X,RF_ORIG_Y,~,RF_ORIG_AUC] = perfcurve( Answers , TreeProb ,Class);

TreeProb = cell2mat(RANDOM_FOREST_PCA{3}); TreeProb = TreeProb(:,1);
[RF_PCA_X,RF_PCA_Y,~,RF_PCA_AUC] = perfcurve( Answers , TreeProb ,Class);

figure, plot(RF_X,RF_Y,RF_ORIG_X,RF_ORIG_Y,RF_PCA_X,RF_PCA_Y);
title('ROC before and after feature selection');
legend(['AFTER : ',num2str(RF_AUC)],...
    ['BEFORE : ',num2str(RF_ORIG_AUC)],...
    ['PCA : ',num2str(RF_PCA_AUC)]);
