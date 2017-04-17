function moveToPix(Pixel)
%move to pixel
%input Pixel(row,col)
%convert to picoscript format
%safety: XY check pixel range
%        Z none
imgH = GetScanXPixels() + 1;%(eg, 512 pixels are coded as 511)
x1 = Pixel(2)-1;
y1 = imgH-Pixel(1);
x1 = floor(x1);
y1 = floor(y1);
%safety check
if (x1<0)||(x1>(imgH-1))||(y1<0)||(y1>(imgH-1))
    error('pixel coordinate out of range');
end
%exe 
SetTipPosition(x1, y1);
WaitForStatusScanPixel(x1);
WaitForStatusScanLine(y1);
end
