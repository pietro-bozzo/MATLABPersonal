function plotATMOnAxis(ax,ATM,opt)
% plotATMs Plot avalanche transition matrix

arguments
  ax (1,1)
  ATM (:,:) double
  opt.ticks (:,1) double = [] % ticks used to divide ICs in regions
  opt.labels (:,1) string = []
  opt.title (1,1) string = ""
  opt.clim (2,1) double = [-1,1]
end

% plot ATM
h = imagesc(ax,ATM); set(h,'AlphaData',~isnan(ATM)); colorbar(ax)
% create labels
if isempty(opt.ticks)
  if isempty(opt.labels)
    ticks = [];
  else
    ticks = 1 : numel(opt.labels);
  end
  labels = opt.labels;
else
  ticks = 0.5;
  labels = "";
  indeces = 1;
  for i = 1 : numel(opt.ticks)
    if isempty(opt.labels)
      ticks = [ticks;ticks(end)+opt.ticks(i)];
      labels = [];
    else
      ticks = [ticks;ticks(end)+opt.ticks(i)/2;ticks(end)+opt.ticks(i)];
      labels = [labels,opt.labels(i),""];
    end
    indeces(end+1) = ticks(end) + 0.5;
  end
  % add lineas separating regions
  for k = 2 : numel(indeces) - 1
    line(ax,[indeces(k)-0.5,indeces(k)-0.5],[0.5,indeces(end)-0.5],Color=[0,0,0]);
    line(ax,[0.5,indeces(end)-0.5],[indeces(k)-0.5,indeces(k)-0.5],Color=[0,0,0]);
  end
end
% adjust plot
set(ax,TickDir='out',XLim=[0.5,size(ATM,1)+0.5],YLim=[0.5,size(ATM,2)+0.5],YDir='normal',XTick=ticks,YTick=ticks,XTickLabel=labels,YTickLabel=labels,CLim=opt.clim,Box='off', ...
  PlotBoxAspectRatio=[1,1,1])
xlabel(ax,'regions, t',FontSize=14);
ylabel(ax,'regions, t + 1',FontSize=14);
% create title
if ~isempty(opt.title)
  title(ax,opt.title,FontSize=17,FontWeight='Normal');
end