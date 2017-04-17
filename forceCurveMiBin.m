function record=forceCurveMiBin(filename)
%created on 4/26/2014

%forceCurveMiBin read binary Force_Distance
%.mi for picoview
%In force volume mode,this program assume scan from
%bottom to right
%besides copy all the machine information
%data is stored as a cell of chunk
%an element in the cell is a force series
%use [t0,dt,x0,dx] to regenerate time and piezo position

record = struct;
record.filename = filename;
fid = fopen(filename);
tline = fgetl(fid);
chunk_id = 1;
while feof(fid) == 0
    if(strcmp(tline(1:4),'data'));%here come the data
        [chunk_length,~] = size(chunkArray);
        data=cell(chunk_length,2);
        for chunk_id=1:chunk_length
            data{chunk_id,1}=fread(fid,chunkArray(chunk_id,2),'float');
            data{chunk_id,2}=chunkArray(chunk_id,3:6);
        end
        record.data=data;
        break;
    elseif(strcmp(tline(1:4),'grid'));%grid in force volume mode
        sizeB=[1,9];
        B = sscanf(tline(5:end),'%f',sizeB);
        record.grid=B(2:5);
        chunkArray=zeros(record.grid(1)*record.grid(2),7);
    elseif(strcmp(tline(1:5),'chunk'))%chunk for segment data
        chunkArray(chunk_id,:) = sscanf(tline,...
        '%*s\t%d\t%d\t%e\t%e\t%e\t%e\t%*s\t%*s\t%d',[1 Inf]);
        %chunkArray: chunk_id chunk_size t0 dt x0 dx id
        chunk_id = chunk_id + 1;
    else
        [field value] = headerparse(tline);
        if~strcmp(field,'Time (s)	Dista')%ugly code
        record.(field) = value;
        end
    end
    tline = fgetl(fid);
end
fclose(fid);
end

%copy from processmi.m found at www.pico-cafe.com
function [field value] = headerparse(tline)

field = tline(1:14);
value  = tline(15:end);
field = strtrim(field);

end
