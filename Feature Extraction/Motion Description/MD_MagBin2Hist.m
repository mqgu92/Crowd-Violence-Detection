function [ wFlowHist ] = MD_MagBin2Hist( bMapr,mMapr ,flowSize,bins,~)
%% MAGBIN2HIST
%
%   Generates a histogram based on precalculated vector magnitude and
%   vector bin map derived from rotation. Bin(Rotation) map is used to
%   seperate vectors in bins with magnitude map providing a method of
%   thresholding weak flows
%

% Add the magnitude of each flow to their bin

wFlowHist  = zeros(bins + 1,1);

%bMapr = reshape(bMapr,1,numel(bMapr));
%mMapr = reshape(mMapr,1,numel(mMapr));
%flowSize = numel(bMapr);
%for i = 1: flowSize
    %fVal = bMapr(i) + 1  ;
    
     %if fMag > threshold
%        wFlowHist( bMapr(i) + 1) = wFlowHist( bMapr(i) + 1) + mMapr(i);
   %  else
    %    wFlowHist(bins + 1) = wFlowHist(bins + 1) + mMapr(i); 
   %  end

   u = unique(bMapr);

for i = 1 : length(u)
   wFlowHist(u(i) + 1) = wFlowHist(u(i) + 1) + sum(mMapr(bMapr == u(i))); 


end




end

