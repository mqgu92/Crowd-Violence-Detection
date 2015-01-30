function [ points ] = EXP_generate_global_points( W,H,v_l,s_l,scheme,override )
%%EXP_GENERATE_GLOBAL_POINTS 
% The scheme for generating regions for description rely on an X,Y
% co-ordinate and a width and height bounding distance as typically given
% by interest point detectors; in order to obtain sub-volumes usually used
% for global schemes we need to generate a set of points on a spatial grid
% at regular intervals with the Width and Height of each points box being
% half the distance to neighbouring points (or the edge)
%
%   L is a constant for all points in such a scheme

% INPUT
% W,H,L are video width, height and length respectively 
% Scheme defines the regions in terms of non-overlapping rows and columns
%   [1 1 1] = No Sub-regioning
%   [2 2 1] = split spatial into 4 corners
%   [3 1 1] = 3 columns, 1 row
%
% The third value indicates how to split the temporal domain, a value of -1
% or null will result in the generation of each point at every interval
% [1:L] (L should be reduced as VideoLength - SampleLength prior to this
% process
%
% Override is a (i,4) collection of X,Y,W,H points that can be manually 
% added, this will typically results in extracting overlapping regions
% however

% OUTPUT
% [x,y,t,w,h,l];

% The spatial points do not move in a global scheme so first generate a set
% of (X,Y) co-ordinates

s_c = scheme(1); % Spatial_Columns
s_r = scheme(2); % Spatial_Rows


p_x = linspace(1,W,s_c + 1); % Equidistant points on a line, the median of
p_y = linspace(1,H,s_r + 1); % each adjacent pair provides the X,Y

tp_x = [p_x',circshift(p_x',-1)];
tp_y = [p_y',circshift(p_y',-1)];

p_x = median(tp_x,2); p_x = p_x(1:end-1);
p_y = median(tp_y,2); p_y = p_y(1:end-1);

[p_x,p_y] = meshgrid(p_x,p_y);

w = abs(tp_x(1,1) - tp_x(1,2)); % All points equal, therefore Width is p1 - p2
h = abs(tp_y(1,1) - tp_y(1,2));

clear tp_x tp_y;

% Determine how temporal scheme is
% Temporal points are not centered, they indicate the temporal start and so
% it is assumed that the input length L is already
% (VideoLength-SampleLength)
if length(scheme) ~= 2
    % Split at every interval
    if scheme(3) == -1
        t = linspace(1,v_l,v_l);
    else
        t_l = scheme(3); % Temporal_Length
        % Split occurding to the scheme
        t = linspace(1,v_l,t_l);
    end
else
    % Split occurding to the scheme
    t = linspace(1,v_l,v_l);
end


t_count = length(t);
p_count = prod(scheme([1,2]));

points = zeros(t_count * p_count,6);
for p = 1 : p_count
    o = t_count *(p - 1); % Index Offset
    
    points(1 + o : t_count + o ,1) = deal(p_x(p));
    points(1 + o : t_count + o ,2) = deal(p_y(p));
    points(1 + o : t_count + o ,3) = deal(t);
    points(1 + o : t_count + o ,4) = deal(w);
    points(1 + o : t_count + o ,5) = deal(h);
    points(1 + o : t_count + o ,6) = deal(s_l);
    
end

if nargin == 6
    % Override Not Implemented yet
    % Simply distribute the specified points over the temporal scheme
    if override
    end;   
%t_count = length(t);
%override_points = zeros(t,6);
%override_points
end

end

