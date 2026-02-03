function name = fileName(file_path)
% fileName

[~,name,extension] = fileparts(file_path);
name = append(name,extension);