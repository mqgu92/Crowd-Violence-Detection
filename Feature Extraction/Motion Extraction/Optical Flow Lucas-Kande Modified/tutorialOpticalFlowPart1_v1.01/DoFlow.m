% Authors:
% Stefan M. Karlsson AND Josef Bigun 

function [U, V] = DoFlow(dx,dy,dt,method)

if nargin<4
%%% possibilities for 'method' are:  %%
%     method = 'LK';         %% Lucas Kanade
    method = 'NOTHING';      %% Do nothing, i.e. return zeros
end

      flowRes = 100; %resolution of the flow field in the image

      %     MOMENT CALCULATIONS
      gaussStd = 2; % for tensor smoothing.
      gg  = single(gaussgen(gaussStd)); %% filter for tensor smoothing

 m200=imresizeNN(conv2(gg,gg, dx.^2 ,'same'),[flowRes flowRes]);
 m020=imresizeNN(conv2(gg,gg, dy.^2 ,'same'),[flowRes flowRes]);
 m110=imresizeNN(conv2(gg,gg, dx.*dy,'same'),[flowRes flowRes]);
 m101=imresizeNN(conv2(gg,gg, dx.*dt,'same'),[flowRes flowRes]);
 m011=imresizeNN(conv2(gg,gg, dy.*dt,'same'),[flowRes flowRes]);

 
if strcmpi(method,'LK')

% Threshold, how well conditioned we want the tensor to be:
EPSILONLK = 0.5;
 
%the flow will be stored in component images U and V. We initialize them to zero:
%(dont change the below initializations, go further below for the actual calculations)

 U = zeros(size(m200));
 V = U;

%%%%%%%%%%%%%% flow by the Lucas and Kanade algorithm  %%%%%%%%%% 
%%%%% this is a traditional, explicit way of estimating flow. It suffers
%%%%% from the problems of numerical instability and slow implementation.
%%%%% NEVER EVER use this implementation for anything but educational purposes
%%%%% if you have come across this code in search of effecient implementation 
%%%%% of the LK local algorithm, see instead below for method "flow1"
for x=1:size(m011,1)
    for y=1:size(m011,2)
        %%%build the 2D structure tensor
        %%%TODO: build the 2D structure tensor, call it S2D!
        %%% (here you can assume that m20 = m200, m02 = m020)
        %%% you have access to the elements as m200(x,y), m020(x,y) and m110(x,y)
        %%% (it should NOT be the identity matrix, enter the correct)
        S2D  = [m200(x,y), m110(x,y);...
                m110(x,y), m020(x,y)];

        %%%%check that S2D is well conditioned, invertible with no problems
        if(rcond(S2D)>EPSILONLK) %"L1"

            %%%%%TODO form the vector 'DTd')
            %%%%% (it should NOT be the zero vector)
            b = [m101(x,y);...
                 m011(x,y)];
            %%%% TODO finally, calculate the velocity vector by the relation 
            %%%% between vector b, and matrix S2D (2D structure tensor)
            %%%% (it should NOT be the zero vector)
              v = -S2D\b;
            
            U(x,y) = v(1);
            V(x,y) = v(2);
        end
    end
end
elseif strcmpi(method, 'flow1')
    %This method is added for completeness. You are not required to study
    %it. It is also a Lucas Kanade version, but regularized (Tikhinov regularization)
    %This way of doing LK, is an improvement in every way I can think of, except
    %that it is less pedagogical
    
    %add  value along the structure tensor diagonal, this ensures it
    %is well conditioned and invertible    
    TikConst  = 80;
    m200 = m200 + TikConst; %"L2"
    m020 = m020 + TikConst;
    
    %do the analytically derived inversion of the tensor and multiplication with "b"
    U =(-m101.*m020 + m011.*m110)./(m020.*m200 - m110.^2);%"L3"
    V =( m101.*m110 - m011.*m200)./(m020.*m200 - m110.^2);
    
else % method 'nothing'
     U = zeros(size(m200));
     V = U;
end