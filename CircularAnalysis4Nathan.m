% Pietro's methods to analyse circular data

% phase of slow rhythm
% set up phase values at extremes and mid-points of oscillations
% A: time stamps for 3*pi/2, B: time stamps for pi/2
phase = [A,mean([A,B],2),B,[mean([B(1:end-1),A(2:end)],2);NaN]].';
phase = [phase(1:2,:);phase(2,:)+0.001;phase(3:4,:)];
phase = [phase(:),repmat([3*pi/2;2*pi;0;pi/2;pi],size(A,1),1)];
phase = phase(1:end-1,:);
% phase(t)
phase = Interpolate(phase,0:0.005:phase(end,1));

% plot phase to check
figure
PlotXY(phase)
% ADD plot of smoothed signal

% compute distribution of phase, if not uniform it must be used to correct analysis
n_bins = 250; % high number to estimate pdf correction
[dist_phase,bins_phase] = CircularDistribution(phase(:,2),'nBins',n_bins,'normalize','pdf');

% declare variables
% E.G., units is [1,3,4,5,7,8]
distr = nan(numel(units),n_bins);
distr_orig = nan(numel(units),n_bins);
phase_unit = cell(numel(units),1);
for i = ["R0","phi0","R","phi","p","h"]
  stats.(i) = nan(numel(units),1);
end

% analyse
for i = 1 : numel(units)
  spikes_unit = spikes(spikes(:,2)==units(i),1);
  if numel(spikes_unit) < 100
    continue
  end

  % phase of each spike
  P = Interpolate(phase,spikes_unit);
  phase_unit{i} = P(:,2);
  % distribution of unit-spike phase values
  [distr_orig(i,:),stats.R0(i),stats.phi0(i),distr(i,:),stats.R(i),stats.phi(i)] = correctDistr(phase_unit{i},dist_phase);

  % repeat on shuffled spikes
  shuffled.spikes = zeros(numel(spikes_unit),opt.shuffle);
  shuffled.phase = zeros(numel(spikes_unit),opt.shuffle);
  shuffled.distr = zeros(n_bins,opt.shuffle);
  shuffled.R0 = zeros(opt.shuffle,1);
  shuffled.phi0 = zeros(opt.shuffle,1);
  shuffled.R = zeros(opt.shuffle,1);
  shuffled.phi = zeros(opt.shuffle,1);
  for k = 1 : opt.shuffle
    SS = Restrict(spikes_unit,us_intervals,'shift','on');
    shuffled.spikes(:,k) = Unshift(shuffleSpikes(SS),us_intervals);
    SP = Interpolate(phase,shuffled.spikes(:,k),'trim','off');
    shuffled.phase(:,k) = SP(:,2);
    [~,shuffled.R0(k),shuffled.phi0(k),shuffled.distr(:,k),shuffled.R(k),shuffled.phi(k)] = correctDistr(shuffled.phase(:,k),dist_phase);
  end
  % H0: shuffled spikes can produce R as high as observed
  stats.p(i,1) = 1 - percentRank(shuffled.R,stats.R(i));

end
stats.h = holmBonferroni(stats.p);

% --- helper functions ---
% DECLARE this function somewhere in your code

function [distr0,R0,phi0,distr,R,phi] = correctDistr(phase,reference_distr)
  % distribution of unit-spike phase values
  [distr0,bins_unit,statistics] = CircularDistribution(phase,'nBins',numel(reference_distr),'normalize','pdf');
  R0 = statistics.r;
  phi0 = statistics.m;

  % correct distribution by prevalence of every phase bin
  distr = distr0 ./ reference_distr;
  distr = distr / trapz(bins_unit,distr); % normalize to get pdf

  % estimate Z from pdf
  Z = trapz(bins_unit,exp(1i*bins_unit).*distr);
  R = abs(Z);
  phi = angle(Z);
end