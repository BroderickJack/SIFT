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

%% Testing the FindLocalExtrema function

% 
% % ------------ 2,2,2 Local Extrema ----
% im1Test = [0.1  0.2  0.3;
%            0.4  0.5  0.6;
%            0.44 0.55 0.66];
% 
% im2Test = [0.11 0.22 0.33;
%            0.44 0.00 0.66;
%            0.13 0.23 0.34];
%        
% im3Test = [0.12 0.24 0.25;
%            0.23 0.24 0.63;
%            0.42 0.53 0.25];
%        
% imsTest = {im1Test, im2Test, im3Test};
% 
% [Row, Col, Index] = FindLocalExtrema(imsTest)
% 
% 
% % --------- NO LOCAL EXTREMA --------
% im1Test = [0.1  0.2  0.3;
%            0.4  0.5  0.6;
%            0.44 0.55 0.66];
% 
% im2Test = [0.11 0.22 0.33;
%            0.44 0.23 0.66;
%            0.13 0.23 0.34];
%        
% im3Test = [0.12 0.24 0.25;
%            0.23 0.24 0.63;
%            0.42 0.53 0.25];
%        
% imsTest = {im1Test, im2Test, im3Test};
% 
% [Row, Col, Index] = FindLocalExtrema(imsTest)
% 
% 
% % ---------- 2,2,2 Local Extrema ----
% im1Test = [0.1  0.2  0.3;
%            0.4  0.5  0.6;
%            0.44 0.55 0.66];
% 
% im2Test = [0.11 0.22 0.33;
%            0.44 1 0.66;
%            0.13 0.23 0.34];
%        
% im3Test = [0.12 0.24 0.25;
%            0.23 0.24 0.63;
%            0.42 0.53 0.25];
%        
% imsTest = {im1Test, im2Test, im3Test};
% 
% [Row, Col, Index] = FindLocalExtrema(imsTest)
