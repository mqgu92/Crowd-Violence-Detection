Confusion = RAND_FOREST{1};
Confusion = sum(cat(3,Confusion{:}),3)

ColSum = sum(Confusion,1);
outMat = bsxfun (@rdivide, Confusion, ColSum)
%outMat = round(outMat.* 100)
Accuracy = trace(outMat) /  length(outMat)

Classes = RAND_FOREST{7}
