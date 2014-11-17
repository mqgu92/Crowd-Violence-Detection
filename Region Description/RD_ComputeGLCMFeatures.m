function [ FinalFeatureSet ] = RD_ComputeGLCMFeatures( GLCM_SET,WINDOW_SIZE,WINDOW_SPLIT,WINDOW_SKIP,FEATURES )
% Using a GLCM set compute the features appropraitely
%

%Features = 'Energy,Contrast,Correlation,Homogeneity'

[M, ~] = size(GLCM_SET); % Number of different GLCM partitions
[N, ~] = size(GLCM_SET{1});  % Number of frames
[F, ~] = size(FEATURES); % Number of Features Extracted


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
FeatureSet = cell(M,1);
FinalFeatureSet = [];
for P = 1 : M
    % For each Parition Set
    Partition = GLCM_SET{P};
    [~, PartitionSize] = size(Partition);
    
    SubFeatureSet = zeros(N,F * PartitionSize);
    
    for i = 1 : S
        % Cycle Through Each Index at which a new feature window begins
        
        WindowStart = getIndex(i);
        for W = 1: WINDOW_SIZE
            
            if SubFeatureSet(WindowStart + W - 1,1) == 0
                GLCMFrame = Partition(WindowStart + W - 1,:);
                for G = 1 : PartitionSize
                    stats = graycoprops(GLCMFrame{G},{'all'});
                    SubFeatureSet(WindowStart + W - 1,1 + F * (G - 1))  = stats.Contrast;
                    SubFeatureSet(WindowStart + W - 1,2 + F * (G - 1))  = stats.Energy;
                    SubFeatureSet(WindowStart + W - 1,3 + F * (G - 1))  = stats.Correlation;
                    SubFeatureSet(WindowStart + W - 1,4 + F * (G - 1))  = stats.Homogeneity;
                end
            end
        end
        
    end
    FeatureSet{P,1} = SubFeatureSet;
    
    
    PartitionFinalFeatureSet = [];
    for i = 1 : S
        % Cycle Through Each Index at which a new feature window begins
        WindowStart = getIndex(i);
    
        TemporalFinalFeature = [];
        for TT = 1: T - 1
            
           SubFinalFeature = zeros(1,8);
           for G = 1 : PartitionSize

                SubFinalFeature(1 + F * 2 * (G - 1))  = mean(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),1 + F * (G - 1)));
                SubFinalFeature(2 + F * 2 * (G - 1))  = var(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),1 + F * (G - 1)));
                SubFinalFeature(3 + F * 2 * (G - 1))  = mean(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),2 + F * (G - 1)));
                SubFinalFeature(4 + F * 2 * (G - 1))  = var(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),2 + F * (G - 1)));
                SubFinalFeature(5 + F * 2 * (G - 1))  = mean(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),3 + F * (G - 1)));
                SubFinalFeature(6 + F * 2 * (G - 1))  = var(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),3 + F * (G - 1)));
                SubFinalFeature(7 + F * 2 * (G - 1))  = mean(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),4 + F * (G - 1)));
                SubFinalFeature(8 + F * 2 * (G - 1))  = var(SubFeatureSet(WindowStart + TemporalIntervals(TT) : WindowStart + TemporalIntervals(TT + 1),4 + F * (G - 1)));
               
           
           end
           TemporalFinalFeature = [TemporalFinalFeature,SubFinalFeature];
        end
        PartitionFinalFeatureSet = [PartitionFinalFeatureSet;TemporalFinalFeature];
    end
    FinalFeatureSet = [FinalFeatureSet,PartitionFinalFeatureSet];
end




end

