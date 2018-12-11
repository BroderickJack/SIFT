function TransformedImage = transformImage(InputImage, TransformMatrix, TransformType)
    % Inputs
    %   - InputImage: matrix of size Hin x Win
    %   - TransformMatrix: 3x3 transform matrix
    %   - TransformType: A string that can be the following
    %       - 'scaling', 'rotation', 'translation', 'reflection', 'shear',
    %       'affine', 'homogenous'
    % Output
    %   - TransformedImage: InputImage after TransformMatrix has been applied 

    % Convert Image to a double
    InputImage = im2double(InputImage);
    
    % Get the size of the image
    [H, W, L] = size(InputImage);
    %% Step 1: Domain of I'
    % [x1prime, y1prime, w1prime]
    % disp(TransformMatrix)
    A1prime = TransformMatrix * [1; 1; 1];
    A2prime = TransformMatrix * [W; 1; 1];
    A3prime = TransformMatrix * [1; H; 1];
    A4prime = TransformMatrix * [W; H; 1];

    prime = [A1prime, A2prime, A3prime, A4prime];

    % Currently A1prime is [x^prime y^prime W^prime];
    % We want the actual xprime so we divide x^prime and y^prime by W^prime
    prime = prime ./ prime(3,:);
    
%     Aprime = [min([1,prime(1,:)]), min([1,prime(2,:)])];
%     Bprime = [max(prime(1,:)), min([1,prime(2,:)])];
%     Cprime = [min([1,prime(1,:)]), max(prime(2,:))];
%     Dprime = [max(prime(1,:)), max(prime(2,:))];
% 
%     Aprime
%     Bprime
%     Cprime
%     Dprime

    minx = round(min([1, prime(1,:)]));
    maxx = round(max(prime(1,:)));
    miny = round(min([1, prime(2,:)]));
    maxy = round(max(prime(2,:)));
    
    %% Adjust for negatives
%     if minx < 0
%         adjust = -1 * minx + 1;
%         minx = minx + adjust;
%         maxx = maxx + adjust;
%     elseif miny < 0
%         adjust = (-1 * miny) + 1;
%         miny = miny + adjust;
%         maxy = maxy + adjust;
%     end

    [Xprime,Yprime]=meshgrid( minx:maxx, miny:maxy );
    Xprime = reshape(Xprime, [1,numel(Xprime)]);
    Yprime = reshape(Yprime, [1,numel(Yprime)]);
    domainPrime = [Xprime; Yprime; ones(size(Xprime))];

    %% Step 3: Invert the transform matrix
    switch(TransformType)
        case 'scaling'
            Aprime = [1/TransformMatrix(1,1), 0,                       0
                      0,                     1/TransformMatrix(2,2),  0
                      0,                     0,                       1];
            
%             fprintf('Scaling\n');
        case 'rotation'
%             fprintf('Rotation\n');
            Aprime = TransformMatrix .* [1, -1, 1;
                                        -1, 1, 1;
                                        1,  1, 1];
        case 'translation'
%             fprintf('Translation\n');
            Aprime = [1, 0, -1*TransformMatrix(1,3);
                      0, 1, -1*TransformMatrix(2,3);
                      0, 0,  1];
            
        case 'reflection'
%             fprintf('Reflection\n');
            Aprime = TransformMatrix; % The inverse of a reflection is the same 
        case 'shear'
%             fprintf('Shear\n');
            Aprime = [1,                        -1*TransformMatrix(1,2), 0;
                      -1*TransformMatrix(2,1),  1,                       0;
                      0,                        0,                       1 ];
                  
        case 'affine'
%             fprintf('Affine\n');
            % Have Matlab take the inverse
            Aprime = inv(TransformMatrix);
            
        case 'homography'
%             fprintf('Homography\n');
            Aprime = inv(TransformMatrix);
        otherwise
            fprintf('"%s" is not a valid transformation', TransformType)
    end
    
    %% Step 4: Use interpolation
    domain = Aprime * domainPrime;
    
    % We need to scale the domain so that it is in the form [x; y; w] where
    % w = 1
    domain = domain ./ domain(3,:);
    
    % Remove the values from the domain and domain prime that when they are
    % reverse transformed back they are not a part of the original image
    outOfBounds = find(domain(1,:)>=1 & domain(2,:)>=1);
    domain = domain(:,outOfBounds);
    domainPrime = domainPrime(:,outOfBounds);
    
    % Trying to correct for mainting (1,1) in new domain
    outOfBounds = find(domainPrime(1,:)>=1 & domainPrime(2,:)>=1);
    domain = domain(:,outOfBounds);
    domainPrime = domainPrime(:, outOfBounds);
    
%     % Shift the domain for negative values
%     if min(domain(1,:)) < 0
%         shift = (-1 * min(domain(1,:))) + 1;
%         domain(1,:) = domain(1,:) + shift;
%     elseif min(domain(2,:)) < 0
%         shift = (-1 * min(domain(2,:))) + 1;
%         domain(2,:) = domain(2,:) + shift;
%     end
%     
    % Shift the adjusted image domain for negative values
    Xprime = domainPrime(1,:);
    Yprime = domainPrime(2,:);
    if min(Xprime) < 1
        shift = (-1 * min(Xprime)) + 1;
        Xprime = Xprime + shift;
    end
    if min(Yprime) < 1
        shift = (-1 * min(Yprime)) + 1;
        Yprime = Yprime + shift;
    end
    
% Replace domain prime
    domainPrime = [Xprime;
                   Yprime;
                   ones(size(Xprime))];
    
    if minx < 0
        adjust = -1 * minx + 1;
        minx = minx + adjust;
        maxx = maxx + adjust;
    end
    if miny < 0
        adjust = (-1 * miny) + 1;
        miny = miny + adjust;
        maxy = maxy + adjust;
    end
    
    TransformedImage = [];
    
%     Yprime = round(Yprime);
%     Xprime = round(Xprime);
    % Matrix is indexed (row,col) -> (Y, X)
%     TransformedImage(Yprime, Xprime) = InputImage(domain(2,:), domain(1,:));
    if length(InputImage(1,1,:)) > 1
        TransformedImage = zeros(maxy, maxx,length(InputImage(1,1,:)));
    %     newIndices = sub2ind(size(TransformedImage), Yprime, Xprime);
        % Round the domain
        domainPrime = round(domainPrime);

        for i = 1:length(InputImage(1,1,:))
            newIndices = sub2ind(size(TransformedImage), domainPrime(2,:), domainPrime(1,:),i*ones(size(domainPrime(1,:))));
            x = interp2(InputImage(:,:,i), domain(1,:), domain(2,:), 'linear');
            TransformedImage(newIndices) = x;
        end
    else
        TransformedImage = zeros(maxy, maxx);
        domainPrime = round(domainPrime);
        newIndices = sub2ind(size(TransformedImage), domainPrime(2,:), domainPrime(1,:));
        TransformedImage(newIndices) = interp2(InputImage, domain(1,:), domain(2,:), 'linear');
    end
%     TransformedImage() = reshape(interp2(InputImage, domain(2,:), domain(1,:), 'linear'),length(Yprime), length(Xprime));

end