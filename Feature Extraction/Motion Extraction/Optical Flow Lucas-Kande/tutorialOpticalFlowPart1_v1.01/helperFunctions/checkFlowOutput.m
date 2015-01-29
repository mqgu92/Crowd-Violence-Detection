% checks for sanity in the DoFlow output
function bOK = checkFlowOutput(U1, V1)
bOK = 1; 
      if (ndims(U1) ~=2 || ndims(V1) ~=2)
          bOK = 0;
          msgbox('function "DoFlow" has returned invalid output. "U1", "V1" must all be 2D');end      
      if (size(U1,1) ~= size(U1,2))
          bOK = 0;
          msgbox('function "DoFlow" has returned an invalid output. "U1", "V1" must all be square (height=width)');end
      if (sum(size(U1) ~= size(V1)))
          bOK = 0;
          msgbox('function "DoFlow" has returned an invalid output. "U1", "V1" must all be of equal size');end
      
