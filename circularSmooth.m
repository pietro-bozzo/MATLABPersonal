function x = circularSmooth(x,dim,varargin)
% circularSmooth Smooth circular data, handling border effects

arguments
  x
  dim {mustBeNumeric,mustBeInteger,mustBePositive} = []
end
arguments (Repeating)
  varargin
end

if isempty(varargin)
  varargin = {'gaussian',10};
end

n = size(x);
if isempty(dim)
  dim = find(n~=1,1);
end

if dim == 1
  x = [x;x;x];
elseif dim == 2
  x = [x,x,x];
else
  error('Not implemented!')
end

try
  x = smoothdata(x,dim,varargin{:});
catch ME
  throw(ME)
end

if dim == 1
  x = x(n(1)+1:2*n(1),:);
else
  x = x(:,n(2)+1:2*n(2));
end