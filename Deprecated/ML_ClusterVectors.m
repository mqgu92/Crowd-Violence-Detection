function [ CENTROIDS ] = ML_ClusterVectors( DATA, K )
%%
%
%   Using input vector perform K-Means clustering and
%   return centroids
%
%%


    Vocab = vl_kmeans(transpose(cell2mat(DATA)), words);

end

