function [Row, Col, Index] = FindLocalExtrema(DifferenceOfGaussian)
% INPUTS
%   - DiffernceOfGaussian: Cell array of the various differnces of gaussian
%   matrices for each 
% OUTPUTS
%   - Row: The Row of the local extrema
%   - Col: The Col of the local extrema
%   - Index: Which "layer" in the difference of gaussian the maxima is in

% This function finds the points that are local extrema compared to the 26
% neighbors of the pixel in it's own scale and the two neighboring scales

% Define the outpts
Row = [];
Col = [];
Index = [];

for i = 1:length(DifferenceOfGaussian)
    % Loop through all of the scales
    pre = DifferenceOfGaussian{max(i-1,1)};
    cur = DifferenceOfGaussian{i};
    nex = DifferenceOfGaussian{min(i+1,length(DifferenceOfGaussian)-1)};
    
    % Loop through all of the points in the current difference of gaussian
    for j = 2:(length(cur(:,1))-1)
        % Loop through all rows in the difference
        for k = 2:(length(cur(1,:))-1)
            % Loop through all columns in the difference
            p = cur(j,k); % The current point being compared 
            ext = 1; % Assume the point is an extrema until proven otherwise
            
            % Create vectors of the rows to check 
            rows = [j-1 j j+1];
            % Creat a vector of the columns to check
            cols = [k-1 k k+1];
            
            % Must intialize is max with the first point
            isMax =  p > pre(j-1, k-1);

            for r = 1:length(rows)
                row = rows(r);
                for c = 1:length(cols)
                    col = cols(c);
                    if (pre(row,col) > p && isMax) || (pre(row,col) < p && ~isMax)
                        ext = 0; % The point is not an extrema
                        break;
                    elseif (cur(row,col) > p && isMax) || (cur(row,col) < p && ~isMax)
                        ext = 0; 
                        break;
                    elseif (nex(row,col) > p && isMax) || (nex(row,col) < p && ~isMax)
                        ext = 0;
                        break;
                    end
                    
                    if(~ext)
                        break;
                    end
                end
                if(~ext)
                    break;
                end
            end
            
            % Check to see if the point is an extrema
            if ext
                % If the point is an extrema add it to the list
                Row = [Row, j];
                Col = [Col, k];
                Index = [Index, i];
            end    
        end
    end    
end

end