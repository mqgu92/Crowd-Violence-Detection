function [ OUTGROUP ] = FN_GEPGroup2VTT( VIDEOLIST,FLOWLIST, GROUP )
% When a test has been previously performed on K-Fold cross validation and
% a new VTT set is required, rather than recompute all the descriptors just
% rewrite the GROUPING

% A FLOW List is a list describing which video has which tag

[M N] = size(VIDEOLIST);


FlowListNames = FLOWLIST(:,3);

OUTGROUP = cell(length(GROUP),1);

for i = 1: M
    %Create VideoName
    VideoName = VIDEOLIST{i,3};
    a = strfind(FlowListNames,VideoName);
    ind= find(~cellfun(@isempty,a));
    OUTGROUP{ind} = VIDEOLIST{i,5};
end

end

