function [Points] = AssignOrientation(Row, Col, Index, DoG, Sigma, Im)   
% INPUTS
%   Row         - The rows of the interest points
%   Col         - The columns of the interest points
%   Index       - The index of the DoG that the interest point was detected in
%   DoG         - The difference of gaussian images
%   Sigma       - The scale associated with each of the points, for each point it
%       the scale is at index
%   Im          - The original image
% OUPTUTS 
%   Points -  SURFPoints object that has an entry for each of the interest
%       points with Location, Orientation, and Scale information

% This function assigns an orientation for each of the interest points 

%% Create the vectors for creating a SURFPoints object at the end
Location = []; % Nx2 matrix of the X,Y coordinates of the interest points
Scale = []; % Nx1 matrix of the scale of each point
Orientation = []; % Nx1 matrix of the orientation from the positive X-axis

%% Parameters for the function
EDGES = (-1*pi):(2*pi)/36:pi; % The edges of the histogram

%% Get the number of rows and columns in the image
[maxRow, maxCol] = size(Im);

%% Find the gradient for all possible sigmas
gMags = {};
gOrientations = {};

for i = 1:length(Sigma) 
    imFilt = imgaussfilt(Im, 1.0/Sigma(i));
    
    % Calculate the gradient for the filtered image
    [Gx, Gy] = imgradientxy(Im, 'sobel');
    gMags{i} = sqrt(Gx.^2 + Gy.^2);
    gOrientations{i} = atan(Gy./Gx);
end

%% Loop through all of the points
for i = 1:length(Row) 
    gMag = gMags{Index(i)};
    gOrientation = gOrientations{Index(i)};
    
    % Look at the orientations around a 9x9 neighborhood of the point
    %   CHECK - The SIFT paper says to weight by the maginitude ... is it
    %   really necisarry??
    
    r = Row(i);
    c = Col(i);
    
    % Loop through the points in the neighborhood
    orientations = [];
    magnitudes = [];
    count = 1;
    for( ro = (max(1, r-4)):(min(maxRow,r+4)) )
        % We want to loop through the rows +/- 4 from the interest point
        for co = (max(1, c-4)):(min(maxCol,c+4))
            % Loop through the columns +/- from the interest point
            gM = gMag(ro, co); % The magnitude at the pixel
            gO = gOrientation(ro, co); % The orientation at the pixel
            
            % Record the magintude and the orientation
            magnitudes(count) = gM;
            orientations(count) = gO;
            count = count + 1;
        end
    end
    
    % Apply the weights to the histogram
    h = weightedhistc(orientations, magnitudes, EDGES);
    
    % Find the orientation with the highest number of occurances
    [Y, I] = max(h); % Get the maximum value Y a tthe index I
    
    % Find if there is another place where it is above 0.8*max value
    possiblePoints = find(h > (0.8*Y));
    
    % Loop through the possible orientations because we need to add a
    % interest point for each one
    for j = 1:length(possiblePoints)
        Location = [Location; c, r];
        Scale = [Scale; Sigma(Index(i))];
        Orientation = [Orientation; possiblePoints(j)];
    end
    
    
    if( i == 1 )
        % We only want to plot one image
        figure(); imshow(Im);
        figure(); imshow(imFilt); title('Filtered with 1/\sigma'); hold on;
        plot(Col(i), Row(i), 'rx');
        figure(); imshow(gMag( (max(1, r-4)):(min(maxRow,r+4)), (max(1, c-4)):(min(maxCol,c+4)) )); title('Maginitude of Gradient');
        
        % Show the histogram of the orientations
%         figure(); histogram(magnitudes, EDGES);
%         figure(); histogram(orientations, EDGES);
        
        % Show the weighted hist
        figure(); bar(EDGES, h); title('Weighted histogram');
    end
end

% Create the SURFPoints object
Points = SURFPoints(Location, 'Scale', Scale, 'Orientation', Orientation);

end