function h = raster(spikes,varargin,opt)

arguments
  spikes (:,2) double
end
arguments (Repeating)
  varargin
end
arguments
  opt.height (1,1) double = 0.5
  opt.label = missing % default is default plot behavior, '' to remove from legend, ' ' to show legend with no name ;)
  opt.ax (1,1) matlab.graphics.axis.Axes = gca
end

if ~all(ismissing(opt.label),'all') && ~isText(opt.label)
  error('Argument ''label'' must be string or missing')
end

times = spikes(:,1);
rows = spikes(:,2);

times = [times,times,nan(size(times))].';
rows =  [rows-opt.height,rows+opt.height,nan(size(rows))].';

if ismissing(opt.label)
  % default label
  h = plot(opt.ax,times(:),rows(:),'LineWidth',1,varargin{:});
else
  h = plot(opt.ax,times(:),rows(:),'LineWidth',1,'DisplayName',opt.label,varargin{:});
end
if opt.label == ""
  RemoveFromLegend(h)
end