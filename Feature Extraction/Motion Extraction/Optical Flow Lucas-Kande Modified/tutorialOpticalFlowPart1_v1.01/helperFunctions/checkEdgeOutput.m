% checks for sanity in the DoEdgeStrength output
function bOK = checkEdgeOutput(edgeIm)
      bOK = 1;
      if (ndims(edgeIm) ~=2 || size(edgeIm,1) ~= size(edgeIm,2) || length(edgeIm) < 3 || ~isreal(edgeIm))
          msgbox('function "DoEdgeStrength" returned invalid image. edgeIm should be square, 2D, real valued (did you use a dx^2 instead of dx.^2?)');
          bOK = 0;
      end      

