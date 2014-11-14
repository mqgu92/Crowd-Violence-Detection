function [ STRNUMBER ] = MISC_Padzeros( NUMBER, ZEROS )
%MISC_PADZEROS Summary of this function goes here
%   Detailed explanation goes here

s = num2str(NUMBER);
l = length(s);

add = ZEROS - l;

for i = 1 : add
    s = [num2str(0),s];
end
STRNUMBER = s;
end

