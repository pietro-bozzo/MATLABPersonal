function x = circularSmooth(x,dim,varargin)
% circularSmooth Smooth circular data, handling border effects
%
% arguments
%     x           data
%     dim         double = [], dimension along which to operate, default is first non-singleton dimension
%     varargin    all extra arguments are passed to smoothdata

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  x
  dim = []
end
arguments (Repeating)
  varargin
end

% parse arguments
if isText(dim)
  % if user omitted dim and specified a method
  varargin = [dim,varargin];
  dim = [];
end
if isempty(varargin)
  varargin = {'gaussian',10};
end

% default dim value
n = size(x);
if isempty(dim)
  dim = find(n~=1,1);
end

% smooth
x = repmat({x},1,3); % make three copies of x
try
  x = cat(dim,x{:}); % concatenate along desired dimension
  x = smoothdata(x,dim,varargin{:});
catch ME
  throw(ME)
end

% restore size of x
if dim > numel(n)
  error('circularSmooth:dimValue','Argument ''dim'' exceeds the number of dimensions of ''x''')
end
idx = repmat({':'},1,numel(n)); % n-dimensional indexing
idx{dim} = n(dim)+1 : 2*n(dim); % slice smoothing dimension
x = x(idx{:});