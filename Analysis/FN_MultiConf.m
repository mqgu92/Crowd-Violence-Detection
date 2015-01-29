function [ ConfusionMat,ConfusionMatScaled,Classes,Accuracy ] = FN_MultiConf( MODEL )
Confusion = MODEL{1};
Confusion = sum(cat(3,Confusion{:}),3);

ColSum = sum(Confusion,1);
ConfusionMatScaled = bsxfun (@rdivide, Confusion, ColSum);
ConfusionMatScaled = round(ConfusionMatScaled.* 100);
Accuracy = trace(ConfusionMatScaled) /  length(ConfusionMatScaled);

Classes = MODEL{7};
ConfusionMat = 1;
%ConfusionMat = confusionmat(cell2mat(MODEL{5}), cell2mat(MODEL{6}));


end

