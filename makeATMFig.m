function fig = makeATMFig(ATM,ticks,groups,opt)
% makeATMFig Plot avalanche transition matrix

arguments
  ATM (:,:) double
  ticks (:,1) double % ticks used to divide ICs in regions
  groups (:,1) double % used to group regions in anatomical areas
  opt.labels (:,1) string = []
  opt.percentile (1,1) double {mustBePositive,mustBeLessThanOrEqual(opt.percentile,1)} = 0.25; % fraction of values to average
  opt.ignore_nans (1,1) {mustBeLogical} = true; % if false, count number of NaNs in average
  opt.title (1,1) string = ""
  opt.clim (2,1) double = [-1,1]
  opt.avrg_clim (2,1) double = [-0.1,0.1]
  opt.save (1,1) {mustBeLogical} = false
  opt.show (1,1) {mustBeLogical} = false
end

% create figure
fig = figure(Name='ATM',NumberTitle='off',Position=get(0,'ScreenSize')); colormap('jet')
t = tiledlayout(2,3,TileSpacing='tight'); main_ax = nexttile(1,[2,2]); avrg_ax = nexttile(3,[1,1]); reg_ax = nexttile(6,[1,1]);
% compute averaged ATMs
avrg_ATM = averageMatrix(ATM,ticks,percentile=opt.percentile,ignore_nans=opt.ignore_nans);
group_ticks = zeros(size(groups));
groups = [0;cumsum(groups)];
for i = 1 : numel(groups) - 1
  group_ticks(i) = sum(ticks(groups(i)+1:groups(i+1)));
end
reg_ATM = averageMatrix(ATM,group_ticks,percentile=opt.percentile);
% plot ATMs
plotATMOnAxis(main_ax,ATM,ticks=ticks,labels=opt.labels,title='ATM difference',clim=opt.clim);
plotATMOnAxis(avrg_ax,avrg_ATM,labels=opt.labels,title='region average',clim=opt.avrg_clim);
plotATMOnAxis(reg_ax,reg_ATM,labels=opt.labels,title='anatomical average',clim=opt.avrg_clim);
% create title
if ~isempty(opt.title)
  title(t,opt.title,FontSize=17,FontWeight='Normal');
end
t.TileSpacing = 'tight';
if opt.save
  %saveas(fig,append(this.results_path,'/ATM.',string(this.regions_array(1,i).id),'.svg'),'svg') IMPLEMENT?
end
if ~opt.show
  if ~opt.save
    warning('Both options ''save'' and ''show'' were not selected.')
  end
  close(fig)
end