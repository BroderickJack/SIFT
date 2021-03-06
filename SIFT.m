function [P, Descriptors] = SIFT(im)
% INPUTS
%   im: nxm array of points in a grayscale image
% OUTPUTS
%   xPoints: X-coordinates of the interest points
%   yPoints: Y-coordinates of the interest points

clear('-except im');
close all;
% INPUTS
%   im: nxm array of points in a grayscale image
% OUTPUTS
%   xPoints: X-coordinates of the interest points
%   yPoints: Y-coordinates of the interest points
SIGMA = [2, 4, 8, 16, 32, 64];

%% Display the image
figure();
imshow(im);

%% Apply the gaussian for all of the values
G_sigma = {}; % Make a cell array for all of the gaussian images
for i = 1:length(SIGMA)
    G_sigma{i} = imgaussfilt(im, SIGMA(i));
end

% Plot the gaussian images
l = length(SIGMA);
figure();
for i = 1:length(SIGMA)
    subplot(l, 1, i);
    imshow(G_sigma{i});
    t = sprintf('%s = %i', '\sigma', SIGMA(i));
    title(t);
end

figure();
for i = 1:length(SIGMA)
    subplot(3, 3, i);
    imshow(G_sigma{i});
    t = sprintf('%s = %i', '\sigma', SIGMA(i));
    title(t);
end


%% Compute the difference of gaussian for each set of images
DoG = {};
for i = 1:length(SIGMA)-1
    DoG{i} = G_sigma{i+1} - G_sigma{i};
    % Normalize
    DoG{i} = mat2gray(G_sigma{i+1} - G_sigma{i});
%     size(DoG{i})
end

% Plot the difference of gaussian
figure();
l = length(DoG);
for i = 1:length(DoG) 
    subplot(l, 1, i);
    % Try viewing with the difference of gaussian normalized
%     imshow(DoG{i});
    imshow(DoG{i}, []);
%     t = sprintf('(%s = %i) - (%s = %i)', '\sigma', SIGMA(i+1), '\sigma',SIGMA(i));
    t = sprintf('DoG: %s = %i', '\sigma', SIGMA(i)); 
    title(t);
end

%%
figure()
for i = 1:length(DoG) 
    subplot(3, 3, i);
    % Try viewing with the difference of gaussian normalized
%     imshow(DoG{i});
    imshow(im2double(DoG{i}));
    t = sprintf('DoG: %s = %i','\sigma',SIGMA(i));
    title(t);
end

%% Find Local Extrema
[Row, Col, Index] = FindLocalExtrema(DoG);
colors = distinguishable_colors(length(DoG)); % Get colors for each scale

figure(); hold on;
imshow(im); hold on;
for i = 1:length(Row)
    plot(Col(i), Row(i), 'Color', colors(Index(i),:), 'Marker', '.', 'MarkerSize', 1);
end

title('Local Extrema');
% for i = 1:100
%     plot(Col(i), Row(i), 'Color', colors(Index(i),:), 'Marker', 'x');
% end

% Plot the local extrema on the original image

%% Eliminate The Edge Responses Using The Sobel Filter
% Find the gradient using the sobel filter
[R,C,I] = EliminateEdgeResponse(Row, Col, Index, DoG);
figure(); 
imshow(im); hold on;
for i = 1:length(R)
    plot(C(i), R(i), 'Color', colors(I(i),:), 'Marker', '.', 'MarkerSize', 1);
end
title('Local Extrema: Removed Edges');

figure();
l = {}; hold on;
for i = 1:length(colors(:,1))
    plot(i,i, 'Color', colors(i,:));
    l{i} = sprintf('DoG: %s = %i', '\sigma', SIGMA(i)); 
end
legend(l)
title('Scale labels');

fprintf('Number of keypoints with edges: %i\n', length(Row));
fprintf('Number of keypoints endges removed: %i\n', length(R));

%% Assign Orientation for Each Point
Points = AssignOrientation(R, C, I, DoG, SIGMA, im);

% Visualize the orientation of each of the points
figure(); imshow(im); hold on;
plot(Points, 'showOrientation', true);

%% Assign Descriptor for Each Point
[Descriptors, P] = AssignDescriptor(Points, G_sigma, SIGMA, im);
fprintf('Number of points before: %i\n', length(Points));
fprintf('Number of points after: %i\n', length(P));


end