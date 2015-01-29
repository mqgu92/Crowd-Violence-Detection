if nargin <1
    movieType  = 'synthetic'; end
if nargin <2
    method = 'nothing'; end
if nargin <3
    bFineScale = 1; end    
if nargin <4
    spdFactor = [0.4, 0]; end
if nargin <5
    lagTime = 0;end


if length(spdFactor) == 1
    spdFactor = [spdFactor, 0]; %if speed of rotation was not given, set zero
end

%initialize globals
g.arrowKey = [0,0];
g.spdFactor = spdFactor;
g.lagTime = abs(lagTime(1)); %lagTime should be single, positive value
g.bPause = 0;

method = lower(method);

sc = 8; %scale vectors for plotting 
camID = 0; %camera id..
if strcmpi(movieType,'synthetic')
    kindOfMovie  = 'synthetic';
    movieType = '';
elseif (strfind(movieType,'camera')==1) %starts with 'camera'
    if strcmpi(movieType,'camera') %exactly 'camera'
     	kindOfMovie  = 'camera';
        movieType = '';
        camID =1; 
    else %argument longer than just 'camera'
        camID = str2double(movieType(7:end));  %last part of string to number
        if ~isempty(camID) %valid number, assume a
            kindOfMovie  = 'camera';
            movieType = '';
        else %it was not a valid number for a camera, assume a file name
            kindOfMovie  = 'file';
        end
    end
else
	kindOfMovie  = 'file';
end

%a function that sets up the video:
vid =  myVidSetup(kindOfMovie,movieType,128,128,camID);
% set initially flow to:
U1 = 0; V1 =0;

