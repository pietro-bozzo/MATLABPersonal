function plotATM(ATM,opt)
% plotATMs Plot avalanche transition matrix

arguments
  ATM (:,:) double
  opt.ticks (:,1) double = [] % ticks used to divide ICs in regions
  opt.labels (:,1) string = []
  opt.title (1,1) string = ""
  opt.clim (2,1) double = [0,1]
  opt.save (1,1) {mustBeLogical} = false
  opt.show (1,1) {mustBeLogical} = false
end

% create figure
fig = figure(Name='ATM',NumberTitle='off',Position=get(0,'ScreenSize')); colormap('jet')
t = tiledlayout(1,1,TileSpacing='Compact'); ax = nexttile();
% plot ATM
plotATMOnAxis(ax,ATM,ticks=opt.ticks,labels=opt.labels,clim=opt.clim);
% create title
if ~isempty(opt.title)
  title(t,opt.title,FontSize=17,FontWeight='Normal');
end
if opt.save
  %saveas(fig,append(this.results_path,'/ATM.',string(this.regions_array(1,i).id),'.svg'),'svg') IMPLEMENT?
end
if ~opt.show
  if ~opt.save
    warning('Both options ''save'' and ''show'' were not selected.')
  end
  close(fig)
end