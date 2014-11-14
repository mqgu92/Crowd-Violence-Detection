function [ BESTPATHS, BESTIDX ] = MD_BestPaths( FLOWPATHS, NUMBER )
%MD_BESTPATHS Summary of this function goes here
%
%   FLOWPATHS = Collection of trajectories in a scene
%
%   NUMBER = Number of paths to keep
%%

% Step 1: Reformat FLOWPATH matrix from 2d to 1d
    FLOWPATHS = reshape(FLOWPATHS,1,prod(size(FLOWPATHS)));

    %tic;
% Step 2: Calculate Path Energy
    Energy = zeros(1,length(FLOWPATHS));

    for i = 1: length(FLOWPATHS)
        Energy(i) =  sum(sum(abs(diff(FLOWPATHS{i},1,1))));
    end
    %disp(toc);
% Step 3: Pick the top NUMBER paths
[rearrange, srtInd] = sort(Energy,'descend');
FIRSTZERO = find(rearrange==0, 1, 'first');
if isempty(FIRSTZERO) 
    FIRSTZERO = 0;
end
m = mean(rearrange(1:FIRSTZERO));
newList = srtInd(rearrange > (m/2));
if FIRSTZERO <= NUMBER
    FIRSTZERO = length(srtInd);
end

if length(newList) <= NUMBER
    srtInd = srtInd(1:FIRSTZERO); % Get all non-zero
else
    srtInd = newList; % Get all non-zero
end

%BESTIDX = srtInd(1:1:1*NUMBER);
%BESTPATHS = FLOWPATHS(BESTIDX);

% RANDOME
randStuff = randperm(length(srtInd));
BESTIDX = srtInd(randStuff(1:NUMBER));
BESTPATHS = FLOWPATHS(BESTIDX);
% 
% range = FIRSTZERO;
% if ~isempty(range)
%     if range > length(FLOWPATHS) 
%         range = length(FLOWPATHS);
%     else
%         range = length(FLOWPATHS);
%     end
% else
%     range = length(FLOWPATHS);
% end
% BESTIDX = round(logspace(0,log10(range),3*NUMBER));
% BESTIDX = unique(BESTIDX);
% step = floor(length(BESTIDX)/NUMBER);
% BESTIDX = BESTIDX(1:step:NUMBER*step);
% BESTPATHS = FLOWPATHS(BESTIDX);
end

