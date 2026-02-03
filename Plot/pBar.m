function pBar(p,x,alpha,opt)
% pBar Draw significance bar between distributions

arguments
  p (:,3)
  x (:,1) = (1 : size(p,1)).'
  alpha (1,1) = 0.05
  opt.dy (1,1) = 1
  opt.draw (:,1) {mustBeLogical} = [true,true,true,false]
end

dx = diff(xlim) / 500;
yLim = ylim;
height = yLim(2);
dy = diff(yLim) / 80 * opt.dy;

% sort according to distance: nearby pairs first, then second neighbours and so on
distances = diff(p(:,1:2),1,2);
[~,ind] = sort(distances);
p = p(ind,:);

last_i = 0;
for i = 1 : size(p,1)

  x_coord = [x(p(i,1))+dx ,x(p(i,2))-dx];
  
  if p(i,3) < alpha / 50 && opt.draw(1)
    height = plotLine(x_coord,height,dy,p(i,1),last_i);
    h2 = scatter(mean(x_coord)+[-10,0,10]*dx,height+1.3*dy*[1,1,1],'k','Marker','*');
  elseif p(i,3) < alpha / 5 && opt.draw(2)
    height = plotLine(x_coord,height,dy,p(i,1),last_i);
    h2 = scatter(mean(x_coord)+[-5,5]*dx,height+1.3*dy*[1,1],'k','Marker','*');
  elseif p(i,3) < alpha && opt.draw(3)
    height = plotLine(x_coord,height,dy,p(i,1),last_i);
    h2 = scatter(mean(x_coord),height+1.3*dy,'k','Marker','*');
  elseif p(i,3) >= alpha && opt.draw(4)
    height = plotLine(x_coord,height,dy,p(i,1),last_i);
    h2 = text(mean(x_coord),height+0.8*dy,'n. s.','HorizontalAlignment','center','VerticalAlignment','baseline');
  end

  last_i = p(i,2);

end

ylim([yLim(1),height + dy*5])

end

function y = plotLine(x,y,dy,p,last_p)

  % increase height not to overlap lines
  if last_p > p
    y = y + dy*3;
  end
  h1 = plot(repelem(x,1,2),y+[-dy,0,0,-dy],'k','LineWidth',1.4);

end