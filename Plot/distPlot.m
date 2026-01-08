function varargout = distPlot(Y,group,opt)
% distPlot Plot violin plots, box plots and scattered data
%
% arguments:
%     Y          (n_samples,n_conditions) double, DESCRIBE
%     group      (n_samples,1) double = [], grouping variable (default is one group)
%
% name-value arguments:
%     group2     double = [], third-level grouping variable used to change scatter symbol
%     violin     string = 'none', either:
%                 - 'none'   :  no violins
%                 - 'half'   :  half-violins, right side
%                 - 'half2'  :  half-violins, left side 
%                 - 'full'   :  full violins
%     scale      double = 1, scale violin amplitude
%     vlim       double = [NaN,NaN], theoretical min and max for violin estimation, default is none
%     smooth     double, bandwith of the kernel smoothing window, default uses 'normal-approx' method of the ksdensity function,
%                optimal to extract normal densities
%     support    support for the data, either:
%                 - 'unbounded' (default), 'positive', 'nonnegative', or 'negative'
%                 - (2,1) double, [lower,upper] bounds
%     colors     group colors, one per group or just one for all groups
%     alpha      double = 1, violin transparency (between 0 and 1)
%     box        logical = false, draw boxes
%     bwidth     double = 1, box plot box width
%     jitter     double or 'v', value of uniform jitter for scattered data, default is 'v': violin shape + median line
%     ssize      double = 50, marker size for scattered data
%     scolor     color string or double, scatter colors, default is 'same' and copies violin plots' colors and alpha
%     salpha     double = 1, transparency value for scattered data (between 0 and 1)
%     legend     (n_groups,1) string = [], group labels for legend, default hides everything from legend
%
% output:
%     h          struct, graphic objects handles

% Copyright (C) 2025 by Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

% daviolinplot combines density and box plots for 2-level factorial data 
%
%   Y - data inputcontaining all conditions and all
%   groups. If Y is a matrix, each column has to correspond to a different
%   condition, while the groups need to be specified in 'groups' vector.                    
%   
%   'whiskers'        Draws whiskers to show min and max data values after 
%                     disregarding the outliers (see outlier description)
%                     0 - no whiskers
%                     1 - draw whiskers (default)                     
%
%   'scatter'         0 - no data scatter (deffault)
%                     1 - scatter shifted to the left
%                     2 - scatter in the center
%                     3 - scatter shifted to the right
%
%   'jitter'          0 - do not jitter scattered data 
%                     1 - jitter scattered data (default) MAKE POSITIVE
%                     VALUE BE ALSO JITTER VALUE FOR 1? AND NEGATIVE FOR 2?
%                     2 - build a histogram using the scatter markers
%
%   'jitterspacing'   Horizontal spacing between datapoints for jitter 2 
%                     Default: 1
% 
%   'outliers'        Highlights the outliers in the plot. The outliers 
%                     are values below Q1-1.5*IQR and above Q3+1.5*IQR.
%                     0 - do not highlight outliers  
%                     1 - highlight outliers (default)
%
%   'outfactor'       Multiple of the interquartile range used to find
%                     outliers: below Q1-outfactor*IQR and above 
%                     Q3+outfactor*IQR
%                     Default: 1.5
%
%   'outsymbol'       Symbol and color for highlighting outliers.
%                     Default: 'k*' (black asterisk).
%
%   'boxalpha'        Boxplot transparency (between 0 and 1)
%                     Default: 1 (completely non-transparent)
%
%   'boxspacing'      A real number to scale spacing between boxes in the 
%                     same condition. Note that negative values result in 
%                     partially overlapping boxes within the same condition
%                     Default: 1
%
%   'linkline'        Superimposes lines linking boxplots across conditions
%                     for each group. Helps to see more clearly possible 
%                     interaction effects between conditions and groups.
%                     0 - no dash lines (default)
%                     1 - dash lines
%
%   'withinlines'     Draws a line between each pair of data points in 
%                     paired datasets. Meant to be used only when plotting
%                     one group.
%                     0 - no lines (default)
%                     1 - lines
%
%   'xtlabels'        Xtick labels (a cell of chars) for conditions. If
%                     there is only 1 condition and multiple groups, then 
%                     xticks and xtlabels will automatically mark different
%                     groups.
%                     Default: conditions/groups are numbered in the input 
%                     order
%
%
% Output Arguments:
%
%   h - a structure containing handles for further customization of the produced plot:
%       cpos - condition positions
%       gpos - group positions
%       
%       graphics objects:
%       vl - violin
%       bx - boxplot box
%       md - boxplot median line
%       wh - boxplot whiskers 
%       sm - scattered data median line
%       ot - outlier markers
%       sc - scattered data markers
%       ln - linklines
%       wl - whithin lines
%       lg - legend

arguments
  Y (:,:)
  group (:,1) {mustBeNumeric,mustBeInteger} = []
  opt.group2 (:,1) {mustBeNumeric} = []
  opt.violin (1,1) string {mustBeMember(opt.violin,["half","half2","full","none"])} = "none"
  opt.scale (1,1) {mustBeNumeric} = 1
  opt.vlim (2,1) {mustBeNumeric} = [NaN,NaN]
  opt.smooth (1,1) {mustBeNumeric,mustBeNonnegative} = 0
  opt.support (1,:) = "unbounded"
  opt.colors = []
  opt.spacing (1,1) {mustBeNumeric} = NaN
  opt.alpha (1,1) {mustBeNumeric,mustBeGreaterThanOrEqual(opt.alpha,0),mustBeLessThanOrEqual(opt.alpha,1)} = 0.7
  opt.box (1,1) {mustBeLogical} = false
  opt.bwidth (1,1) {mustBeNumeric} = 1
  opt.bcolor = 'same'
  opt.balpha (1,1) {mustBeNumeric} = NaN
  opt.whisk (1,1) {mustBeLogical} = true
  opt.scatter (1,1) {mustBeLogical} = true
  opt.jitter (1,1) = 'v'
  opt.smedian (1,1) {mustBeLogical} = true
  opt.outliers (1,1) string = "k*"
  opt.ssize (1,1) {mustBeNumeric} = 50
  opt.scolor = 'same'
  opt.salpha (1,1) {mustBeNumeric} = NaN
  opt.linkline (1,1) {mustBeLogical} = false
  opt.withinlines (1,1) {mustBeLogical} = false
  opt.legend (:,1) string = string.empty
  opt.labels (:,1) string = string.empty
end

% validate input
% CHECK support
if ischar(opt.jitter)
  opt.jitter = string(opt.jitter);
end
if ~isnumeric(opt.jitter) && (~isstring(opt.jitter) || opt.jitter ~= "v")
  error('Argument ''jitter'' must be numeric or ''v''')
end

% default values
if opt.smooth == 0
  opt.smooth = 'normal-approx';
end
make_legend = ~isempty(opt.legend);

% default groups
if isempty(group)
  unique_groups = (1 : size(Y,2)).';
  group = repelem(unique_groups,size(Y,1),1);
  n_groups = size(Y,2);
  opt.group2 = repmat(opt.group2,size(Y,2),1);
  Y = Y(:);
else
  if numel(group) ~= size(Y,1)
    error('distPlot:groupSize','Argument ''group'' must have one element for every row of Y')
  end
  unique_groups = unique(group,'stable');
  n_groups = numel(unique_groups);
end
if ~isempty(opt.group2) && numel(group) ~= numel(opt.group2)
  error('distPlot:group2Size','Argument ''group2'' must have one element for every row of Y')
end

% validate colors MISSING VALIDATION FOR OTHER COLORS
if isempty(opt.colors)
  opt.colors = myColors(1:n_groups);
else
  try
    opt.colors = validatecolor(opt.colors,'multiple');
  catch ME
    throw(ME)
  end
  if size(opt.colors,1) == 1
    opt.colors = repmat(opt.colors,n_groups,1);
  elseif size(opt.colors,1) ~= n_groups
    error('myboxPlot:colorNumber',"Data has "+num2str(n_groups)+" groups but "+num2str(size(opt.colors,1))+" colors were given")
  end
end

% default colors
if strcmp(opt.scolor,'same')
  opt.scolor = opt.colors;
  if isnan(opt.salpha)
    opt.salpha = opt.alpha;
  elseif opt.salpha < 0 || opt.salpha > 1
    error('myBoxPlot:salphaValue','Argument ''salpa'' must be between 0 and 1')
  end
end
if strcmp(opt.bcolor,'same')
  opt.bcolor = opt.colors;
  if isnan(opt.balpha)
    opt.balpha = opt.alpha;
  elseif opt.balpha < 0 || opt.balpha > 1
    error('myBoxPlot:balphaValue','Argument ''balpa'' must be between 0 and 1')
  end
end

% positions
n_cond = size(Y,2);
if isnan(opt.spacing)
  % default spacing
  if n_cond == 1
    opt.spacing = 0.01;
  else
    opt.spacing = 1;
  end
end
c_pos = 1 : n_cond; % center of each condition
box_width = 0.6 * opt.bwidth / (n_groups+1);
loc_sp = 0.4 * box_width * opt.spacing; % local spacing between plots
% g_pos has one row per group, one col per cond; each condition is a tick, each group is spread around cond
g_pos = repmat(c_pos,n_groups,1) + ((1 : n_groups).'-(n_groups+1)/2)*(box_width+loc_sp);

if ~make_legend
  opt.legend = strings(n_groups,1);
end

h.gpos = g_pos;
h.cpos = c_pos;

% loop over groups
hold on
pt_all = [];
scdata = cell(2,1);
symbols = ["o","diamond","^","square","pentagram"];
opt.group2 = mod(opt.group2-1,numel(symbols)) + 1;
for g = 1 : n_groups

    % percentiles
    pt = prctile(Y(group==unique_groups(g),:),[2;9;25;50;75;91;98]);
    
    % box coordinates
    box_xcor = g_pos(g,:).' + [-1,1]*box_width/2;
    box_ycor = [pt(3,:).',pt(5,:).'];
    box_medcor = pt(4,:).';

    for k = 1 : n_cond

        this_data = Y(group==unique_groups(g),k);
        is_outlier = isoutlier(this_data);
        if isempty(opt.group2)
          this_g2 = ones(size(this_data));
          this_unique_g2 = 1;
        else
          this_g2 = opt.group2(group==unique_groups(g));
          this_unique_g2 = unique(this_g2);
        end

        if all(isnan(this_data),'all')
          continue % ADD CREATION OF EMPTY DATA?? OR USELESS?
        end

        % 1. violin
        
        % estimate probability density of the data
        [f,xi] = ksdensity(this_data,'Bandwidth',opt.smooth,'BoundaryCorrection','reflection','NumPoints',1000,'Support',opt.support);
        if any(~isnan(opt.vlim))
            % truncate violin
            lims = [min(xi),max(xi)];
            lims(~isnan(opt.vlim)) = opt.vlim(~isnan(opt.vlim));
            f = f(xi >= lims(1) & xi <= lims(2));
            xi = xi(xi >= lims(1) & xi <= lims(2));
            % adjust xi endpoints
            xi(1) = lims(1);
            xi(end) = lims(2);
            xi = [xi(1)*(1-1E-5), xi, xi(end)*(1+1E-5)];
            f = [0,f,0];
        end
        % scale density
        f = f / max(f) * opt.scale / 7 / (n_groups+1);

        % plot violin
        if opt.violin == "full"
          h.vl(k,g) = fill([f,-fliplr(f)]+g_pos(g,k),[xi,fliplr(xi)],opt.colors(g,:),FaceAlpha=opt.alpha,DisplayName=opt.legend(g));
        elseif opt.violin == "half"
          h.vl(k,g) = fill(f+g_pos(g,k),xi,opt.colors(g,:),FaceAlpha=opt.alpha,DisplayName=opt.legend(g));
        elseif opt.violin == "half2"
          h.vl(k,g) = fill(-f+g_pos(g,k),xi,opt.colors(g,:),FaceAlpha=opt.alpha,DisplayName=opt.legend(g));
        end

        % 2. box

        if opt.box
            % boxes
            h.bx(k,g) = fill(box_xcor(k,[1,1,2,2]),box_ycor(k,[1,2,2,1]),opt.bcolor(g,:),'FaceAlpha',opt.balpha);
            % median
            h.md(k,g) = line(box_xcor(k,[1,2]),box_medcor([k,k]),'color','k','LineWidth', 2);
            % plot whiskers
            if opt.whisk
                m = min(this_data(~is_outlier));
                M = max(this_data(~is_outlier));
                h.wh(k,g,:) = plot(g_pos(g,k)*[1,1],[m,box_ycor(k,1)],'k-',g_pos(g,k)*[1,1],[M,box_ycor(k,2)],'k-','LineWidth',1.5);
            end             
        end

        % 3. scatter
        
        % jitter scattered data
        if isstring(opt.jitter)
          % if jitter is 'v'
          f = [f,NaN]; % add NaN at the end for elements outside bounds
          distr_ind = discretize(this_data,xi);
          distr_ind(isnan(distr_ind)) = numel(f); % I NOW GIVE NaN TO ELEMENTS OUTSIDE vlim BUT ACTUALLY SHOULD ERROR
          xdata = g_pos(g,k) + (rand(size(this_data)) - 0.5) * 2 .* f(distr_ind).';
          % draw median
          if opt.scatter && opt.smedian
            h.sm(k,g) = line(g_pos(g,k)+[-1,1]*0.25*opt.scale/(n_groups+1),pt(4,k)*[1,1],'Color','k','LineWidth',1.5);
          end
        elseif opt.jitter == 0
          xdata = g_pos(g,k)*ones(numel(this_data),1);
        else
          xdata = g_pos(g,k)*ones(numel(this_data),1) + (box_width/1.5)*(0.5 - rand(numel(this_data),1)); % ADD jitter intensity here ??
        end

        % scatter data
        if opt.scatter
          h.sc(k,g) = scatter(NaN,NaN,MarkerFaceColor=opt.colors(g,:),MarkerEdgeColor='k',MarkerFaceAlpha=opt.salpha,DisplayName=opt.legend(g));
          for i = 1 : numel(this_unique_g2)
            do_scatter = ~is_outlier & this_g2 == this_unique_g2(i);
            h.sc(k,g) = scatter(xdata(do_scatter),this_data(do_scatter),opt.ssize,symbols(this_unique_g2(i)),MarkerFaceColor=opt.colors(g,:),MarkerEdgeColor='k', ...
              MarkerFaceAlpha=opt.salpha);
          end
        end
        if opt.outliers ~= ""
          h.ot(k,g) = scatter(xdata(is_outlier),this_data(is_outlier),opt.ssize,opt.outliers);    
        end
        
        % store data in case it's needed for withinlines SHOULD CHECK AT THE BEGINNING THAT n points IS SAME
        scdata{1} = scdata{2};
        scdata{2} = [xdata,this_data];
    end
    
    % draw a line that links each group across conditions
    if opt.linkline
       h.ln(g) = line(g_pos(g,:),pt(4,:),'color',opt.colors(g,:),'LineStyle','-.','LineWidth',1.5); 
    end

    % link paired data points within groups
    if opt.withinlines && g > 1
      x_line = [scdata{1}(:,1),scdata{2}(:,1),nan(size(scdata{1}(:,1)))].';
      y_line = [scdata{1}(:,2),scdata{2}(:,2),nan(size(scdata{1}(:,2)))].';
      h.wl(g-1) = plot(x_line(:),y_line(:),'Color',[0.8,0.8,0.8,0.7],'LineWidth',1.1);
      uistack(h.wl(g-1),'bottom')
    end
    pt_all = [pt_all, pt];
end

% move lines to the background
if opt.linkline==1
    uistack(h.ln,'bottom')
end

% build legend
if opt.violin ~= "none"
  legend_field = "vl";
elseif opt.scatter
  legend_field = "sc";
else
  legend_field = "bx";
end
% remove unnecessary lines
for field = fieldnames(h).'
  if ~ismember(field{1},["gpos","cpos",legend_field])
    RemoveFromLegend(h.(field{1}))
  end
end
RemoveFromLegend(h.(legend_field)(2:end,:))
if ~make_legend
  % remove all lines
  RemoveFromLegend(h.(legend_field)(1,:))
else
  h.lg = legend();
end

% set ticks and labels
if n_cond == 1
  xticks(g_pos);
else
  xticks(c_pos);
end
if ~isempty(opt.labels)
  xticklabels(opt.labels);
end

xlim([g_pos(1)-0.6*box_width, g_pos(end)+0.6*box_width]); % adjust x-axis margins

h.pt_all = pt_all;

if nargout > 0
  varargout{1} = h;
end