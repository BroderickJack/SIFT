% Jack Broderick
% November 22, 2018
% CS652 Final Project
clear; clc; close all;

% This script runs the SIFT algorithm and displays the results


%% Define the variables
imageName = './TestImages/im1.jpg';

%% Load the image
% Convert to grayscale and then to double
im = im2double( rgb2gray( imread(imageName) ) );

%% Call the SIFT algorithm to get interest points
[xPoints, yPoints] = SIFT(im);

%% Show the interest points
figure(); hold on;
imshow(im);
plot(xPoints, yPoints, 'rx');
legend('Interest Points');