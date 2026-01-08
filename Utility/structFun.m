function s = structFun(func,a,b,opt)
% structFun

arguments
  func {mustBeA(func,'function_handle')}
  a {mustBeA(a,'struct')}
  b {mustBeA(b,'struct')} = struct.empty
  opt.UniformOutput {mustBeLogical} = true
end

if isempty(b)
  % built-in call of structfun

  try
    s = structfun(func,a,'UniformOutput',opt.UniformOutput);
  catch ME
    throw(ME)
  end

else

  for field = fieldnames(a)'
    s.(field{1}) = func(a.(field{1}),b.(field{1}));
  end

  if opt.UniformOutput && all(structfun(@isscalar,s))
    s = structfun(@(x) x,s);
  end

end