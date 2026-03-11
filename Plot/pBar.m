function pBar(p,x,alpha,opt)
% pBar Draw horizontal bars representing significant differences between distributions

arguments
  p (:,3)
  x (:,1) = (1 : size(p,1)).'
  alpha (1,1) {mustBeNumeric} = 0.05
  opt.dy (1,1) {mustBeNumeric} = 1
  opt.draw (:,1) {mustBeLogical} = [true,true,true,false] % [n.s., *, **, ***]
end

dx = diff(xlim) / 500;
yLim = ylim;
height = yLim(2);
dy = diff(yLim) / 80 * opt.dy;

% sort according to distance: nearby pairs first, then second neighbours and so on
distances = round(diff(x(p(:,1:2)),1,2),10);
[~,ind] = sortrows([distances,x(p(:,1))]); % sortrows breaks ties by smaller x
p = p(ind,:);

% h
h = p(:,3);
if alpha ~= -1
  h(p(:,3) < alpha) = 1;
  h(p(:,3) < alpha/5) = 2;
  h(p(:,3) < alpha/50) = 3;
  h(p(:,3) >= alpha) = 0;
end

% plot
last_i = 0;
for i = 1 : size(p,1)

  x_coord = [x(p(i,1))+dx ,x(p(i,2))-dx];
  
  if h(i) == 3 && opt.draw(1)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i);
    h2 = scatter(mean(x_coord)+[-10,0,10]*dx,height+1.3*dy*[1,1,1],10,'k','Marker','*');
  elseif h(i) >= 2 && opt.draw(2)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i);
    h2 = scatter(mean(x_coord)+[-5,5]*dx,height+1.3*dy*[1,1],10,'k','Marker','*');
  elseif h(i) >= 1 && opt.draw(3)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i);
    h2 = scatter(mean(x_coord),height+1.3*dy,10,'k','Marker','*');
  elseif h(i) == 0 && opt.draw(4)
    [height,last_i] = plotLine(x_coord,height,dy,p(i,1:2),last_i);
    h2 = text(mean(x_coord),height+0.8*dy,'n.s.','HorizontalAlignment','center','VerticalAlignment','baseline');
  end

  %last_i = p(i,2);

end

ylim([yLim(1),height + dy*5])

end

function [y,last_p] = plotLine(x,y,dy,p,last_p)

  % increase height not to overlap lines
  if last_p > p(1)
    y = y + dy*3;
  end
  h1 = plot(repelem(x,1,2),y+[-dy,0,0,-dy],'k'); % ,'LineWidth',1);
  last_p = p(2);

end