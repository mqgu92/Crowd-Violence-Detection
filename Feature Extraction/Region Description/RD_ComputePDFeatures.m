function [ FinalFeatureSet ] = RD_ComputePDFeatures( PD_SET,WINDOW_SIZE,WINDOW_SPLIT,WINDOW_SKIP )
% Using a GLCM set compute the features appropraitely
%

%Features = 'Energy,Contrast,Correlation,Homogeneity'

[M, ~] = size(PD_SET); % Number of different GLCM partitions
[N, ~] = size(PD_SET{1});  % Number of frames
F = 1;

% Determine the number of features extractable confined by the temporal
% plane
getIndex = 1:WINDOW_SKIP:(N - WINDOW_SIZE ) ;

if isempty(getIndex)
    getIndex = 1;
    WINDOW_SIZE = N;
end

TemporalIntervals = [0,cumsum(diff(round(linspace(0,WINDOW_SIZE,WINDOW_SPLIT+1))))];
TemporalIntervals(end) = TemporalIntervals(end) - 1; 
[~ ,T] = size(TemporalIntervals);

S = length(getIndex);


% Step 1: Cycle through each frame and calculate the GLCM features
FinalFeatureSet = [];
for P = 1 : M
    % For each Parition Set
    Partition = PD_SET{P};
    [~, PartitionSize] = size(Partition);
    
    SubFeatureSet = PD_SET{P};
    
    PartitionFinalFeatureSet = [];
    for i = 1 : S
        % Cycle Through Each Index at which a new feature window begins
        WindowStart = getIndex(i);
    
        TemporalFinalFeature = [];
        for TT = 1: T - 1
            
           SubFinalFeature = zeros(1,2);
           for G = 1 : PartitionSize
                SubFinalFeature(1 + F * 2 * (G - 1))  = mean(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),1 + F * (G - 1)));
                SubFinalFeature(2 + F * 2 * (G - 1))  = var(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),1 + F * (G - 1)));
           end
           TemporalFinalFeature = [TemporalFinalFeature,SubFinalFeature];
        end
        PartitionFinalFeatureSet = [PartitionFinalFeatureSet;TemporalFinalFeature];
    end
    FinalFeatureSet = [FinalFeatureSet,PartitionFinalFeatureSet];
end




end

