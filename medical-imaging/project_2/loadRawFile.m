% Helper function to load raw file
function raw = loadRawFile(filename)
    fid = fopen(filename, 'r');
    raw = fread(fid, 'uint16', 'ieee-le');
    fclose(fid);
end