%% PCA Vs NonPCA
% 1 = Non PCA
% 2 = Non PCA Static Data
% 3 = Non PCA Motion Data
% 4 = PCA
% 5 = PCA Static Data
% 6 = PCA Motion Data
TITLE = 'CVD';

clear max ind;
DATASIZE =  size(GLOBALOUTPUT);

DATA_STANDARD = GLOBALOUTPUT(1:6:DATASIZE(1),:);
DATA_STATIC = GLOBALOUTPUT(2:6:DATASIZE(1),:);
DATA_MOTION = GLOBALOUTPUT(3:6:DATASIZE(1),:);

DATA_PCA_STANDARD = GLOBALOUTPUT(4:6:DATASIZE(1),:);
DATA_PCA_STATIC = GLOBALOUTPUT(5:6:DATASIZE(1),:);
DATA_PCA_MOTION = GLOBALOUTPUT(6:6:DATASIZE(1),:);

% Find Best AUC Results
[~,RFIND] = max([DATA_PCA_STANDARD{:,2}]);
DATA_PCA_STANDARD_SVM_ROC = DATA_PCA_STANDARD{RFIND,3};
DATA_PCA_STANDARD_SVM_ROC_VALUE = DATA_PCA_STANDARD{RFIND,2};
X_PCA_STANDARD = DATA_PCA_STANDARD_SVM_ROC(:,1);
Y_PCA_STANDARD = DATA_PCA_STANDARD_SVM_ROC(:,2);

[~,RFIND] = max([DATA_PCA_STATIC{:,2}]);
DATA_PCA_STATIC_SVM_ROC = DATA_PCA_STATIC{RFIND,3};
DATA_PCA_STATIC_SVM_ROC_VALUE = DATA_PCA_STATIC{RFIND,2};
X_PCA_STATIC = DATA_PCA_STATIC_SVM_ROC(:,1);
Y_PCA_STATIC = DATA_PCA_STATIC_SVM_ROC(:,2);


[~,RFIND] = max([DATA_PCA_MOTION{:,2}]);
DATA_PCA_MOTION_SVM_ROC = DATA_PCA_MOTION{RFIND,3};
DATA_PCA_MOTION_SVM_ROC_VALUE = DATA_PCA_MOTION{RFIND,2};
X_PCA_MOTION = DATA_PCA_MOTION_SVM_ROC(:,1);
Y_PCA_MOTION = DATA_PCA_MOTION_SVM_ROC(:,2);
plot(X_PCA_STANDARD,Y_PCA_STANDARD,X_PCA_STATIC,Y_PCA_STATIC,X_PCA_MOTION,Y_PCA_MOTION);

title('DATA: PCA, ROC Comparisons');
legend(['ALL: ROC = ',num2str(DATA_PCA_STANDARD_SVM_ROC_VALUE)],...
   ['FEATURE MEAN: ROC = ',num2str(DATA_PCA_STATIC_SVM_ROC_VALUE)],...
   ['FEATURE VARIANCE: ROC = ',num2str(DATA_PCA_MOTION_SVM_ROC_VALUE)]);

[~,RFIND] = max([DATA_STANDARD{:,2}]);
DATA_STANDARD_SVM_ROC = DATA_STANDARD{RFIND,3};
DATA_STANDARD_SVM_ROC_VALUE = DATA_STANDARD{RFIND,2};
X_STANDARD = DATA_STANDARD_SVM_ROC(:,1);
Y_STANDARD = DATA_STANDARD_SVM_ROC(:,2);

[~,RFIND] = max([DATA_STATIC{:,2}]);
DATA_STATIC_SVM_ROC = DATA_STATIC{RFIND,3};
DATA_STATIC_SVM_ROC_VALUE = DATA_STATIC{RFIND,2};
X_STATIC = DATA_STATIC_SVM_ROC(:,1);
Y_STATIC = DATA_STATIC_SVM_ROC(:,2);


[~,RFIND] = max([DATA_MOTION{:,2}]);
DATA_MOTION_SVM_ROC = DATA_MOTION{RFIND,3};
DATA_MOTION_SVM_ROC_VALUE = DATA_MOTION{RFIND,2};
X_MOTION = DATA_MOTION_SVM_ROC(:,1);
Y_MOTION = DATA_MOTION_SVM_ROC(:,2);
figure,plot(X_STANDARD,Y_STANDARD,X_STATIC,Y_STATIC,':',X_MOTION,Y_MOTION,'--');

title('DATA: NON-PCA, ROC Comparisons');
legend(['ALL: ROC = ',num2str(DATA_STANDARD_SVM_ROC_VALUE)],...
   ['FEATURE MEAN: ROC = ',num2str(DATA_STATIC_SVM_ROC_VALUE)],...
   ['FEATURE VARIANCE: ROC = ',num2str(DATA_MOTION_SVM_ROC_VALUE)]);



figure, plot(1:length([DATA_PCA_STANDARD{:,1}]),...
    [DATA_PCA_STANDARD{:,1}],...
    1:length([DATA_PCA_STATIC{:,1}]),[DATA_PCA_STATIC{:,1}],...
    1:length([DATA_PCA_MOTION{:,1}]),[DATA_PCA_MOTION{:,1}]);

title('Comparison of Accuracy with PCA');
legend('ALL',...
   'FEATURE MEAN',...
   'FEATURE VARIANCE:');


figure, plot(1:length([DATA_STANDARD{:,1}]),...
    [DATA_STANDARD{:,1}],...
    1:length([DATA_STATIC{:,1}]),[DATA_STATIC{:,1}],...
    1:length([DATA_MOTION{:,1}]),[DATA_MOTION{:,1}]);


title('Comparison of Accuracy without PCA');
legend('ALL',...
   'STATIC',...
   'MOTION');

figure, plot(1:length([DATA_PCA_STANDARD{:,2}]),...
    [DATA_PCA_STANDARD{:,2}],...
    1:length([DATA_PCA_STATIC{:,2}]),[DATA_PCA_STATIC{:,2}],...
    1:length([DATA_PCA_MOTION{:,2}]),[DATA_PCA_MOTION{:,2}]);

title('Comparison of ROC with PCA');
legend('ALL',...
   'STATIC',...
   'MOTION');


figure, plot(1:length([DATA_STANDARD{:,2}]),...
    [DATA_STANDARD{:,2}],...
    1:length([DATA_STATIC{:,2}]),[DATA_STATIC{:,2}],...
    1:length([DATA_MOTION{:,2}]),[DATA_MOTION{:,2}]);


title('Comparison of ROC without PCA');
legend('ALL',...
   'STATIC',...
   'MOTION');


figure, plot(1:length([DATA_STANDARD{:,2}]),...
    [DATA_STANDARD{:,2}],...
    1:length([DATA_PCA_STANDARD{:,2}]),[DATA_PCA_STANDARD{:,2}]);


title('PCA vs Non PCA ALL');
legend('Non PCA','PCA');
%% Evaluation of Pyramids
% Get Data by Pyramid Size

KnownPyr = {};
PlotData = cell(20,1);
DATA = DATA_PCA_STANDARD;

for p = 1: length(DATA)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(DATA{p,9}, KnownPyr{k})
            known = true;
            PlotData{k} = [PlotData{k};DATA{p,1}];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; DATA{p,9}];
        PlotData{length(KnownPyr)} = [PlotData{length(KnownPyr)};DATA{p,1}];
    end
end
figure;
PlotData = PlotData(~cellfun('isempty',PlotData)) ; 
col=hsv(length(PlotData));
for p = 1:length(PlotData)
    plot([1:length(PlotData{p})],PlotData{p},'color',col(p,:)); hold on;
end

title('Comparisons of Spatial Pyramids');
LegendString = cell(length(KnownPyr),1);
for k = 1: length(KnownPyr)
    LegendString{k} = num2str(KnownPyr{k});
end

legend(LegendString);

%% Evaluation of Grey Levels
% Get Data by Pyramid Size

KnownPyr = {};
PlotData = cell(20,1);

for p = 1: length(DATA)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(DATA{p,8}, KnownPyr{k})
            known = true;
            PlotData{k} = [PlotData{k};DATA{p,1}];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; DATA{p,8}];
        PlotData{length(KnownPyr)} = [PlotData{length(KnownPyr)};DATA{p,1}];
    end
end
figure;
PlotData = PlotData(~cellfun('isempty',PlotData)) ; 
col=hsv(length(PlotData));
for p = 1:length(PlotData)
    plot([1:length(PlotData{p})],PlotData{p},'color',col(p,:)); hold on;
end

title('Comparisons of Grey Levels');
LegendString = cell(length(KnownPyr),1);
for k = 1: length(KnownPyr)
    LegendString{k} = num2str(KnownPyr{k});
end

legend(LegendString);

%% Evaluation of TExture Range
% Get Data by Pyramid Size

KnownPyr = {};
PlotData = cell(20,1);

for p = 1: length(DATA)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(DATA{p,10}, KnownPyr{k})
            known = true;
            PlotData{k} = [PlotData{k};DATA{p,1}];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; DATA{p,10}];
        PlotData{length(KnownPyr)} = [PlotData{length(KnownPyr)};DATA{p,1}];
    end
end
figure;
PlotData = PlotData(~cellfun('isempty',PlotData)) ; 
col=hsv(length(PlotData));
for p = 1:length(PlotData)
    plot([1:length(PlotData{p})],PlotData{p},'color',col(p,:)); hold on;
end

title('Comparisons of Texture Range');
LegendString = cell(length(KnownPyr),1);
for k = 1: length(KnownPyr)
    LegendString{k} = num2str(KnownPyr{k});
end

legend(LegendString);

%% Evaluation of TExture OFfsets
% Get Data by Pyramid Size

KnownPyr = {};
PlotData = cell(20,1);

for p = 1: length(DATA)
    known = false;
    for k = 1: length(KnownPyr)
        if isequal(DATA{p,7}, KnownPyr{k})
            known = true;
            PlotData{k} = [PlotData{k};DATA{p,1}];
        end
    end
    if ~known
        KnownPyr = [KnownPyr; DATA{p,7}];
        PlotData{length(KnownPyr)} = [PlotData{length(KnownPyr)};DATA{p,1}];
    end
end

figure;
PlotData = PlotData(~cellfun('isempty',PlotData)) ; 
col=hsv(length(PlotData));
for p = 1:length(PlotData)
    plot([1:length(PlotData{p})],PlotData{p},'color',col(p,:)); hold on;
end

title('Comparisons of Texture Offset');
LegendString = cell(length(KnownPyr),1);
for k = 1: length(KnownPyr)
    LegendString{k} = num2str(KnownPyr{k});
end

legend(LegendString);