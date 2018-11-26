function [xPoints, yPoints] = SIFT(im)
% INPUTS
%   im: nxm array of points in a grayscale image
% OUTPUTS
%   xPoints: X-coordinates of the interest points
%   yPoints: Y-coordinates of the interest points
SIGMA = [2, 4, 8, 16, 32];

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

%% Compute the difference of gaussian for each set of images
DoG = {};
for i = 1:length(SIGMA)-1
    DoG{i} = G_sigma{i+1} - G_sigma{i};
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
    t = sprintf('(%s = %i) - (%s = %i)', '\sigma', SIGMA(i+1), '\sigma',SIGMA(i));
    title(t);
end

%% Find Local Extrema
[Row, Col, Index] = FindLocalExtrema(DoG)
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
end