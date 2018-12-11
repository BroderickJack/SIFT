% Jack Broderick
% November 22, 2018
% CS652 Final Project
clear; clc; close all;

% This script runs the SIFT algorithm and displays the results


%% Define the variables
% imageName = './TestImages/im3.png';
% imageName = './TestImages/im1.jpg';
% imageName = './TestImages/im2.jpg';
imageName = './TestImages/im5.jpg';
imageName2 = './TestImages/im6.jpg';

%% Load the image
% Convert to grayscale and then to double
im = imread(imageName);
im = rgb2gray(im);
% im = imresize(im, [450, 450]);
im = im2double(im);
% im = im2double( rgb2gray( resize(imread(imageName), [450,450]) ) );
im2 = im2double(rgb2gray(imread(imageName2)));

%% Call the SIFT algorithm to get interest points
[Points1, Descriptors1] = SIFT(im);
[Points2, Descriptors2] = SIFT(im2);

%% Compute the closest
% Create a vector of the SIFTPoint that corresponds to each point in im1
matched = {};
for i = 1:length(Points1)
    % Loop through all of the points in image 1 to get the closest match in
    % image 2
    D1 = Descriptors1(i,:);
    
    if any(isnan(D1))
       matched{i} = Points2(1);
       continue;
    end
    
    % Save the minimum distance and the index in points 2
    minD = inf;
    minI = -1;
    for j = 1:length(Points2)
        D2 = Descriptors2(j,:);
        dist = sqrt(sum((D1-D2).^2));
        
        if (dist < minD)
            % This is the new minimum euclidian distance
            minD = dist;
            minI = j;
        end
    end
    matched{i} = Points2(minI);
end

%% Now we must plot the correspondance points
% Combine the images into a single image
imComb = [im, im2];
figure();
imshow(imComb); hold on;
title('Plotting correspondance points');

xGain = length(im(1,:)); % The gain to add to all of the column values for image 1

%
for i = 1:length(Points1)
    p1 = Points1(i).Location;
    p2 = matched{i}.Location;
    
    y1 = p1(2); x1 = p1(1);
    y2 = p2(2); x2 = p2(1) + xGain;
    
    % Plot the line between the two points
    plot([x1, x2], [y1, y2], 'rx-');
end

%% Testing the FindLocalExtrema function

