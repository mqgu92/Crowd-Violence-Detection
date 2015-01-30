function [ dMap,mMap,bMap ] = MD_UV2Maps( v, u , threshold, bins )
%% MD_UV2Maps
%
% Converts u,v vector flows into two distinct maps
%   Magnitude Map: The magnitude of vector flow
%   Rotation Map: Direction of vector
%   Bin Map: Based on direction, allocates a 'bins' number of groups


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
mMapIDX = (mMap < threshold);
mMap(mMapIDX) = 0;


%% Calculate the Bin Map
%Bin = angle *bins / total angle
bMap = mod(round((dMap .* bins) ./360),bins);

%% Create a histogram
%flowSize =  size(u);
%flowSize = flowSize(1) * flowSize(2); 

%bMapr = reshape(bMap, 1,flowSize);
%mMapr = reshape(mMap, 1,flowSize);




end

