function experiment=topographyMiBin(filename)
%created on 6/9/14
%assumes first image is topography
%TopographyMiBin read binary Agilent Image
%.mi for picoview
%this program assumes scan rightwards,upwards.
%besides copy all the machine information
%data is stored as a matrix experimenting surface topography
%test on 7/11/14
experiment = struct;
experiment.filename = filename;
fid = fopen(filename);
tline = fgetl(fid);
chunk_id = 1;
bufferlabel_flag=0;
while feof(fid) == 0
    if(strcmp(tline(1:4),'data'));%here come the data
        [field value] = headerparse(tline);
        size(value)
        eval(sprintf('experiment.%s = value;',field));
        break;
    elseif(strcmp(tline(1:11), 'bufferLabel'))
        bufferlabel_flag = bufferlabel_flag+1;
    elseif bufferlabel_flag<2
        [field, value] = headerparse(tline);
        experiment.(field) = value;
    end
    tline = fgetl(fid);
end
experiment.Topography = imageparse(experiment, fid); 
h = figure;
imagesc(experiment.Topography)
pause(3)
close(h)
fclose(fid);

end
function data = imageparse(experiment,fid)
%copy from processmi.m for pico-cafe.com
xpixels = str2num(experiment.xPixels);
ypixels = str2num(experiment.yPixels);
%Handle different bit resolutions for data
if ( strcmp(experiment.data,'BINARY') || strcmp(experiment.data,'BINARY_16') )
    data = fread(fid, xpixels*ypixels, 'int16');
    data = reshape(data, xpixels, ypixels);
    data = data*str2double(experiment.bufferRange)/(2^16/2);
elseif strcmp(experiment.data,'BINARY_32')
    data = fread(fid, xpixels*ypixels, 'int32');
    data = reshape(data, xpixels, ypixels);
    data = data*str2double(experiment.bufferRange)/(2^32/2);
else
    error('Unrecognized data type.  The "data" field in the .mi file is not BINARY, BINARY_16, or BINARY_32.')
end

data = flipud(data');

end
%copy from processmi.m found at www.pico-cafe.com
function [field,value] = headerparse(tline)

field = tline(1:14);
value  = tline(15:end);
field = strtrim(field);

end
