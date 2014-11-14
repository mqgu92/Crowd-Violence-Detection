% create a matrix y, with two rows
Desc = GEPNonPCADescriptors;
[M N] = size(GEPNonPCADescriptors);
%Generate Wrapper 
StoreCell = cell(M + 1, N + 2);

for i = 1 : M + 1
    StoreCell{i,1} = strcat('P',num2str(i - 2));
end


for i = 1 : N + 1
    StoreCell{1,i} = strcat('D',num2str(i - 1));
end

DescCell = num2cell(Desc);
[G GN] = grp2idx(GEPTags);  % Reduce character tags to numeric grouping
G = 1./G;
StoreCell(2:M+1,2:N+1) = DescCell;
StoreCell(2:M+1,N+2) = num2cell(G);

% open a file for writing
fid = fopen('exptable.txt', 'w');


% print values in column order
% two values appear on each row of the file

fprintf(fid, 'DN \n');
fprintf(fid, '598 \n');
fprintf(fid, '417 \n');

for y = 1 : M + 1
    Line = '';
    for x = 1 : N + 1
        Line = strcat(Line,num2str(StoreCell{y,x}),';');
    end
    Line = strcat(Line,num2str(StoreCell{y,x + 1}),'\n');    

    fprintf(fid, Line);    
    disp(y);
end


fclose(fid);


