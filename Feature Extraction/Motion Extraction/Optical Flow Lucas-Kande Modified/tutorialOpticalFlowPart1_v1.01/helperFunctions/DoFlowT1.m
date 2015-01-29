% Authors:
% Stefan M. Karlsson AND Josef Bigun 

function [U, V] = DoFlowT1(dx,dy,dt)

persistent gg TikConst;
%%initialization:
if isempty(gg)
    gg  = single(gaussgen(2)); %% filter for tensor smoothing
    TikConst  = single(40);    %% value 40, single precision
end

 %     MOMENT CALCULATIONS
 m200= conv2(gg,gg, dx.^2 ,'same') + TikConst;
 m020= conv2(gg,gg, dy.^2 ,'same') + TikConst;
 m110= conv2(gg,gg, dx.*dy,'same');
 m101= conv2(gg,gg, dx.*dt,'same');
 m011= conv2(gg,gg, dy.*dt,'same');

%flow calculations:
U =(-m101.*m020 + m011.*m110)./(m020.*m200 - m110.^2);
V =( m101.*m110 - m011.*m200)./(m020.*m200 - m110.^2);



    
