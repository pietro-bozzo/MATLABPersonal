function [samples,originalIndex,intervalID] = myRestrict(samples,intervals)
% myRestrict Keep only samples that fall in a given list of time intervals
%
% arguments:
%     samples          (n_samples,n_vars), either a column vector of time stamps or a matrix having in each row
%                      [time,value] of a sample
%     intervals        (2,n_intervals) double, each column is a [start;stop] interval
%
% output:
%     samples          (n_valid_samples,1), samples which fell into an interval
%     originalIndex    (n_valid_samples,1) double, indeces of valid samples in the original samples, i.e.,
%                      >> samples = original_samples(originalIndex)
%     intervalID       (n_valid_samples,1) double, indeces of interval each valid sample belongs to

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% NOTE ON DIFFERENCE with Restrict: samples having t == intervals(j,2) are excluded

arguments
  samples (:,:)
  intervals (2,:) {mustBeNumeric}
end

% assign and index to each sample time, only odd indeces belong to intervals
ind = discretize(samples(:,1),intervals(:));

% identify samples to keep
valid_ind = mod(ind,2) == 1;

% get index of samples to keep in original samples
originalIndex = find(valid_ind);

% restrict samples
samples = samples(originalIndex,:);

% get index of interval for every valid sample
if nargout > 2
  intervalID = (ind(valid_ind) + 1) / 2;
end