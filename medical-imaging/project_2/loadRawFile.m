% Helper function to load raw file
function raw = loadRawFile(filename)
    fid = fopen(filename, 'r', 'l');
    raw = fread(fid, Inf, 'uint16');
    fclose(fid);
end