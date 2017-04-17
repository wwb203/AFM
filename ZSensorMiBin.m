function experiment=ZSensorMiBin(filename)
%created on 6/9/14
%TopographyMiBin read binary Agilent Image
%.mi for picoview
%this program assumes scan rightwards,upwards.
%besides copy all the machine information
%images of different channels stored in bufferList
%Z Sensor Trace = Topography.
experiment = struct();
experiment.filename = filename;
fid = fopen(filename);
tline = fgetl(fid);
bufferId = 0;
bufferList = struct();
while feof(fid) == 0
    if(strcmp(tline(1:4),'data'));%here come the data
        [field, value] = headerparse(tline);
        eval(sprintf('experiment.%s = value;',field));
        break;
    elseif(strcmp(tline(1:11), 'bufferLabel'))
        bufferId = bufferId + 1;
        [~, value] = headerparse(tline);
        bufferList(bufferId).bufferLabel = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).filter = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).direction = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).acqMode = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).bufferRange = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).bufferUnit = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).DisplayRange = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).DisplayOffset = value;
        tline = fgetl(fid);
        [~, value] = headerparse(tline);
        bufferList(bufferId).trace = value;
    else
        [field, value] = headerparse(tline);
        eval(sprintf('experiment.%s = value;',field));
    end
    tline = fgetl(fid);
end
bufferNum = bufferId;
for bufferId = 1:bufferNum
    bufferList(bufferId).data = experiment.data;
    bufferList(bufferId).xPixels = experiment.xPixels;
    bufferList(bufferId).yPixels = experiment.yPixels;
    bufferList(bufferId).Img = imageparse(bufferList(bufferId), fid);
end
fclose(fid);
experiment.bufferList = bufferList;
%display Raw_Defl Trace Img
for bufferId = 1:bufferNum
    if(strcmp(bufferList(bufferId).bufferLabel, 'Z_Sensor')&&...
            strcmp(bufferList(bufferId).trace, 'Trace'))
        bufferId
        Img = bufferList(bufferId).Img;
    end
end
experiment.Topography = Img;
h = figure;
imagesc(Img)
pause(3)
close(h)
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
function [field,value] = headerparse(tline)
field = tline(1:14);
value  = tline(15:end);
field = strtrim(field);
end