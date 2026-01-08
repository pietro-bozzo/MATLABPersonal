function [p,h,z] = twoProportionsZ(x1,n1,x2,n2,opt)
%
% 'left' tests the null hypothesis that data from population 1 have smaller proportion

arguments
  x1
  n1 {mustBeGreaterThanOrEqual(n1,x1)}
  x2
  n2 {mustBeGreaterThanOrEqual(n2,x2)}
  opt.tail (1,1) string {mustBeMember(opt.tail,["right","left","both"])} = "both"
  opt.alpha (1,1) {mustBeNumeric} = 0.05
end

p1 = x1 / n1;
p2 = x2 / n2;
p_tot = (x1+x2) / (n1+n2);

% test statistic
z = (p1-p2) / sqrt(p_tot*(1-p_tot)*(1/n1+1/n2));

% p-value
p = normcdf(z);

if opt.tail == "left"
  p = 1 - p;
elseif opt.tail == "both"
  p = 2 * p;
  p(p>1) = 2 - p(p>1);
end

h = p < opt.alpha;