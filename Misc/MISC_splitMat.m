function [ OUTPUT ] = MISC_splitMat(DATA, X,Y,Z )
    
    if nargin == 3
    [M,N] = size(DATA);
    
    OUTPUT = mat2cell(DATA,diff(round(linspace(0,M,Y+1))),...
        diff(round(linspace(0,N,X+1))));
    end
    if nargin == 4
    [M,N,O] = size(DATA);
    
    OUTPUT = mat2cell(DATA,diff(round(linspace(0,M,Y+1))),...
        diff(round(linspace(0,N,X+1))),...
        diff(round(linspace(0,O,Z+1))));
    end
    
end

