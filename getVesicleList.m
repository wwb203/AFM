function experiment = getVesicleList(experiment)
%input,record.Data=topography image
%mouse click input
%output pixelList(row,col)
%Img(row,col),plot(col,row)
%test on 7/11/14
I = imagestrip(experiment.Topography);
%line correction, substract median of line
[y_size, ~]=size(I);
for yid = 1:y_size
    med = median(I(yid, :));
    I(yid, :) = I(yid, :) - med;
end
I = linelevel(I);
%image segmentation
background = imopen(I, strel('disk', 15));
%background correction
I2 = I - background;
%enhance contrast
I3 = imadjust(I2);
%turn into binary image
level = graythresh(I3);
bw = im2bw(I3, level*1.3);
%clean dist
bw = bwareaopen(bw, 50);
%smooth boundary
bw = imopen(bw,strel('disk', 5));
bw = imclearborder(bw);
L = bwlabel(bw, 4);
h = figure;
imshow(L)
title('backsapce to del,return to end')
%click ROI vesicles
%backspace to delete pixel
%enter to end
label = impixel();
label = label(label~=0);%delete background pixel
close(h)
%label = [1;13;14];
label = label(:, 1);
%delete unwanted vesicles
bw2 = zeros(size(L));
for i = 1:length(label)
    bw2 = bw2 + (L==label(i));
end
L = logical(bw2);
%find centroid of vesicles
cc = regionprops(L, 'Centroid');
centroids = floor(cat(1, cc.Centroid));
vesicleNum = length(cc);
vesicleList = struct();
%generate a grid around vesicle center
for i = 1:vesicleNum
    vesicleList(i).center=[centroids(i, 2), centroids(i, 1)];
    tmpPixelList = [];
    for rowId = 1:4:9
        for colId = 1:4:9
            tmpPixel = vesicleList(i).center + [rowId-5, colId-5];
            if bw2(tmpPixel(1), tmpPixel(2))%avoid pixel outside vesicle
                tmpPixelList = cat(1, tmpPixelList, tmpPixel);
            end
        end
    end
    vesicleList(i).PixelList = tmpPixelList;
end
experiment.vesicleList = vesicleList;
%show results for 3 seconds
bw3 = zeros(size(bw2));
for i = 1:vesicleNum
    for j = 1:length(vesicleList(i).PixelList)
        tmpPixel = vesicleList(i).PixelList(j, :);
        bw3(tmpPixel(1), tmpPixel(2)) = 1;
    end
end
Img = imoverlay(I3, bw3, [0,1,0]);
h = figure;
imshow(Img)
pause(3)
close(h)
end
function [record, coefficients] = imagestrip(record, n, windows, show_result)
% record = imagestrip(record) fits a plane to the data in LTSTM-format record and subtracts it.
%
% records = imagestrip(records) works.
%
% imagestrip(record, n) fits a 2D polynomial of order n and subtracts that
%  --> NOTE: this is not implemented correctly; it lacks cross-terms (e.g. xy).
%            However, since in the stm the non-linearity occurs in the y-direction,
%            this still works well.
%
% imagestrip(record, n, window) fits only to a subregion of the data specified
%    by window = [start_row, start_column, end_row, end_column];
%
% imagestrip(record, n, windows) finds the best fit to multiple regions
%    simultaneously, where each region is allowed to have a different
%    height. windows is a n x 4 matrix with columns specified above.
%
% [record, coefficients] = ... returns the coefficients for the fit. The
%    format is [a1 a2 a3 ... an b1 b2 b3 ... bn c], where an is the
%    coefficient of x^n, bn that of y^n and c the constant offset. 
%
%    If there are multiple windows specified, there will be additional c's -- one for
%    each window. The constant subtracted from the record will be the mean
%    of these c's, weighted by the area of each window.
%
% record does not have to be a LTSTM record; it also works with any matrix
%
% Created by CRM 4/6/2006
% CRM Added n and window 5/18/2006
% CRM Added support for multiple windows 5/23/2006
% CRM Added support for imagestrip(records) 10/8/2006

if nargin < 1
    error('Please specify a record or surface to strip.');
end

if nargin < 4, show_result = 0; end

% handle multiple records
if isstruct(record) && length(record) > 1
    for i=1:length(record)
        switch nargin
            case 1
                record(i) = imagestrip(record(i));
            case 2
                record(i) = imagestrip(record(i), n);
            case 3
                record(i) = imagestrip(record(i), n, windows);
        end
    end
    return;
end


if nargin == 1
    n = 1;
end

if isstruct(record)
    Z = record.Data;
else
    Z = record;
end


if nargin < 3
    windows = [1 1 size(Z, 1) size(Z, 2)];
end

if size(Z, 1) == 1   % There is only one row
    disp('   Warning: imagestrip does not support 1D data. Data is unchanged.');
    return; % do nothing
end


% Make the start rows and columns < the end rows and columns
windows(:,[1 3]) = sort(windows(:,[1 3]),2);
windows(:,[2 4]) = sort(windows(:,[2 4]),2);

[X, Y] = meshgrid(1:size(Z, 2), 1:size(Z, 1));

XY1 = [];
all_Z_to_fit = [];
n_windows = size(windows, 1);

% Now create the giant matrix that will be used for the fit, one window at
% a time.
for i = 1:n_windows
    
    window = windows(i,:);
    
    % construct a matrix XY1 so that we can find the best solution for
    %   [a1 a2 ... an b1 b2 ... bn c] * [x; x^2; ... x^n; y; y^2; ... y^n; 1] = Z
    
    X_to_fit = X(window(1):window(3), window(2):window(4));
    Y_to_fit = Y(window(1):window(3), window(2):window(4));
    Z_to_fit = Z(window(1):window(3), window(2):window(4));
    
    X_to_fit = cumprod(repmat(X_to_fit(:), [1 n]), 2);
    Y_to_fit = cumprod(repmat(Y_to_fit(:), [1 n]), 2);
    
    % This list will enforce that each region has its own dc offset
    offsets = zeros(1,n_windows);
    offsets(i) = 1;
    
    new_XY1 = [X_to_fit  Y_to_fit  ones(numel(Z_to_fit),1)*offsets];
    
    XY1 = [XY1; new_XY1];
    all_Z_to_fit = [all_Z_to_fit; Z_to_fit(:)];
end

% X = A\B is the solution to the equation AX = B computed by Gaussian elimination 
coefficients = XY1 \ all_Z_to_fit(:);


% Calculate the surface over the entire data
X = cumprod(repmat(X(:), [1 n]), 2);
Y = cumprod(repmat(Y(:), [1 n]), 2);

XY1 = [X Y ones(numel(Z),1)];

% For the subtraction, use the mean of the coeffients for each window,
% weighted by the size of that window

% Compute how big each window is
window_areas = prod(windows(:,3:4) - windows(:,1:2),2);

% Compute the weighted mean
cs = coefficients(end - n_windows + 1 : end);
c = sum(cs .* window_areas) / sum(window_areas(:));

surface_coefficients = [coefficients(1:end - n_windows); c];

surface = reshape(XY1 * surface_coefficients, size(Z));

% strip the surface from the record
Z = Z - surface;

% If a record was passed in, return a record
if isstruct(record)
    record.Data = Z;
else
    record = Z;
end


if show_result
    figure;
    surf(Z + surface);
    hold on;
    surf(surface);
end

end

function levelImg = linelevel(img)
% LINELEVEL Level the rows of a matrix to zero mean value.
%   LEVELIMG = LINELEVEL(IMG) Takes the 2D array IMG and subtracts the
%   mean value of each row from that row, leveling the rows such that the
%   mean value of each is zero.

% 7/7/11 PVS

means = mean(img,2); %Column vector of means of each row

offset = repmat(means,1,size(img,2));  %Matrix of these mean values to be subtracted from original image

levelImg = img - offset;
end