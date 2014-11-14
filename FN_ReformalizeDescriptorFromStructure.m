function [ OUT_DESCRIPTORS ] = FN_ReformalizeDescriptorFromStructure( DESCRIPTORS, STRUCTURE,FEATURES_PER_CELL )
% A pyramid structure may be applied to a set of descriptors, it may be
% important to seperate the features derived from the structure into a
% single list of feature vectors for bag of words generation
DescriptorSize = size(DESCRIPTORS);
OUT_DESCRIPTORS = reshape(DESCRIPTORS, sum(sum(prod(STRUCTURE,2)))*DescriptorSize(1),FEATURES_PER_CELL);

OUT_DESCRIPTORS = mat2cell(OUT_DESCRIPTORS,...
ones( length(OUT_DESCRIPTORS)/ sum(sum(prod(STRUCTURE,2))),1) * sum(sum(prod(STRUCTURE,2))),FEATURES_PER_CELL);
end

