%%% varies t to "bounce-loop" a video of length T. It goes on forever, by
%%% alternating playing the video forwards and backwards.
function t2 = varyT(t,T)
    T = T-1;
    t= t-1;
    t2 = mod(t,T)-2*mod(floor((t)/T),2).*(mod(t,T)-T/2)+1;
