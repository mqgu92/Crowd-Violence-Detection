function [Precision,NegativePredictiveValue,Sensitivty,Specificity,Accuracy,PLOT] = MISC_PlotConfusion( C, CLASSES, PlotEnabled )



% Percentage of Positive Class that is correct (True Positive)
Precision = C(1,1) / (C(1,1)+C(1,2));

% Percentage of Negative Class that is correct (True Negative)
NegativePredictiveValue = C(2,2) / (C(2,1)+C(2,2));

Sensitivty = C(1,1) / (C(1,1) + C(2,1));

Specificity = C(2,2) / (C(1,2) + C(2,2));

Accuracy = (C(1,1)+ C(2,2) ) /sum(sum(C));
PLOT = 0;
if PlotEnabled
mat = C;
mat = zeros(3);
cSize = size(C);
mat(1:cSize(1),1:cSize(2)) = C;

mat(1,3) = Precision * 100;
mat(2,3) = NegativePredictiveValue* 100;
mat(3,1) = Sensitivty * 100;
mat(3,2) = Specificity * 100;

mat(3,3) = Accuracy * 100;             

%mat = confusionmat(testIDX{i} - 1 , fd{i} - 1) 
      %# A 5-by-5 matrix of random values from 0 to 1

PLOT = figure,imagesc(mat);            %# Create a colored plot of the matrix values
colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

            
                         
                         
textStrings = num2str(mat(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding


%% ## New code: ###
idx = find(strcmp(textStrings(:), '0.00'));
textStrings(idx) = {'   '};
%% ################

[x,y] = meshgrid(1:3);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(mat(:) > midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:2,...                         %# Change the axes tick marks
        'XTickLabel',CLASSES,...  %#   and tick labels
        'YTick',1:2,...
        'YTickLabel',CLASSES,...
        'TickLength',[0 0]);
set(gca,'xaxisLocation','top')


end



end

