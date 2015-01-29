% Authors:
% Stefan M. Karlsson AND Josef Bigun 

function edgeIm = DoEdgeStrength(dx,dy)

edgeIm = sqrt(dx.^2+dy.^2);
    