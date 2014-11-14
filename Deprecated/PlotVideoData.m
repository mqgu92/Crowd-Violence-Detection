% Assuming a VideoList and Descriptors are present!
% Var - VideoList   Var - GLCMNonPCADescriptors Var - GLCMDescriptors

% 1 = EDGE, 2 EDGE VARIANCE 3 = DIFFERENCE, 4 DIFFERENCE VARIANCE, 
% 5 = ENERGY, 6 = ENERYGY VARIANCE, 7 = CONTRAST, 8 = CONTRAST VARIANCE

DISPLAYDATA = 8;

%% Plot Video Visual Texture Similairty
Colours = {'g','r','b','c','y'};

figure 
%Create Class Divide
[G GN] = grp2idx(GLCMTags);  % Reduce character tags to numeric grouping
ClassCount = size(unique(GN));

previousData = 0;
lineMean = [];
for i = 1: ClassCount
    data = [zeros(previousData,1);GLCMNonPCADescriptors(G == i,DISPLAYDATA)];
    dataMean = mean(data); lineMean = [lineMean,ones(1,length(data))*dataMean];
    bar(data,Colours{i},'EdgeColor',Colours{i});
    hold on;
    previousData = length(data);
end

plot(lineMean);
