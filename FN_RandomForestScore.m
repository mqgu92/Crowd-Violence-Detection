function [classification]= FN_RandomForestScore( DATA,DATA_GROUP,DATA_TAGS,...
DATA2,DATA_GROUP2,DATA_TAGS2)

% Perform Classification
[RANDOM_FOREST,~] = ...
    FN_CrossValidationTesting( DATA,DATA_GROUP,DATA_TAGS,false,true);

AnswersNumeric = cell2mat(RANDOM_FOREST{6});
Classes =  RANDOM_FOREST{7};
Answers = cell(length(AnswersNumeric),1);

Answers(AnswersNumeric == 1) = Classes(1); 
Answers(AnswersNumeric == 2) = Classes(2); 

if length(unique(Classes)) == 1
    classification = 0;
    return;
end


%[~,~,~,classification] = perfcurve( Answers ,  cell2mat(RANDOM_FOREST{3}),'Abnormal Crowds' );

%classification = classification * length(AnswersNumeric);
%classification = (classification * mean(RANDOM_FOREST{2}))/2* length(DATA_TAGS);
%disp(['Classification Value: ',num2str(classification)]);
classification = sum (cell2mat(RANDOM_FOREST{5})-1);

end

