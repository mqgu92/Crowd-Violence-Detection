function [ VOCAB ] = ML_VocabGeneration( DATA, WORDS )
%%
%
%   Using input vector perform K-Means clustering and
%   return centroids
%
%%
    disp('---Vocab Generation---');
    %Reduce all data into a matrix
    %DATA = transpose(cell2mat(DATA));
    %Cluster and return Centroids
    tic;
    %[idx,VOCAB] = kmeans3(DATA, WORDS,'EmptyAction','drop');
    VOCAB = vl_kmeans(transpose(DATA), WORDS);
    VOCAB = transpose(VOCAB);
    disp('---Vocab Generated---');
    t = toc;
    disp(strcat('Time Taken to Generate:',num2str(t)));
end
