function plotPercent(data,opt)
% plotPercent Plot percentages on a bar graph

arguments
  data (:,:) double % n conditions x n groups (bars per condition)
  opt.labels (:,1) string = []
  opt.legend (:,1) string = []
  opt.colors (:,3) double = []
  opt.ax = matlab.graphics.axis.Axes.empty
end

% validate input
if ~isempty(opt.legend) && size(data,2) ~= numel(opt.legend)
  error('plotPercent:legendNumber','Number of legend entries must equal number of groups (columns of ''data'')')
end
if ~isempty(opt.labels) && size(data,1) ~= numel(opt.labels)
  error('plotPercent:labelNumber','Number of labels must equal number of conditions (rows of ''data'')')
end
if ~isempty(opt.colors) && size(data,2) ~= size(opt.colors,1) && numel(data) ~= size(opt.colors,1)
  error('plotPercent:colorNumber','Number of colors must equal number of groups (columns of ''data'') or number of ''data'' elements')
end

% default value
if isempty(opt.ax)
  opt.ax = gca;
end

% draw bars
b = bar(opt.ax,data,FaceColor='flat');

% adjust labels
if ~isempty(opt.legend)
  for i = 1 : size(data,2)
    b(i).DisplayName = opt.legend(i);
  end
  legend
end
% adjust colors
if ~isempty (opt.colors)
  if size(data,2) == size(opt.colors,1)
    for i = 1 : size(data,2)
      b(i).CData = opt.colors(i,:);
    end
  else
    k = 1;
    for i = 1 : size(data,1)
      for j = 1 : size(data,2)
        b(j).CData(i,:) = opt.colors(k,:);
        k = k + 1;
      end
    end
  end
end
if ~isempty(opt.labels)
  set(opt.ax,'XTick',b(1).XData,'XTickLabel',opt.labels)
end
adjustAxes(opt.ax)
ylabel(opt.ax,'percentage (%)');

% old code to give labels to bar tips
% if ~isempty(opt.labels)
%   xtips = b.XEndPoints;
%   ytips = b.YEndPoints;
%   hor_align = 'center';
%   ver_align = 'bottom';
%   rotation = 0;
%   if max(strlength(opt.labels)) > 5
%     % rotate text if it's too long
%     ytips = ytips + max(ytips) * 0.01; % adjust height not to touch bars
%     hor_align = 'left';
%     ver_align = 'middle';
%     rotation = 90;
%   end
%   text(xtips,ytips,opt.labels,HorizontalAlignment=hor_align,VerticalAlignment=ver_align,Rotation=rotation)
% end