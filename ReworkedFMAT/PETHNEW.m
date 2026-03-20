function varargout = PETHNEW(samples,events,varargin,opt)

% /!\ PROBLEM: mixing varargin and opt

% PETH - Compute a peri-event time histogram relative to synchronizing events
%
%  USAGE
%
%    [mat,t,mean] = PETH(samples,events,<options>)
%
%  INPUT
%
%    samples         either a list of timestamps (e.g. a spike train) or a
%                    (n,2) matrix of [timestamps values], in case of a continuous
%                    signal (e.g. reactivation strength, local field potential)
%                    
%    events          timestamps to synchronize on (e.g., brain
%                    stimulations)
%    <options>       optional list of property-value pairs (see table below)
%
%    =========================================================================
%     Properties     Values
%    -------------------------------------------------------------------------
%     'durations'    durations before and after synchronizing events for each
%                    trial (in s) (default = [-1 1])
%     'nBins'        number of time bins around the events (default = 101)
%     'fast'         if 'off' (default), sort 'samples' and 'events' before
%                    operating, otherwise they are expected to be sorted
%                    (only for timestamps input)
%     'group'        indeces to group samples, a separate output will be computed
%                    per group (much faster than calling PETH once per group;
%                    only for timestamps input)
%     'mode'         whether the sample data is linear ('l') or circular ('c')
%                    (for example, in the case 'samples' is the phase of an
%                    oscillation; only for matrix input)
%     'show'         display the mean PETH (default = 'on' when no outputs are
%                    requested and 'off' otherwise)
%     'smooth'       standard deviation for Gaussian kernel (default = 1 bin)
%                    applied to the mean peri-event activity 'm' (note, no
%                    smoothing will be applied to the output 'matrix')
%     'title'        if the results are displayed ('show' = 'on'), specify a
%                    desired title (default is deduced by variable names)
%     <plot options> any other property (and all the properties that follow)
%                    will be passed down to "plot" (e.g. 'r', 'linewidth', etc);
%                    because all the following inputs are passed down to "plot",
%                    make sure you put these properties last
%    =========================================================================
%
%  OUTPUT
%
%    mat             matrix containing the counts of a point process (for 
%                    timestamp data) or the avarage activity (for a continous
%                    signal) around the synchronizing events. Each column
%                    corresponds to a particular delay around the event (delay
%                    value indicated in timeBins), and each row corresponds to
%                    a synchronizing event ('mat' is a cell array when 'group'
%                    is provided)
%    timeBins        time bin delay values corresponding columns of 'mat'
%    mean            average activity across all events (a cell array when 'group' 
%                    is provided)
%
%  EXAMPLE
%
%    % show mean spiking activity around the stimuli:
%    PETH(spikes(:,1),stimuli); 
%
%    % compute the mean lfp around delta wave peaks:
%    [matrix,timeBins,m] = PETH([lfp.timestamps double(lfp.data(:,1))],deltaWaves.peaks); 
%
%    % get the order of delta wave power:
%    [~,order] = sort(deltaWaves.peakNormedPower); 
%    plot the mean lfp around delta waves as ordered according to delta wave power
%    PlotColorMap(matrix(order,:),'x',timeBins);
%
%  SEE
%
%    See also Sync, SyncHist, SyncMap, PlotSync, PETHTransition.

% Copyright (C) 2018-2025 by Ralitsa Todorova & Michaël Zugaro, Pietro Bozzo
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.

arguments
    samples (:,:)
    events (:,1)
end
arguments (Repeating)
    varargin
end
arguments
    opt.durations (2,1) = [-1,1] % CHECK TO ALLOW 'duration'
    opt.nBins (1,1) {mustBeInteger,mustBePositive} = 101
    opt.fast {mustBeGeneralLogical} = false
    opt.group {mustBeNumeric} = []
    opt.mode string {mustBeMember(opt.mode,["l","c"])} = "l"
    opt.show = []
    opt.smooth (1,1) {mustBeNumeric,mustBeNonnegative} = 1
    opt.title (1,1) string = missing
end

% validate input
if size(samples,2) > 2
    error('Samples must have one or two columns (type ''help <a href="matlab:help PETH">PETH</a>'' for details).')
end
if ~isempty(opt.group) && size(opt.group,1) ~= size(samples,1)
    error('Incorrect value for property ''group'' (type ''help <a href="matlab:help PETH">PETH</a>'' for details).');
end
if isempty(opt.show)
    if nargout < 1, opt.show = 'on'; else, opt.show = 'off'; end
end
opt.show = GeneralLogical(opt.show);
opt.fast = GeneralLogical(opt.fast);

% default values
if ismissing(opt.title)
    opt.title = replace([inputname(1) ' synchronised to ' inputname(2)],'_','\_');
end

if isempty(samples)
  [varargout{[1,3]}] = deal(nan(1,opt.nBins));
  varargout{2} = linspace(opt.durations(1),opt.durations(2),opt.nBins);
  return
end

groups = unique(opt.group);

if size(samples,2) == 2
    % 1. samples is a signal
    t = linspace(opt.durations(1),opt.durations(2),opt.nBins);
    mat_t = bsxfun(@plus,events,t);
    dt = diff(samples(:,1));
    samples(dt>median(dt)*2,2) = nan;       % To take care of gaps in the signal : interpolate values in the gaps to nans
    if strcmp(opt.mode,'l')
        mat = interp1(samples(:,1),samples(:,2),mat_t);
        m = Smooth(mean(mat,'omitnan'),opt.smooth);
    else % circular data
        unwrapped = unwrap(samples(:,2));
        mat = wrap(interp1(samples(:,1),unwrapped,mat_t));
        angles = mean(exp(1i*mat),'omitnan');
        smoothed = [Smooth(imag(angles(:)),opt.smooth) Smooth(real(angles(:)),opt.smooth)];
        m = atan2(smoothed(:,1),smoothed(:,2));
    end
else
    % 2. samples is a point process
    % synchronize samples to events
    [sync,Ie,Is] = Sync(samples,events,'durations',opt.durations,'fast',opt.fast);
    t = linspace(opt.durations(1),opt.durations(2),opt.nBins+1); % nBins+1 chosen to match previous behavior of Bins
    time_bin = t(2) - t(1);
    % compute matrix
    if isempty(opt.group)
        mat = sync2mat(sync,Ie,t,size(events,1),opt.nBins);
        if opt.show || nargout > 2
            m = smoothdata(mean(mat),'gaussian',5*opt.smooth) / time_bin; % factor 5 chosen to match previous behavior of Smooth
        end
    else
        % compute per group
        opt.group = opt.group(Is);
        mat = cell(numel(groups),1);
        m = cell(numel(groups),1);
        for g = 1 : numel(groups)
            mat{g} = sync2mat(sync(opt.group==groups(g)),Ie(opt.group==groups(g)),t,size(events,1),opt.nBins);
            if opt.show || nargout > 2
                m{g} = smoothdata(mean(mat{g}),'gaussian',5*opt.smooth) / time_bin;
            end
        end
    end
    % adjust times and title
    t = (t(1:end-1) + t(2:end)) / 2;
    if opt.show
        opt.title = [opt.title ', ' num2str(numel(Ie)) ' x ' num2str(numel(unique(Ie))) ' instances'];
    end
end

% plot
if opt.show
    if isempty(opt.group)
        plot(t,m,varargin{:});
    else
        hold on
        cellfun(@(x) plot(t,x,varargin{:}),m)
    end
    title(opt.title);
end

if nargout > 0
    varargout{1} = mat;
    varargout{2} = t;
end
if nargout > 2
    varargout{3} = m;
end

end

% --- helper functions ---

function mat = sync2mat(sync,Ie,t,nEvents,nBins)

    mat = zeros(nEvents,nBins);
    if ~isempty(sync)
        s = discretize(sync,t);
        % correct numerical errors in sync (elements outside 'limits')
        nan_ind = isnan(s);
        if any(nan_ind)
          s(nan_ind & sync > t(end-1)) = nBins;
          s(nan_ind & sync < t(2)) = 1;
        end
        mat(:) = accumarray(sub2ind(size(mat),Ie,s),1,[numel(mat),1]); % Can maybe change with size(mat) !!
    end

end