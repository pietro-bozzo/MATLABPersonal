function [stats,distr,distr_orig,shuffled] = circEntrainment(x,reference,opt)

arguments
  x (:,1) {mustBeNumeric}
  reference (:,:) {mustBeNumeric} = []
  opt.mode (1,1) string {mustBeMember(opt.mode,["time","phase"])} = "time"
  opt.n_bins (1,1) {mustBeNumeric,mustBeInteger,mustBePositive} = 250
  opt.phase_dist (:,1) {mustBeNumeric} = [] % MUST have domain [0,2*pi]
  opt.intervals (:,2) {mustBeNumeric} = []
  opt.shuffle (:,:) {mustBeNumeric} = []
  opt.alpha (1,1) {mustBeNumeric,mustBeNonnegative} = 0.05
end

% 1. distribution of phase values, corrected by prevalence of every phase bin

if opt.mode == "time"

  if size(reference,2) ~= 2
    error('circEntrainment:refSize','In ''time'' mode, ''reference'' must have two columns')
  end

  % phase of each event
  phases = interp1(reference(:,1),reference(:,2),x);
  
  % distribution of reference phase values
  if isempty(opt.phase_dist)
    [dist_phase,bins_phase] = CircularDistribution(reference(:,2),'nBins',opt.n_bins,'normalize','pdf');
  else
    dist_phase = opt.phase_dist;
  end
  
else

  if isempty(reference)
    reference = ones(opt.n_bins,1);
  elseif size(reference,2) ~= 1
    error('circEntrainment:refSize','In ''phase'' mode, ''reference'' must have one column')
  end
  phases = x;
  dist_phase = reference;

end
[distr_orig,stats.R0,stats.phi0,distr,stats.R,stats.phi] = correctDistr(phases,dist_phase);

if isempty(opt.shuffle)
  shuffled = [];
  return
end

% 2. repeat on shuffled data

if opt.mode == "time"

  if ~isscalar(opt.shuffle) || rem(opt.shuffle,1) || opt.shuffle < 0
    error('circEntrainment:shuffle','In ''time'' mode, ''shuffle'' must be a non-negative integer')
  end

  % shift to shuffle
  if isempty(opt.intervals)
    times_shifted = x;
  else
    times_shifted = Restrict(x,opt.intervals,'shift','on');
  end

  % declare variables
  shuffled.times = zeros(size(times_shifted,1),opt.shuffle);
  shuffled.phase = zeros(size(times_shifted,1),opt.shuffle);
  shuffled.distr = zeros(numel(dist_phase),opt.shuffle);
  shuffled.R0 = zeros(opt.shuffle,1);
  shuffled.phi0 = zeros(opt.shuffle,1);
  shuffled.R = zeros(opt.shuffle,1);
  shuffled.phi = zeros(opt.shuffle,1);

  for k = 1 : opt.shuffle
    shuffled.times(:,k) = shuffleSpikes(times_shifted);
    if ~isempty(opt.intervals)
      shuffled.times(:,k) = Unshift(shuffled.times(:,k),opt.intervals);
    end
    shuffled.phase(:,k) = interp1(reference(:,1),reference(:,2),shuffled.times(:,k));
    [~,shuffled.R0(k),shuffled.phi0(k),shuffled.distr(:,k),shuffled.R(k),shuffled.phi(k)] = correctDistr(shuffled.phase(:,k),dist_phase);
  end

else

  % SEEMS NON NECESSARY
  % if size(opt.shuffle,1) ~= numel(phases)
  %   error('circEntrainment:shuffle','In ''phase'' mode, ''shuffle'' must have one row for each element of ''x''')
  % end

  shuffled.phase = opt.shuffle;
  shuffled.distr = zeros(numel(dist_phase),size(opt.shuffle,2));
  shuffled.R0 = zeros(size(opt.shuffle,2),1);
  shuffled.phi0 = zeros(size(opt.shuffle,2),1);
  shuffled.R = zeros(size(opt.shuffle,2),1);
  shuffled.phi = zeros(size(opt.shuffle,2),1);

  for k = 1 : size(opt.shuffle,2)
    [~,shuffled.R0(k),shuffled.phi0(k),shuffled.distr(:,k),shuffled.R(k),shuffled.phi(k)] = correctDistr(shuffled.phase(:,k),dist_phase);
  end

end

% H0: shuffled events can produce R as high as observed
stats.p = MCpValue(shuffled.R,stats.R,'greater');
stats.h = stats.p < opt.alpha;

end

% --- helper functions ---

function [distr0,R0,phi0,distr,R,phi] = correctDistr(phase,reference_distr)

  % distribution of phase values
  [distr0,bins_unit,statistics] = CircularDistribution(phase,'nBins',numel(reference_distr),'normalize','pdf');
  R0 = statistics.r;
  phi0 = modulo(statistics.m,0,2*pi);

  % correct distribution by prevalence of every phase bin
  distr = distr0 ./ reference_distr;
  distr = distr / trapz(bins_unit,distr); % normalize to get pdf

  % estimate Z from pdf
  Z = trapz(bins_unit,exp(1i*bins_unit).*distr);
  R = abs(Z);
  phi = modulo(angle(Z),0,2*pi);

end

% --- extra code to plot examples in debug mode

function plotInDebug()
  % this function is not meant to be called, rather its code can be executed in debug mode to produce plots

  bins_phase = linspace(0,2*pi,numel(dist_phase)+1).';
  bins_phase = (bins_phase(1:end-1)+bins_phase(2:end)) / 2;
  
  %% plot phase distribution
  makeFigure('distr',"Phase distribution");
  plot(bins_phase,dist_phase,'Color',[0.7,0.7,0.7],'DisplayName','reference phase')
  plot(bins_phase,distr_orig,'Color',myColors(1),'DisplayName','events phase')
  plot(bins_phase,distr,'Color',myColors(2),'DisplayName','corrected events phase')
  xlim([0,2*pi]), xticks([0,pi/2,pi,3*pi/2,2*pi]), xticklabels(["0","π/2",'π','3π/2','2π']), xlabel('phase (rad)'), ylabel('p(phase)'), legend

  %% polar plot of original data for significance test
  makeFigure('signif',"Significance test, p: "+string(stats.p),polar=true);
  l = 1;
  for k = 1 : 5 : size(shuffled.phase,2)
    hs(l) = polarhistogram(shuffled.phase(:,k),50,'Normalization','pdf','EdgeColor',myColors(2),'EdgeAlpha',0.5,'DisplayStyle','stairs','LineWidth',1.1,'DisplayName','shuffled'); l = l + 1; end
  for k = 1 : size(shuffled.phase,2)
    polarscatter(shuffled.phi0(k),shuffled.R0(k),75,'filled','MarkerFaceAlpha',0.2,'MarkerFaceColor',myColors(2)); end
  h(1) = polarplot(bins_phase,dist_phase,'Color',[0.7,0.7,0.7],'LineWidth',1.3,'DisplayName','reference');
  h(2) = polarhistogram(phases,50,'Normalization','pdf','EdgeColor',myColors(1),'DisplayStyle','stairs','LineWidth',1.3,'DisplayName','uncorrected');
  polarscatter(stats.phi0,stats.R0,75,'filled','MarkerFaceAlpha',1,'MarkerFaceColor',myColors(1))
  legend([h(2),hs(1),h(1)]); clear k l h hs; rlim([0,0.4])

  %% polar plot of corrected data for significance test
  makeFigure('signif',"Significance test, p: "+string(stats.p),polar=true);
  l = 1;
  for k = 1 : 5 : size(shuffled.phase,2)
    hs(l) = polarplot(bins_phase,circularSmooth(shuffled.distr(:,k),[],'gaussian',5),'Color',myColors(2),'LineWidth',1.1,'DisplayName','shuffled'); l = l + 1; end
  for k = 1 : size(shuffled.phase,2)
    polarscatter(shuffled.phi(k),shuffled.R(k),75,'filled','MarkerFaceAlpha',0.2,'MarkerFaceColor',myColors(2)); end
  h(1) = polarplot(bins_phase,dist_phase,'Color',[0.7,0.7,0.7],'LineWidth',1.3,'DisplayName','reference');
  h(2) = polarplot(bins_phase,circularSmooth(distr,[],'gaussian',5),'Color',myColors(1),'LineWidth',1.3,'DisplayName','corrected');
  polarscatter(stats.phi,stats.R,75,'filled','MarkerFaceAlpha',1,'MarkerFaceColor',myColors(1))
  legend([h(2),hs(1),h(1)]); clear k l h hs

  %% plot event pdf, corrected and not
  makeFigure('stats',"Phase pdf, p: "+string(stats.p),polar=true);
  h(1) = polarplot(bins_phase,dist_phase,'Color',[0.7,0.7,0.7],'LineWidth',1.3,'DisplayName','reference');
  h(2) = polarhistogram(phases,50,'Normalization','pdf','EdgeColor',myColors(1),'DisplayStyle','stairs','LineWidth',1.3,'DisplayName','uncorrected');
  polarscatter(stats.phi0,stats.R0,75,'filled','MarkerFaceAlpha',0.7,'MarkerFaceColor',myColors(1))
  h(3) = polarplot(bins_phase,circularSmooth(distr,[],'gaussian',5),'Color',myColors(2),'LineWidth',1.3,'DisplayName','corrected');
  polarscatter(stats.phi,stats.R,75,'filled','MarkerFaceAlpha',0.7,'MarkerFaceColor',myColors(2))
  rticks([0.2,0.4]), rlim([0,0.5]), legend(h(3:-1:1))

end