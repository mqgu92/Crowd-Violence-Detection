function [ OUT_DESCRIPTORS ] = FN_ReformalizeDescriptorToStructure( DESCRIPTORS, STRUCTURE,FEATURES_PER_CELL  )
%FN_REFORMALIZEDESCRIPTORTOSTRUCTURE Summary of this function goes here
%   Detailed explanation goes here

OUT_DESCRIPTORS = reshape(DESCRIPTORS, length(DESCRIPTORS)/ sum(sum(prod(STRUCTURE,2))),...
    sum(sum(prod(STRUCTURE,2))) * FEATURES_PER_CELL);


end

