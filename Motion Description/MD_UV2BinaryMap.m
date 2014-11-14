function [ BINARYMAP, PREVMAG ] = MD_UV2BinaryMap( U1,V1,U2,V2,PREVMAG )
%%
%   INPUT: U1,V1, U2,V2, prevMag
%   to save time re-calculating offer optional prevMag
%   in order to re-input pre-calculated flow magnitudes
%
%   OUTPUT: Binary Map, Magn
%   Using U,V flows calculate the magnitude of two frames
%   
%%%

%Step 1: Calculate Magnitude Maps
[~,bMag,~] = MD_UV2Maps( V1, U1 , 0, 1 );
if nargin > 4
    pMag = PREVMAG;
else
    [~,pMag,~] = MD_UV2Maps( V2, U2 , 0, 1 );
end
PREVMAG = bMag;

dMap = bMag - pMag;
Threshold = mean(mean(abs(dMap)));

dMap(dMap < Threshold) = 0;
dMap(dMap ~= 0) = 1;

BINARYMAP = dMap;
end

