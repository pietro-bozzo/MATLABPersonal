function BF = binomialBFTest(x1,n1,x2,n2,a,b)
% binomialBFTest Compute the Bayesian factor between modeling two datasets as two independent Bernoulli processes versus a single one
%
% assuming for model i (e.g., one overall model for the combined datasets):
%   xi: number of successes, ni: number of trials, Xi: data, thetai: parameter, a: prior number of successes, b: prior number of failures
%   likelihood: p(Xi,thetai) ~ Bernoulli(thetai)
%   prior: p(thetai) ~ Beta(a,b)
%   posterior: p(thetai,Xi) ~ Beta(a+xi,b+ni-xi)
% then
%   model evidence: int(likelihood * prior) dthetai = (n x) * Beta(a+xi,b+ni-xi) / Beta(a,b)
%   with (n x) = n! / (x! (n-x)!) the binomial coefficient
% and to evaluate the Bayesian factor:
%    BF = evidence(overall) / (evidence(1) * evidence(2))
%
% arguments
%     x1    double, number of successes
%     n1    double, number of trials
%     x2    double, number of successes
%     n2    double, number of trials
%     a     double = 1/3, first beta prior parameter, default is "neutral" prior proposed in J. Kerman 2011
%     b     double = 1/3, second beta prior parameter

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  x1
  n1
  x2
  n2
  a = 1/3
  b = 1/3
end

% compute evidence, except for the binomial coefficients
BF = evidence(x1+x2,n1+n2,a,b) / evidence(x1,n1,a,b) / evidence(x2,n2,a,b);

% WRONG: binomial coefficients cancel because in both cases they are (n1 x1) * (n2 x2), as they do not depend on the parameter
% a product of binomial coefficients completes the calculation, let (a b) = a! / (b! (a-b)!) be the binomial coefficient, then we must compute:
%
% (n1+n2 x1+x2) / (n1 x1) / (n2 x2) =
%
%     x1! (n1-x1)!    x2! (n2-x2)!         (n1+n2)!
% = --------------- --------------- -------------------------
%         n1!             n2!        (x1+x2)! (n1+n2-x1-x2)!
%
% recalling:
%
% a! / b! = a * (a-1) * ... * (a-b+1)
%
% we can simplify factorials from the numerator and denominator

% num = sort([x1,n1-x1,x2,n2-x2,n1+n2],'descend');
% den = sort([n1,n2,x1+x2,n1+n2-x1-x2],'descend');
% 
% mult = []; % numbers to multiply
% div = []; % numbers to divide
% for i = 1 : 4
%   if num(i) > den(i)
%     mult = [mult,num(i) : -1 : den(i)+1];
%   else
%     div = [div,den(i) : -1 : num(i)+1];
%   end
% end
% mult = [mult,num(end):-1:1]; % if necessary, intersect(mult,div) can be removed from both arrays
% 
% p = vpa(1);
% for i = 1 : min(numel(mult),numel(div))
%   p = p * mult(i) / div(i);
% end
% p = p * prod(mult(i+1:end)) / prod(div(i+1:end));

%BF = double(BF * p); % restore double precision
%BF = double(BF); % restore double precision

end

% --- helper functions ---

function e = evidence(x,n,a,b)
% compute evidence for a Binomial model, excluding the binomial coefficient, use high precision numbers to avoid numerical cancellation

  e = beta(vpa(x+a),vpa(n-x+a)) / beta(vpa(a),vpa(b));

end