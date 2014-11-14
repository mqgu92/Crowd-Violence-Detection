function [ OUTPUT ] = ML_NearestWord( DATA, VOCAB,WORDS )
%  ML_NEARESTWORD returns the a collection of centroids that best 
%  representate a set of data

    OUTPUT = zeros(length(DATA),WORDS);
    %disp('Finding Nearest Words');
    %tic;
    for i = 1 : length(DATA)
     
        data = DATA{i};
        

        labels = knnsearch(VOCAB,data,'distance','euclidean');

        for j = 1 : length(labels)
             OUTPUT(i,labels(j)) = OUTPUT(i,labels(j)) + 1;
        end
    end

end

