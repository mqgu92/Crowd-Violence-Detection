%%%%%%% a sigmoidal function. It does the logical operation (x>0) in a fuzzy manner %%%%
function out=sig(x,fuzziness)
if nargin <2
    fuzziness = 1;end;
if (fuzziness == 0)
    out = x > 0;
else
    out= (1+erf(x./fuzziness))/2;
end
