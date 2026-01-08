function ci = vonMisesCredibleInt(phi,opt)
% vonMisesCredibleInt Estimate Bayesian credible intervals for the probability of success from data modeled as a Bernoulli process
%
% assuming
% phi: directional data, theta: data, theta: parameter, a: prior number of successes, b: prior number of failures
% likelihood: p(phi,eta) ~ exp(eta*t - log(I0(||eta||))), t = (cos(phi),sin(phi)), eta = kappa * (cos(mu),sin(mu))
% prior: p(eta) ~ exp(eta*s - nu*log(I0(||eta||))), nu > 0, s in R^2, ||s|| < nu
% then
% posterior: p(theta,X) ~ Beta(a+x,b+n-x)
%
% arguments
%     x        double, number of successes
%     n        double, number of trials
%     a        double = 1/3, firstbeta prior parameter, default is "neutral" prior proposed in J. Kerman 2011
%     b        double = 1/3, second beta prior parameter
%
% name-value arguments
%     alpha    double = 95, credible interval percentage (%)

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

arguments
  phi
  a = 1/3
  b = 1/3
  opt.alpha = 95
end

% compute sufficient statistics
T = [sum(cos(phi)),sum(sin(phi))];

pd = makedist('Beta','a',a+x,'b',b+n-x);
ci = icdf(pd,1/2 + opt.alpha/200*[-1,1]);

% visualize posterior
% plot(pd)