function [Descriptor, Points] = AssignD(Points, G_Sigma, SIGMA, Im)
% INPUT
%   Points - SURFPoints Ojbects that contain information about the scale,
%   location and orientation of each of the points 
%       - Each object has the following properties
%           - Count
%           - Location [col, row] == [x, y]
%           - Scale
%           - Oreintation
%   SIGMA - The 
%   G_Sigma - The image with various gaussian filters applied
% OUTPUTS
%   D - A Nx128 matrix where each row is the D for the
%   ith point in Points

% Extract the data from points
Scales = Points.Scale;
Orientations = Points.Orientation;
Locations = Points.Location;

% Function paramters
BINS = 0:(2*pi)/8:2*pi; % For the weighted gradient

% Initialze the Descriptor
Descriptor = []; % Nx128 vector, one row per point

for i = 1:length(Points)
    % Get the info about the interest point
    s = Scales(i); % Get the Scale of the interest point
    l = Locations(i, :); % Get the row and column of the point\
    c = l(1);
    r = l(2);
    o = Orientations(i); % Get the orientation of the point
    
    % First, apply the gaussian
    imFilt = imgaussfilt(Im, s);
    
    % Rotate the image
    % Get the rotation matrix
    R = [cos(o), -sin(o), 0;
         sin(o), cos(o) , 0;
         0     , 0      , 1];
    % Find the rotated r and c
    x = [c;
         r;
         1];
    x_prime = R * x;
    x_prime = x_prime ./ x_prime(end);
    rR = x_prime(2);
    cR = x_prime(1);
    
    if (r == 954 && c == 688)
        fprintf('Debug');
    end
    
    % If rR or cR are < 0, then we can't have them in our image
    if (rR < 0 || cR < 0)
        Points(i) = [];
        fprintf('Skipping r = %i, c = %i\n', r, c);
        continue;
    end
    
%     imRotate = imrotate(imFilt, -r*(180/pi));
    imRotate = transformImage(imFilt, R, 'rotation');
    
    % Get the gradient orientation and magnitude in a 16x16 region around
    % the interest point
    
    % Calculate the gradient for the filtered and rotated image
    [Gx, Gy] = imgradientxy(imRotate, 'sobel');
    gMag = sqrt(Gx.^2 + Gy.^2);
    
    % Apply gaussian to the magnitude
    gMag = imgaussfilt(gMag, s);
    
    gOr = atan(Gy./Gx); % atan returns a result in radians

    % Need to calculate for a 16x16 region around the point
    gM = []; % 16x16 around the interest point
    gO = []; % 16x16 around the interest point
    imVal = []; % 16x16 neighborhood around the interest point

    
    % use rR and cR because we are looking in the rotated image
    for ro = max(rR-8,0):1:min(length(imRotate(:,1)),rR+7)
        gMRow = []; % Create each row of the gradient 
        gORow = []; % Create each row of the orientation
        imRow = [];
        for co = max(cR-8):1:min(length(imRotate(1,:)),cR+7)
            % We are probably going to need to interpolate these values
            v = interp2(imRotate, co, ro);
            mag = interp2(gMag, co, ro);
            or = interp2(gOr, co, ro);
            
            % INTERP2 TAKES X,Y not ROW,COL
            
            % Add the values to the row
            gMRow = [gMRow, mag];
            gORow = [gORow, or];
            imRow = [imRow, v];
        end
        % Add the row to the overall matrix
        gM = [gM; gMRow];
        gO = [gO; gORow];
        imVal = [imVal; imRow];
    end
    
    % Compute the histogram of the orientations weighted by the magnitude
    % Calculate the histogram for top left corner 
    if (r == 954 && c == 688)
        figure(); imshow(gM, []);
        title('Gradient magnitude in neighborhood');
        set(gcf,'PaperPositionMode', 'auto');
        set(gcf, 'ResizeFcn', 'resize_fcn');
        figure(); imshow(imVal);
        title('Image in neighborhood');
        set(gcf,'PaperPositionMode', 'auto');
        set(gcf, 'ResizeFcn', 'resize_fcn');
        figure();
    end
    
    D = [];
    count = 1;
    for secR = 1:4
        % Loop through the four columns of subblocks
        for secC = 1:4
            i1R = ((secR-1)*4)+1;
            i2R = (secR*4);
            i1C = ((secC-1)*4)+1;
            i2C = (secC*4);
            O = gO(i1R:i2R, i1C:i2C);
            O = reshape(O, numel(O), 1);
            M = gM(i1R:i2R, i1C:i2C);
            M = reshape(M, numel(M), 1);
            
            % Calculate the weighted histogram for the subsection
            g = weightedhistc(O, M, BINS);
           
            % 1x9 row vector where the last element are ones that didn't
            % fit in any of the bins so we don't care about those
            D = [D, g(1:end-1)];
            
            
            if (r == 954 && c == 688)
                subplot(4,4, count);
                bar(BINS, g);
                count = count + 1;
            end
        end
    end
    
    % We need to normalize the D to have length 1
    D = D ./ norm(D);
    % We need to make sure that there are no values above 0.2
    D( find(D > 0.2) ) = 0.2;
    % Re-normalize
    D = D ./ norm(D);
    
    if (r == 954 && c == 688)
        fprintf('Scale: %i\n', s);
        fprintf('Column: %i Row: %i\n', c, r);
        fprintf('Orientation: %0.2f [rad]\n', o);
        
        % Show the old image
        figure(); imshow(Im);
        title('Original');
        hold on;
        plot(c, r, 'rx');
        
        % Show the rotated image
        figure(); imshow(imRotate);
        title("Roated Image");
        hold on;
        plot(cR, rR, 'rx');
        
        % Show them both in the same subplot
        figure();
        subplot(121); hold on; imshow(Im);
        title('Original');
        hold on;
        plot(c, r, 'rx');
        subplot(122); hold on;imshow(imRotate);
        title("Rotated Image");
        hold on;
        plot(cR, rR, 'rx');
    end
    
    % Add the descriptor for this point
    Descriptor = [Descriptor; D];
    
end