function [OUTPUT] = ML_SplitData( DATA , VARIATION , TRAINPERC, FOLDS )
%ML_SPLITDATA 
%
%   Split data into two parts, training and testing
%      
%   DATA will consist of a list of video names from which features
%   are extracted from; this function will split data into training 
%   and testing sets
%
%
%   If variation is true then all data will be split regardless of
%   video
%
%   DATA = {Video Name, Class Name, Disorderly/Non-disorderly}
%   TRAIN = Specific video for TRAINING only
%   TEST = Specific video for TESTING only
%   TRAINPERC = Percentage of videos used for training
%
%
%   OUTPUT = 1x5, FOLD , Training,Test,label ind, labels
%
%   Only data indexs are turned, not actual data
%
%%%%%%%

OUTPUT = cell(FOLDS,3);
ClassList = DATA(:,3);

if VARIATION
    %Perform Standard Cross Validation across entire set
    disp('Using Standard Cross Validation');
    [g gn] = grp2idx(ClassList);               

    cvFolds = cvpartition(g,'Kfold', FOLDS);   
    
    for i = 1 : FOLDS
        OUTPUT{i,1} = i;
        OUTPUT{i,2} = cvFolds.training(i);
        OUTPUT{i,3} = cvFolds.test(i);
        OUTPUT{i,4} = g;
        OUTPUT{i,5} = gn;
        
    end
    
    return;
end


%% Step 2: Identify unique scenes

%Perform cross validation across entire set without duplicates
D = cell(length(DATA),1);

for i = 1 : length(DATA)
    D{i} = [DATA{i,1:3}];
end
 
[grpD, gn] = grp2idx( D(:,1) );    

%% Obtain indexes of fight and non fight in grpD
NF = strfind(gn, 'NFight') ;
indNF = find(~cellfun(@isempty,NF));
indF = find(cellfun(@isempty,NF));

if length(indNF) > 3 && length(indF) > 3 
    [g gn] = grp2idx(ClassList);    
    for i = 1 : FOLDS
    
        % Not enough unique data, use cross validation
        randF =indF(randperm(length(indF)));
        randNF =indNF(randperm(length(indNF)));

        indF = floor(length(randF) * TRAINPERC);
        indNF = floor(length(randNF) * TRAINPERC);


        TrainFInd = (ismember(grpD,randF(1:indF)));
        TrainNFInd = (ismember(grpD,randNF(1:indNF)));
        TestFInd = (ismember(grpD,randF(indF + 1 :end)));
        TestNFInd = (ismember(grpD,randNF(indNF + 1 :end)));

        TrainInd = TrainFInd + TrainNFInd;
        TestInd = TestFInd + TestNFInd;
    
        OUTPUT{i,1} = i;
        OUTPUT{i,2} = TrainInd;
        OUTPUT{i,3} = TestInd;
        OUTPUT{i,4} = g;
        OUTPUT{i,5} = gn;
    end
else
    %Use standard crossvalidation
    OUTPUT = ML_SplitData( DATA , true , TRAINPERC, FOLDS );
end





end

