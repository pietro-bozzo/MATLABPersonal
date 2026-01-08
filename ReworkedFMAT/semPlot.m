function line = semPlot(ax,x,y,opt)
% semPlot Plot data and standard error of the mean

arguments
  ax (1,1)
  x (:,1)
  y (:,:)
  opt.color (1,3) double {mustBeNonnegative} = myColors(1)
  opt.smooth (1,1) double = 0 
end

if size(y,2) ~= numel(x)
  error('semPlot:argumentShape','y should have one column for each element in x.')
end

%if isvector(y),
%    handle = plot(x,Smooth(y,smooth),'color',color);
%    return
%end

% a = [nanmean(y)-nansem(y); nanmean(y)+nansem(y)]';
% % a = [quantile(y,0.25); quantile(y,0.75)]';
% a(:,2) = a(:,2)-a(:,1);
% a(:,1) = Smooth(a(:,1),smooth);
% a(:,2) = Smooth(a(:,2),smooth);
% 
% handles = area(x,a,'EdgeColor','none','FaceColor',color);
% delete(handles(1));
% handle = handles(2);
% set(get(handle,'children'),'FaceAlpha',0.5);
% % set(get(handle,'children'),'FaceColor',mean([get(get(handle,'children'),'FaceColor');1 1 1]));


xx = [x(:);flipud(x(:))];
yy = [Smooth(nanmean(y)'-nansem(y)',opt.smooth); Smooth(flipud(nanmean(y)'+nansem(y)'),opt.smooth)];
y = Smooth(nanmean(y),opt.smooth);

hold on;
handles = fill(ax,xx,yy,opt.color,FaceAlpha=0.3,EdgeAlpha=0,DisplayName='');
% set(handles,'FaceColor',mean([color;1 1 1]),'edgeAlpha',0);

line = plot(ax,x,y,Color=opt.color,LineWidth=2);