function [ VidList ] = LoadDataSet( FlowsBase )
%%
% Provides a list of data samples with the following information 
%
% File location from Base Directory
%   Sub-Class : Defined Class Type
%   General Class : Loose Classe Type
%   Fold : Partition Value, used for k-fold testing
%   Data Name : The title of the sample
%
%   Example
%   {'Fight\1\Scuffle\QuickFight','Scuffle','Fight',1,'QuickFight';}
%
%
%   Sample list is generated by examening the directory 'FlowBase' data
%   must be saved in the following folder format
%
%   'General_Class\Fold\Sub-Class\Sample_Name'
%
%   A directory approach allows for easy data introduction and re-arranging
%%
VidList = {};


FlowDir = strcat(FlowsBase,'Fight\');

dirInfo = dir(FlowDir);
isub = [dirInfo(:).isdir]; %# returns logical vector
nameFolds = {dirInfo(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i = 1 : length(nameFolds)
   
    
    GROUP = nameFolds{i};
    
    innerDir = dir(strcat(FlowDir,GROUP));
    isub = [innerDir(:).isdir]; %# returns logical vector
    innerNameFolds = {innerDir(isub).name}';
    innerNameFolds(ismember(innerNameFolds,{'.','..'})) = [];
    
    fType = 'Fight';

    %Classes   
    for k = 1: length(innerNameFolds)
    
        innerInnerDir = dir(strcat(FlowDir,GROUP,'\',innerNameFolds{k}));
        Innerisub = [innerInnerDir(:).isdir]; %# returns logical vector
        innerInnerNameFolds = {innerInnerDir(Innerisub).name}';
        innerInnerNameFolds(ismember(innerInnerNameFolds,{'.','..'})) = [];
        class = innerNameFolds{k};
        
        
        % Files in Classes
        for j = 1 : length(innerInnerNameFolds)
            vidName = strcat('Fight\',GROUP,'\',class,'\',innerInnerNameFolds{j});
            VidList = [VidList;{vidName,class,fType,GROUP,innerInnerNameFolds(j)}];
        end
    end
end

%Step1: Get Fights
FlowDir = strcat(FlowsBase,'NotFight\');

dirInfo = dir(FlowDir);
isub = [dirInfo(:).isdir]; %# returns logical vector
nameFolds = {dirInfo(isub).name}';
nameFolds(ismember(nameFolds,{'.','..'})) = [];

for i = 1 : length(nameFolds)
   
    
    GROUP = nameFolds{i};
    
    innerDir = dir(strcat(FlowDir,GROUP));
    isub = [innerDir(:).isdir]; %# returns logical vector
    innerNameFolds = {innerDir(isub).name}';
    innerNameFolds(ismember(innerNameFolds,{'.','..'})) = [];
    
    fType = 'NotFight';

    %Classes   
    for k = 1: length(innerNameFolds)
    
        innerInnerDir = dir(strcat(FlowDir,GROUP,'\',innerNameFolds{k}));
        Innerisub = [innerInnerDir(:).isdir]; %# returns logical vector
        innerInnerNameFolds = {innerInnerDir(Innerisub).name}';
        innerInnerNameFolds(ismember(innerInnerNameFolds,{'.','..'})) = [];
        class = innerNameFolds{k};
        
        
        % Files in Classes
        for j = 1 : length(innerInnerNameFolds)
            vidName = strcat('NotFight\',GROUP,'\',class,'\',innerInnerNameFolds{j});
            VidList = [VidList;{vidName,class,fType,GROUP,innerInnerNameFolds{j}}];
        end
    end
end


end
