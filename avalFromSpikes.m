function [sizes,intervals,timeDependentSize] = avalFromSpikes(spikes,window,smooth,threshold)
% avalFromSpikes Compute avalanches from spiking data
%
% arguments:
%     spikes       (n_spikes,1) double, spike time stamps (s)
%     window       double, time bin (s) for avalanche computation
%     smooth       double = 1, gaussian kernel std in number of samples, default is no smoothing
%     threshold    double = 30, percentile of population firing rate for avalanche computation

arguments
  spikes (:,1) {mustBeNumeric}
  window (1,1) {mustBeNumeric,mustBePositive}
  smooth (1,1) {mustBeNumeric,mustBeGreaterThanOrEqual(smooth,1)} = 1
  threshold (1,1) {mustBeNumeric,mustBeNonnegative} = 30
end

% population firing rate
fr = Frequency(spikes,'limits',[min(spikes),max(spikes)],'binSize',window,'smooth',smooth/5); % smooth / 5 is used to compensate for behavior of Frequency
profile = fr(:,2);

% threshold it
threshold = prctile(profile,threshold);
profile = profile - threshold;
profile(profile<0) = 0;

% compute sizes
ind = [true; profile(2:end)~=0 | profile(1:end-1)~=0]; % ind(i) = 0 if i is repeated zero
clean = profile(ind); % remove repeated zeros
sizes = accumarray(cumsum(clean==0)+(profile(1)~=0),clean);
timeDependentSize = clean;
if sizes(end) == 0 % remove last zero
  sizes = sizes(1:end-1);
end

% compute avalanche start and end times
intervals = [find([profile(1)~=0; profile(2:end)~=0 & profile(1:end-1)==0]) - 1, find([profile(2:end)==0 & profile(1:end-1)~=0; profile(end)~=0])] * window;