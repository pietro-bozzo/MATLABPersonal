function plotIntervals(intervals,opt)

%PlotIntervals - Plot vertical bars or rectangles to show interval limits.
%
% Given a list of intervals [start stop], draw a green vertical bar at
% the beginning of each interval, and a red vertical bar at the end of
% each interval or a grey rectangle representing the interval.
%
%  USAGE
%
%    PlotIntervals(intervals,<options>)
%
%    intervals      list of [start stop] intervals
%    <options>      optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties    Values
%    -------------------------------------------------------------------------
%     'style'       'bars' for colored vertical bars, or 'rectangles' for
%                   background shaded rectangles (default)
%     'direction'   'h' for horizontal, or 'v' for vertical (default)
%     'color'       rectangle color ('rectangles' mode, default = grey)
%     'alpha'       rectangle transparency ('rectangles' mode, default = 1)
%    =========================================================================
%

% Copyright (C) 2008-2013 by Gabrielle Girardeau & Michaël Zugaro
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

arguments
  intervals (:,2) double
  opt.style (:,1) char = 'rectangles'
  opt.direction (1,1) char = 'v'
  opt.color (1,3) double {mustBeNonnegative} = [0.9,0.9,0.9]
  opt.alpha (1,1) double {mustBeNonnegative} = 1
  opt.ylim (2,1) double = ylim
end

[style,direction,color,alpha,yLim] = unpackArgs(opt);

hold on;
xLim = xlim;
if strcmp(style,'bars')
  for i = 1 : size(intervals,1)
    if strcmp(direction,'v')
      plot([intervals(i,1),intervals(i,1)],yLim,'Color',[0,0.75,0]);
      plot([intervals(i,2),intervals(i,2)],yLim,'Color',[0.9,0,0]);
    else
      plot(xLim,[intervals(i,1),intervals(i,1)],'Color',[0,0.75,0]);
      plot(xLim,[intervals(i,2),intervals(i,2)],'Color',[0.9,0,0]);
    end
  end
else
  for i = 1 : size(intervals,1)
		if strcmp(direction,'v')
			dx = intervals(i,2) - intervals(i,1);
			dy = yLim(2) - yLim(1);
			rec = patch(intervals(i,1)+[0,0,dx,dx],yLim(1)+[0,dy,dy,0],color,'FaceAlpha',alpha,'LineStyle','none','HandleVisibility','off');
		else
			dx = xLim(2) - xLim(1);
			dy = intervals(i,2) - intervals(i,1);
			rec = patch(xLim(1)+[0,0,dx,dx],intervals(i,1)+[0,dy,dy,0],color,'FaceAlpha',alpha,'LineStyle','none','HandleVisibility','off');
        end
		% uistack(rec,'bottom'); TOO LSOW
  end
end