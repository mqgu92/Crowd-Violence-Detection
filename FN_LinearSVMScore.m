function [classification]= FN_LinearSVMScore( DATA,DATA_GROUP,DATA_TAGS,...
DATA2,DATA_GROUP2,DATA_TAGS2)

% Perform Classification
[~,LINEAR_SVM] = ...
    FN_CrossValidationTesting( DATA,DATA_GROUP,DATA_TAGS,true,false );

AnswersNumeric = cell2mat(LINEAR_SVM{6});
Classes =  LINEAR_SVM{7};
Answers = cell(length(AnswersNumeric),1);

Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

if length(unique(Classes)) == 1
    classification = 0;
    return;
end


%[~,~,~,classification] = perfcurve( Answers ,  cell2mat(LINEAR_SVM{3}),'Abnormal Crowds' );

%classification = classification * length(AnswersNumeric);
%classification = (classification * mean(LINEAR_SVM{2}))/2* length(DATA_TAGS);
%disp(['Classification Value: ',num2str(classification)]);
classification = sum (cell2mat(LINEAR_SVM{5})-1);

end

