function FN_TreeBaggerAnalysis( DATA,DATA_TAGS,DATA_GROUPS,NUMBER_OF_TREES )

%Obtain a random sample
sampleLimit = 2000;
randIdx = randperm(length(DATA));
DATA = DATA(randIdx(1:sampleLimit),:);
DATA_TAGS = DATA_TAGS(randIdx(1:sampleLimit),:);
DATA_GROUPS = DATA_GROUPS(randIdx(1:sampleLimit),:);

[G GN] = grp2idx(DATA_TAGS);  % Reduce character tags to numeric grouping

Training_model = TreeBagger(NUMBER_OF_TREES,...
    DATA,...
    G,...
    'Method', 'classification',...
    'OOBVarImp','on',...
    'OOBPred','on',...
    'NPrint',1);


figure
plot(oobError(Training_model));
xlabel 'Number of Grown Trees';
ylabel 'Out-of-Bag Mean Squared Error';


figure
bar(Training_model.OOBPermutedVarDeltaError);
xlabel 'Feature Number' ;
ylabel 'Out-of-Bag Feature Importance';
idxvar = find(Training_model.OOBPermutedVarDeltaError>0.7)


b5v = TreeBagger(NUMBER_OF_TREES,DATA(:,idxvar),G,'Method','classification',...
    'OOBVarImp','On');
figure
plot(oobError(b5v));
xlabel 'Number of Grown Trees';
ylabel 'Out-of-Bag Mean Squared Error';
figure
 bar(b5v.OOBPermutedVarDeltaError);
 xlabel 'Feature Index';
 ylabel 'Out-of-Bag Feature Importance';
% 
%   Perform PCA and Plot
%


b5v = fillProximities(b5v);
[~,e] = mdsProx(b5v,'Colors','rb');
xlabel 'First Scaled Coordinate';
ylabel 'Second Scaled Coordinate';
figure, bar(e(1:20))
UniqueClasses =length(unique(DATA_TAGS));
ScatterColorMap = colormap(lines(UniqueClasses));
[PCAData,e] = PerformPCA(DATA);
PCAData = PCAData{:};
PCADataSize = size(PCAData);

if PCADataSize(2) == 1
    figure, gscatter(PCAData(:,1),...
        zeros(PCADataSize(1),1),...
        [DATA_GROUPS{:}],...
        ScatterColorMap(1:UniqueClasses,:));
else
    figure, gscatter(PCAData(:,1),...
        PCAData(:,2),...
        [DATA_GROUPS{:}],...
        ScatterColorMap(1:UniqueClasses,:));
end


figure, bar(e)


end

