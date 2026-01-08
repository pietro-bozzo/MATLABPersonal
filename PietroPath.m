function path = PietroPath()
% PietroPath Get path to main folder Pietro, provided that this function is in one of its subfolders

split = strsplit(fileparts(mfilename('fullpath')),'Pietro');
if size(split,2) < 2
    error('Unable to get path to Pietro folder')
end
path = [split{1},'Pietro'];