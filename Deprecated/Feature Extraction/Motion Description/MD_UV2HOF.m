function [ flowHist ,wFlowHist ] = MD_UV2HOF( v, u , threshold, bins )
%% UV2MAGROT 
%
% Converts a set of u,v vector flows into a Histogram of Oriented Flows 
%   with 'bins' number of bins
%

%% Calculate the Angle Map
dMap = atan2(v,u);
dMap(isnan(dMap)) = 0;
dMap = dMap .* (180/pi);
% Remove the negatives by 360 - abs(angle)
dNegMap = dMap;
dNegMap(dNegMap >0) = 0;
dNegMap = abs(dNegMap);
dNegMap = 360 - dNegMap;
dNegMap(dNegMap == 360) = 0;

dMap(dMap < 0 ) = 0;
dMap = dMap + dNegMap;

%% Calculate the Magnitude Map
mMap = (v.^2 + u.^2).^0.5;

%% Calculate the Bin Map
%Bin = angle *bins / total angle
bMap = mod(round((dMap .* bins) ./360),bins);

%% Create a histogram
flowSize =  size(u);
flowSize = flowSize(1) * flowSize(2); 

bMapr = reshape(bMap, 1,flowSize);
mMapr = reshape(mMap, 1,flowSize);

% Add the magnitude of each flow to their bin
flowHist = zeros(bins + 1,1);

wFlowHist  = zeros(bins + 1,1);

for i = 1: flowSize
    fVal = bMapr(i) + 1  ;
    fMag = mMapr(i);
    if fMag > threshold
        flowHist(fVal) = flowHist(fVal) + 1 ;
    else
        flowHist(bins + 1) = flowHist(bins + 1) + 1; 
    end
    
     if fMag > threshold
        wFlowHist(fVal) = wFlowHist(fVal) + fMag;
     else
        wFlowHist(bins + 1) = wFlowHist(bins + 1) + fMag; 
     end

    
end



end

