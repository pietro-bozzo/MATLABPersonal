function structure = reverseCellStruct(x,field_f,cat_f)
% reverseCellStruct Given a cell array of structs sharing the same fields, concatenate them into fields of a struct
%
% arguments:
%     x          (n,1) cell, each cell containing a struct
%     field_f    function handle, optional, applied to each field value before concatenation; must accept and return one input
%     cat_f      function handle, optional, called to concatenate field values across cells; must accept a cell array of
%                   field values and return a concatenated result, default is @(y) vertcat(y{:})

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  x cell
  field_f function_handle = @(x) x
  cat_f function_handle = @(x) vertcat(x{:})
end

x = x(~cellfun(@isempty, x));

if isempty(x)
  structure = struct;
  return
end

for field = fieldnames(x{1})'
  temp = cellfun(@(y) field_f(y.(field{1})),x,'UniformOutput',false);
  structure.(field{1}) = cat_f(temp);
end