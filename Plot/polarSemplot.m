function h = polarSemplot(phi,theta,color,opt)
% polarSemplot Plot mean +/- sem of data

arguments
    phi (:,1)
    theta (:,:)
    color = myColors(1)
    opt.mode (1,1) string {mustBeMember(opt.mode,["sem","std"])} = "sem"
    opt.smooth {mustBeScalarOrEmpty} = []
    opt.semColor (:,:) = []
    opt.legend (1,1) string = "mean ± sem"
    opt.lineProp (:,1) cell = {}
    opt.ax (1,1) = gca
end

% validate input
try
  color = validatecolor(color,'multiple');
catch ME
  throw(ME)
end

% default value
if isempty(opt.semColor)
  opt.semColor = color;
end

% compute mean and dashed lines
theta_avrg = mean(theta,1,'omitnan');
if opt.mode == "sem"
  theta_area = nansem(theta,1);
else
  theta_area = std(theta,1,'omitnan');
end

% smooth
if opt.smooth ~= 0
  theta_avrg = circularSmooth(theta_avrg,[],'gaussian',opt.smooth);
  theta_area = circularSmooth(theta_area,[],'gaussian',opt.smooth);
end

% plot lines
phi = [phi;phi(1)];
theta_avrg = [theta_avrg,theta_avrg(1)];
theta_area = [theta_area,theta_area(1)];
h(1) = polarplot(opt.ax,phi,theta_avrg,'Color',color,'LineWidth',1.3,opt.lineProp{:});
hold on
h(2) = polarplot(opt.ax,phi,theta_avrg+theta_area,'Color',color,'LineStyle','--',opt.lineProp{:});
h(3) = polarplot(opt.ax,phi,theta_avrg-theta_area,'Color',color,'LineStyle','--',opt.lineProp{:});
RemoveFromLegend(h(2:3))

if opt.legend == missing
  RemoveFromLegend(h(1))
else
  h(1).DisplayName = opt.legend;
end