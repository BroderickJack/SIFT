function [Row, Col, Index] = EliminateEdgeResponse(R, C, I, DoG)
% INPUTS
%   - Row: (nx1 array) The rows of the keypoints found 
%   - Col: (nx1 array) The columns of the keypoints found
%   - Index: (nx1 array) The index in DoG that the keypoint is found
%   - DoG: Cell array that has the difference of gaussian images 
% OUTPUTS
%   - Row: The rows of the keypoints that aren't edges
%   - Col: The columns of the keypoints that aren't edges  
%   - Index: The index in DoG that the keypoint is found

% This is a function to remove the keypoints that are on edges or at
% corners

%% Initialize the output
Row = [];
Col = [];
Index = [];

%% Parameters
r = 10; % The ratio for eliminating keypoints that are along edges 
eigThresh = 4; % Maximum eigen value threshold
%% Compute the sobel second derivatives for each element in DoG
Dxx = {}; Dxy = {}; Dyx = {}; Dyy = {};
for i = 1:length(DoG)
    im = DoG{i};
    [Gx, Gy] = imgradientxy(im, 'sobel');
    [Dxx{i}, Dxy{i}] = imgradientxy(Gx, 'sobel');
    [Dyx{i}, Dyy{i}] = imgradientxy(Gy, 'sobel');   
end

%% Find the hessian for all of the keypoints
% Find what the values of (Tr(H)^2)/det(H) are
vals = [];
for i = 1:length(R)
    index = I(i);
    dXX = Dxx{index}; dXY = Dxy{index}; dYX = Dyx{index}; dYY = Dyy{index};
    r = R(i); c = C(i);
    
    if (r == 682 && c == 289)
        fprintf('Stop here');
        
    end
    H = [dXX(r,c), dXY(r,c);
         dXY(r,c), dYY(r,c)];
%     H = [dXX(c,r), dXY(c,r);
%          dXY(c,r), dYY(c,r)];
%     vals = [vals,((trace(H)^2) / det(H))];
vals = [vals, mean(eig(H))];
%     if(((trace(H)^2) / det(H)) < ((r + 1)^2)/r)
    if any(eig(H) > eigThresh)
% Use the eigen-value 

        % This point is not an edge
        Row = [Row, r];
        Col = [Col, c];
        Index = [Index, index];
    end
end

% Plot a histogram of the values
figure();
histogram(vals);


   
end