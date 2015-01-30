function [ structured_data,structured_point_data,structured_point_information ] = EXP_structure_data( unstructured_data, spatial, temporal )
%% EXP_STRUCTURE_DATA 
% Re-arranges unstructured data by video samples, the flags "spatial" and
% "temporal" will concatenate data as follows:
% 
% TEMPORAL, points from a sample that occur at the same temporal point will
% be grouped together at placed in a cell; if temporal is false then points
% will be groups by video only, regardless of temporal or spatial
% relationships
%
%   EXAMPLE:    Vector  , T
%               Vect1   , 1
%               Vect2   , 2        
%               Vect3   , 1
%               Vect4   , 1
%   OUTPUT = {[Vect1;Vect2;Vect4], [Vect3]};
%
% SPATIAL, rather than group points into a list of points that occur at
% time T points are concatenated in order of raster scan occurance
%
%   EXAMPLE:    Vector  , T , X, Y
%               Vect1   , 1 , 1 , 1
%               Vect2   , 1 , 3 , 1        
%               Vect3   , 1 , 2 , 1
%   OUTPUT = {[Vect1,Vect3,Vect2]};

% First Group Points by Video 
sample_names = unique(unstructured_data(:,4));
structured_data = cell(length(sample_names),1);
structured_point_data = cell(length(sample_names),1);
structured_point_information = cell(length(sample_names),1);
unstructured_samples = unstructured_data(:,4);

for s = 1: length(sample_names)
    index = strfind(unstructured_samples,sample_names{s}) ;
    index = find(not(cellfun('isempty', index)));

    video_structure_data = cell2mat(unstructured_data(index,1));
    video_structure_points = cell2mat(unstructured_data(index,2));

    
    if ~temporal && ~ spatial
        structured_data{s} = video_structure_data;
        structured_point_data{s} = video_structure_points;
        structured_point_information{s} = unstructured_data(index,3:5);
    end
    
    if temporal 
        [structured_data{s} structured_point_data{s}]=  temporalScheme(video_structure_data, video_structure_points);
        [s_v_s , ~] = size(structured_data{s});
        structured_point_information{s} = unstructured_data(index(1:s_v_s),3:5);
    end
    
    if spatial 
        % Split Grid into
       %[structured_data{s} structured_point_data{s}]=  temporalScheme(video_structure_data, video_structure_points);
        %[s_v_s , ~] = size(structured_data{s});
        %structured_point_information{s} = unstructured_data(index(1:s_v_s),3:5);
    end

end
structured_point_information  = cat(1,structured_point_information{:});
if temporal
    structured_data = cat(1,structured_data{:}); % Expand all descriptors into a single format
    structured_point_data  = cat(1,structured_point_data{:});
    
end



end

function [structured_data,structured_points] = temporalScheme(unstructered_data, point_data)
    t_list = point_data(:,3); % Temporal Start Points
    samples = unique(t_list);
    
    structured_data = cell(length(samples),1);
    structured_points = cell(length(samples),1);
    for v = 1:length(samples)
        t = samples(v);
        index = find(t_list == t);
        structured_data{v} = unstructered_data(index,:);
        structured_points{v} = point_data(index,:);
    end
end


