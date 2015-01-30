function [ GLCM_features, GLCM_mean_std_features ] = RD_ComputeGLCMFeatures( GLCM_VOLUME, WINDOW_SPLIT )
% Using a GLCM set compute the features appropraitely
%

OUTPUT = zeros();
[M,N,WINDOW_SIZE] = size(GLCM_VOLUME);

TemporalIntervals = [0,cumsum(diff(round(linspace(0,WINDOW_SIZE,WINDOW_SPLIT+1))))];
TemporalIntervals(end) = TemporalIntervals(end) - 1; 
[~ ,T] = size(TemporalIntervals);

GLCM_features = zeros(WINDOW_SIZE,4);
%Compute Statistics for Each Frame
for i = 1: WINDOW_SIZE
    stats = graycoprops(GLCM_VOLUME(:,:,i),{'all'});
    GLCM_features(i,1)  = stats.Contrast;
    GLCM_features(i,2)  = stats.Energy;
    GLCM_features(i,3)  = stats.Correlation;
    GLCM_features(i,4)  = stats.Homogeneity;
end

GLCM_mean_std_features = zeros(1,8 * (T - 1));
for i = 1: T - 1
GLCM_mean_std_features(:,1 + ((i - 1) * 8)) = mean(GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),1));
GLCM_mean_std_features(:,2 + ((i - 1) * 8)) = std (GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),1));     
GLCM_mean_std_features(:,3 + ((i - 1) * 8)) = mean(GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),2));
GLCM_mean_std_features(:,4 + ((i - 1) * 8)) = std (GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),2));  
GLCM_mean_std_features(:,5 + ((i - 1) * 8)) = mean(GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),3));
GLCM_mean_std_features(:,6 + ((i - 1) * 8)) = std (GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),3));  
GLCM_mean_std_features(:,7 + ((i - 1) * 8)) = mean(GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),4));
GLCM_mean_std_features(:,8 + ((i - 1) * 8)) = std (GLCM_features(1 + TemporalIntervals(i) : 1 + TemporalIntervals(i + 1),4));  
end


end

