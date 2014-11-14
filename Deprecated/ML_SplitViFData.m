function [ OUTPUT ] = ML_SplitViFData( DATA )

OUTPUT = cell(5,3);
GroupList = [DATA{:,4}];

if ischar(GroupList(1))
GroupList = str2num(GroupList(:));
end

D = cell(length(DATA),1);

for i = 1 : length(DATA)
    D{i} = [DATA{i,3}];
end

 disp('Using ViF Cross Validation');
    [g gn] = grp2idx(D);               


    for i = 1 : 5
        id = 1:5;
        id(i) = 0;
        
        train = ismember(GroupList,id);
        test = ~ismember(GroupList,id);
        OUTPUT{i,1} = i;
        OUTPUT{i,2} = train';
        OUTPUT{i,3} = test';
        OUTPUT{i,4} = g;
        OUTPUT{i,5} = gn;
        
    end

