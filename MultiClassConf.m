Confusion = LINEAR_SVM{1};
Confusion = sum(cat(3,Confusion{:}),3);

ColSum = sum(Confusion,1);
outMat = bsxfun (@rdivide, Confusion, ColSum);
outMat = round(outMat.* 100);
Accuracy = trace(outMat) /  length(outMat);

Classes = LINEAR_SVM{7};

%for i = 1: length(outMat)
%    disp(sprintf([Classes{i}, '\t\t\t\t', num2str(outMat(i,:))]));
%end

%confusionmat(cell2mat(LINEAR_SVM{5}), cell2mat(LINEAR_SVM{6}))
Classes

