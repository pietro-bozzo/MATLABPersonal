function varargout = unpackArgs(options)
% unpackArgs Unpack Name-Value Arguments structure (used by MATLAB to provide Name-Value argument validation)
%
% arguments:
%     options      struct, each field is an optional argument and contains its value
%
% output:
%     varargout    values of all Name-Value Arguments in options structure
%
% usage:
%
%     % example arguments block inside a function
%     arguments
%       opt.a (1,1) char = 'v'
%       opt.b (1,3) double {mustBeNonnegative} = [0,0,0]
%       opt.c (:,1) double {mustBeNonnegative} = []
%     end
%     % unpack to have variables in function workspace
%     [a,b,c] = unpackArgs(opt)

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  options (1,1) struct
  % default_values (1,1) struct TO IMPLEMENT
end

names = fieldnames(options);

for i = 1 : numel(names)
  varargout{i} = options.(names{i});
end