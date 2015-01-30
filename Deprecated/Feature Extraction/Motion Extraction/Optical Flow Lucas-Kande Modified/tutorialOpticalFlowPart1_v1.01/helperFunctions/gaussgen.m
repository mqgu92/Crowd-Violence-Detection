function h=gaussgen(std,siz,type)
if nargin < 2
    siz = round(5*std);
    siz =siz + mod(siz-1,2); %make sure odd sized
end

% This function generates a 1-D gaussian kernel
x2 = (-(siz-1)/2:(siz-1)/2).^2;
h = exp(-(x2)/(2*std*std));
h = h/sum(sum(h));
