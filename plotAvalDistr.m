function plotAvalDistr(data,opt)
% plotAvalDistr Plot avalanches size or duration distribution

arguments (Repeating)
  data (:,1) double
end
arguments
  opt.log (1,1) {mustBeLogical} = false
  opt.labels (:,1) string = []
  opt.colors (:,3) {mustBeNumeric,mustBeNonnegative,mustBeLessThanOrEqual(opt.colors,1)} = myColors(1:numel(data))
  opt.var (1,1) string = 'S' % name of the quantity plotted
  opt.type (1,1) string = 'pdf'
  opt.verbose (1,1) {mustBeLogical} = false
  opt.ax (1,1) matlab.graphics.axis.Axes = gca % figure axes
end

if ~isempty(opt.labels) && numel(data) ~= numel(opt.labels)
  error('plotAvalDistrOnAxis:labelsNumber','Number of labels must equal number of data vectors')
end
if numel(data) ~= size(opt.colors,1)
  error('plotAvalDistrOnAxis:colorNumber','Number of colors must equal number of data vectors')
end

n_bins_ref = 100;
range_ref = 10;
for i = 1 : numel(data)
  if opt.log
    % plot distribution of log(data) on linear axis
    [counts,edges] = histcounts(log(data{i}),Normalization=opt.type);
  else
    % plot distribution of data on loglog axis
    [l_bound,h_bound] = bounds(data{i});
    l_bound = log10(l_bound) - 0.1;
    h_bound = log10(h_bound) + 0.1;
    n_bins = floor( n_bins_ref * ((h_bound-l_bound) / range_ref) ); % adjust number of bins based on range to cover
    edges = logspace(l_bound,h_bound,n_bins);
    [counts,edges] = histcounts(data{i},edges,Normalization=opt.type);
  end
  % center time in bins
  times = (edges(1:end-1) + edges(2:end)) / 2;
  plot(opt.ax,times,counts,Marker='.',Color=opt.colors(i,:),LineWidth=1.6,MarkerSize=9)
  % log parameters to console
  opt.verbose && opt.log && fprintf(1,'range: '+string(h_bound-l_bound)+', n bins: '+string(n_bins)+'\n');
end

% to fit a line I GET EXACTLY y = 1 / x, FILTERING ARTEFACT?
% A = counts(counts~=0);
% B = times(counts~=0);
% n = log(A(2)/A(1)) / log(B(2)/B(1))
% a = A(1) / (B(1)^n)
% Y = a * times.^n;
% plot(times,Y)

if opt.log
  xlabel(opt.ax,'log('+opt.var+')');
  ylabel(opt.ax,'p(log('+opt.var+'))');
else
  adjustAxes(opt.ax,'XScale','log','YScale','log');
  xlabel(opt.ax,opt.var);
  ylabel(opt.ax,'p('+opt.var+')');
end
if ~isempty(opt.labels)
  legend(opt.ax,opt.labels)
end