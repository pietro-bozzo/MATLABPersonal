function pBar(p,x,alpha)
% pBar Draw significance bar between distributions

arguments
  p (:,3)
  x (:,1) = (1 : size(p,1)).'
  alpha (1,1) = 0.05
end

dx = diff(xlim) / 500;
yLim = ylim;
height = yLim(2);
dy = diff(yLim) / 80;

% sort according to distance: nearby pairs first, then second neighbours and so on
distances = diff(p(:,1:2),1,2);
[~,ind] = sort(distances);
p = p(ind,:);

last_i = 0;
for i = 1 : size(p,1)
  x_coord = [x(p(i,1))+dx ,x(p(i,2))-dx];
  
  if p(i,3) < alpha
    % increase height not to overlap lines
    if last_i > p(i,1)
      height = height + dy*3;
    end

    h1 = plot(repelem(x_coord,1,2), height+[-dy,0,0,-dy], 'k', 'LineWidth',1.4);
    if p(i,3) < alpha/50
      h2 = scatter(mean(x_coord)+[-10,0,10]*dx,height+1.3*dy*[1,1,1],'k','Marker','*');
    elseif p(i,3) < alpha/5
      h2 = scatter(mean(x_coord)+[-5,5]*dx,height+1.3*dy*[1,1],'k','Marker','*');
    else
      h2 = scatter(mean(x_coord),height+1.3*dy,'k','Marker','*');
    end
    last_i = p(i,2);
  end
end

ylim([yLim(1),height + dy*5])