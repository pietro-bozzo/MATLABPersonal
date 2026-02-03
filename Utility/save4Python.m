function save4Python(session,name,A,folder)
% save4Python Save content of A in a mat file
%
% arguments:
%     session    path to session xml file
%     name       variable name for file
%     A          variable to save
%     folder     session subfolder

% Copyright (C) 2026 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  session (1,1) string
  name (1,1) string
  A
  folder (1,1) string = ""
end

[filebase,basename] = fileparts(session);
fname = fullfile(filebase,'Pietro',folder);
if ~isfolder(fname)
  mkdir(fname)
end
fname = fullfile(filebase,'Pietro',folder,basename+"_"+name);
save(fname,'A')